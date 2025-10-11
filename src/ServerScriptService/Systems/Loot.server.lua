-- Loot.server.lua
-- Story 2: Enhanced lootable containers with visual/audio feedback
-- REFACTORED: Particle effects, SFX, lid animation, cooldown tracking, 3 unique loots per day

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local LootRegistry = require(ReplicatedStorage.Items.LootRegistry)
local Signals = require(ReplicatedStorage.Shared.Signals)
local AssetConfig = require(ReplicatedStorage.Shared.AssetConfig)

local TAG = "LootCrate"
local lootedCrates = {} -- Track loot count per crate: { [part] = { count = 0, maxLoots = 3 } }

-- Tween constants from ux-context.md
local TWEEN_FEEDBACK = 0.15

local function createPuffParticle(part)
  -- Create a dust puff particle effect
  local particle = Instance.new("ParticleEmitter")
  particle.Name = "LootPuff"
  particle.Texture = AssetConfig.Particles.Smoke
  particle.Rate = 0
  particle.Lifetime = NumberRange.new(0.5, 0.8)
  particle.Speed = NumberRange.new(2, 4)
  particle.SpreadAngle = Vector2.new(30, 30)
  particle.Color = ColorSequence.new(Color3.fromRGB(200, 180, 150))
  particle.Size = NumberSequence.new(1, 2)
  particle.Transparency = NumberSequence.new(0.3, 1)
  particle.Parent = part
  return particle
end

local function createCooldownIndicator(part)
  -- Create a billboard GUI to show cooldown state
  local billboard = Instance.new("BillboardGui")
  billboard.Name = "CooldownIndicator"
  billboard.Size = UDim2.new(3, 0, 1, 0)
  billboard.StudsOffset = Vector3.new(0, 2, 0)
  billboard.AlwaysOnTop = true
  billboard.Parent = part

  local frame = Instance.new("Frame")
  frame.Size = UDim2.new(1, 0, 0.1, 0)
  frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
  frame.BorderSizePixel = 0
  frame.Parent = billboard

  local fill = Instance.new("Frame")
  fill.Name = "Fill"
  fill.Size = UDim2.new(0, 0, 1, 0)
  fill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
  fill.BorderSizePixel = 0
  fill.Parent = frame

  local label = Instance.new("TextLabel")
  label.Name = "Label"
  label.Size = UDim2.new(1, 0, 1, 0)
  label.BackgroundTransparency = 1
  label.Text = "3/3"
  label.TextColor3 = Color3.fromRGB(255, 255, 255)
  label.TextScaled = true
  label.Font = Enum.Font.GothamBold
  label.Parent = frame

  return billboard
end

local function updateCooldownIndicator(part, current, max)
  local indicator = part:FindFirstChild("CooldownIndicator")
  if not indicator then
    return
  end

  local frame = indicator:FindFirstChild("Frame")
  if not frame then
    return
  end

  local fill = frame:FindFirstChild("Fill")
  local label = frame:FindFirstChild("Label")

  if fill and label then
    local ratio = current / max
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    label.Text = string.format("%d/%d", current, max)

    -- Color feedback: green when available, red when depleted
    if current > 0 then
      fill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    else
      fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
  end
end

local function setCrateVisualState(part, remainingLoots, maxLoots)
  -- Defensive: Verify part still exists and is valid
  if not part or not part.Parent then
    warn("[Loot] setCrateVisualState called on invalid/destroyed crate")
    return false
  end

  -- Visual feedback: show availability based on remaining loots
  local prompt = part:FindFirstChild("LootCratePrompt")

  if remainingLoots <= 0 then
    part.Transparency = 0.7
    part.BrickColor = BrickColor.new("Dark stone grey")
    if prompt then
      prompt.Enabled = false
    end
  else
    part.Transparency = 0
    part.BrickColor = BrickColor.new("Br. yellowish orange")
    if prompt then
      prompt.Enabled = true
    end
  end

  updateCooldownIndicator(part, remainingLoots, maxLoots)

  -- Verify cooldown indicator was properly updated
  local indicator = part:FindFirstChild("CooldownIndicator")
  if not indicator then
    warn(string.format("[Loot] Missing CooldownIndicator on crate '%s' - recreating", part.Name))
    createCooldownIndicator(part)
    updateCooldownIndicator(part, remainingLoots, maxLoots)
  end

  return true
end

local function playLidNudgeAnimation(part)
  -- Lid nudge animation using TWEEN_FEEDBACK (0.15s)
  local tweenInfo = TweenInfo.new(
    TWEEN_FEEDBACK,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
    0,
    true -- Reverses back to original position
  )

  local originalCFrame = part.CFrame
  local goal =
    { CFrame = originalCFrame * CFrame.new(0, 0.3, 0) * CFrame.Angles(math.rad(10), 0, 0) }

  local tween = TweenService:Create(part, tweenInfo, goal)
  tween:Play()
