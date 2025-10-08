-- Loot.server.lua
-- Connect ProximityPrompts named 'LootCratePrompt' to LootRegistry

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local LootRegistry = require(ReplicatedStorage.Items.LootRegistry)
local Signals = require(ReplicatedStorage.Shared.Signals)

local TAG = "LootCrate"
local lootedCrates = {} -- Track which crates have been looted today

local function setCrateVisualState(part, isLooted)
  -- Visual feedback: reduce transparency and disable prompt when looted
  if isLooted then
    part.Transparency = 0.7
    part.CanCollide = true
    local prompt = part:FindFirstChild("LootCratePrompt")
    if prompt then
      prompt.Enabled = false
    end
  else
    part.Transparency = 0
    part.CanCollide = true
    local prompt = part:FindFirstChild("LootCratePrompt")
    if prompt then
      prompt.Enabled = true
    end
  end
end

local function wireCrate(part)
  if not part:FindFirstChildWhichIsA("ProximityPrompt") then
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LootCratePrompt"
    prompt.ActionText = "Loot"
    prompt.ObjectText = "Crate"
    prompt.HoldDuration = 0.5
    prompt.Parent = part
  end

  -- Initialize crate as available
  lootedCrates[part] = false
  setCrateVisualState(part, false)

  part:FindFirstChild("LootCratePrompt").Triggered:Connect(function(player)
    if lootedCrates[part] then
      return -- Already looted today
    end

    local success = LootRegistry.tryLoot(player, part)
    if success then
      lootedCrates[part] = true
      setCrateVisualState(part, true)
    end
  end)
end

-- Reset all crates at the start of each day
Signals.DayStarted.Event:Connect(function()
  for crate, _ in pairs(lootedCrates) do
    lootedCrates[crate] = false
    setCrateVisualState(crate, false)
  end
  print("[Loot] All crates reset for new day")
end)

-- Tag crates in Studio with CollectionService Tag "LootCrate"
for _, part in ipairs(CollectionService:GetTagged(TAG)) do
  wireCrate(part)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(wireCrate)