end

local function playSFX_LootOpen(part)
  -- Play loot open sound effect at -10 dB (ux-context.md)
  local sound = Instance.new("Sound")
  sound.Name = "SFX_LootOpen"
  sound.SoundId = AssetConfig.Sounds.LootOpen
  sound.Volume = AssetConfig.Volume.SFX_Standard
  sound.Parent = part
  sound:Play()

  -- Clean up after playing (primary method)
  sound.Ended:Connect(function()
    sound:Destroy()
  end)

  -- Backup cleanup to prevent memory leaks if Ended doesn't fire
  -- Typical switch sound duration is < 1s, so 2s is a safe fallback
  task.delay(2, function()
    if sound.Parent then
      sound:Destroy()
    end
  end)
end

local function wireCrate(part)
  -- Create proximity prompt
  if not part:FindFirstChildWhichIsA("ProximityPrompt") then
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LootCratePrompt"
    prompt.ActionText = "Loot"
    prompt.ObjectText = "Crate"
    prompt.HoldDuration = 0.5
    prompt.Parent = part
  end

  -- Initialize crate loot tracking (3 loots per day phase)
  local maxLoots = 3
  lootedCrates[part] = { count = 0, maxLoots = maxLoots }

  -- Create particle emitter
  if not part:FindFirstChild("LootPuff") then
    createPuffParticle(part)
  end

  -- Create cooldown indicator
  if not part:FindFirstChild("CooldownIndicator") then
    createCooldownIndicator(part)
  end

  -- Set initial visual state
  setCrateVisualState(part, maxLoots, maxLoots)

  -- Handle loot interaction
  part:FindFirstChild("LootCratePrompt").Triggered:Connect(function(player)
    local crateData = lootedCrates[part]
    if not crateData or crateData.count >= crateData.maxLoots then
      return -- Already looted max times today
    end

    -- Attempt to loot
    local success = LootRegistry.tryLoot(player, part)
    if success then
      -- Increment loot count
      crateData.count += 1
      local remaining = crateData.maxLoots - crateData.count

      -- Play visual/audio feedback
      playLidNudgeAnimation(part)
      playSFX_LootOpen(part)

      -- Emit particle puff
      local puff = part:FindFirstChild("LootPuff")
      if puff then
        puff:Emit(15)
      end

      -- Update visual state
      setCrateVisualState(part, remaining, crateData.maxLoots)

      print(string.format("[Loot] Crate looted: %d/%d remaining", remaining, crateData.maxLoots))
    end
  end)
end

-- Reset all crates at the start of each day
Signals.DayStarted.Event:Connect(function()
  local resetCount = 0
  local staleCount = 0
  local errorCount = 0

  for crate, data in pairs(lootedCrates) do
    -- Defensive: Remove stale references to destroyed crates
    if not crate or not crate.Parent then
      lootedCrates[crate] = nil
      staleCount += 1
      warn(string.format("[Loot] Removed stale crate reference during day reset"))
      continue
    end

    if data then
      -- Reset loot count
      data.count = 0

      -- Apply visual state with verification
      local success = setCrateVisualState(crate, data.maxLoots, data.maxLoots)

      if success then
        -- Verify all critical child elements exist
        local prompt = crate:FindFirstChild("LootCratePrompt")
        local particle = crate:FindFirstChild("LootPuff")
        local indicator = crate:FindFirstChild("CooldownIndicator")

        if not prompt then
          warn(string.format("[Loot] Crate '%s' missing ProximityPrompt after reset", crate.Name))
          errorCount += 1
        end

        if not particle then
          warn(string.format("[Loot] Crate '%s' missing particle emitter - recreating", crate.Name))
          createPuffParticle(crate)
        end

        if not indicator then
          -- Already handled by setCrateVisualState, but log it
          errorCount += 1
        end

        resetCount += 1
      else
        errorCount += 1
      end
    end
  end

  -- Log comprehensive reset summary
  print(
    string.format(
      "[Loot] Day reset complete: %d crates reset, %d stale references removed, %d errors detected",
      resetCount,
      staleCount,
      errorCount
    )
  )
end)

-- Tag crates in Studio with CollectionService Tag "LootCrate"
for _, part in ipairs(CollectionService:GetTagged(TAG)) do
  wireCrate(part)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(wireCrate)

-- Defensive: Clean up tracking when crates are removed
CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(part)
  if lootedCrates[part] then
    lootedCrates[part] = nil
    print(string.format("[Loot] Cleaned up tracking for removed crate '%s'", part.Name))
  end
end)
