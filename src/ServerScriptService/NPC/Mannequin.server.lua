-- Mannequin.server.lua
-- Story 4: Basic enemy AI stub for testing barricades
-- REFACTORED: 0.8s attack cadence, SFX_EnemyHit, barricade targeting, heartbeat audio

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local Signals = require(ReplicatedStorage.Shared.Signals)
local AssetConfig = require(ReplicatedStorage.Shared.AssetConfig)

local activeEnemies = {}
local heartbeatSound = nil
local DAMAGE_AMOUNT = 1
local ATTACK_COOLDOWN = 0.8 -- Attack cadence per acceptance criteria
local SPAWN_TAG = "EnemySpawn"

local function createMannequin(spawnPoint)
  local mannequin = Instance.new("Model")
  mannequin.Name = "Mannequin"

  local torso = Instance.new("Part")
  torso.Name = "Torso"
  torso.Size = Vector3.new(2, 2, 1)
  torso.BrickColor = BrickColor.new("Dark stone grey")
  torso.Material = Enum.Material.Concrete
  torso.Position = spawnPoint.Position + Vector3.new(0, 3, 0)
  torso.Parent = mannequin

  local head = Instance.new("Part")
  head.Name = "Head"
  head.Size = Vector3.new(1, 1, 1)
  head.Shape = Enum.PartType.Ball
  head.BrickColor = BrickColor.new("White")
  head.Position = torso.Position + Vector3.new(0, 1.5, 0)
  head.Parent = mannequin

  local humanoid = Instance.new("Humanoid")
  humanoid.MaxHealth = 50
  humanoid.Health = 50
  humanoid.WalkSpeed = 8
  humanoid.Parent = mannequin

  -- Weld head to torso
  local weld = Instance.new("WeldConstraint")
  weld.Part0 = torso
  weld.Part1 = head
  weld.Parent = torso

  mannequin.PrimaryPart = torso
  mannequin.Parent = workspace

  return mannequin
end

local function findNearestBoard(fromPosition)
  -- Find nearest board to attack
  local nearestBoard = nil
  local minDist = math.huge

  for _, part in ipairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") and part.Name == "Board" and part.Parent then
      local dist = (part.Position - fromPosition).Magnitude
      if dist < minDist and dist < 50 then -- Within 50 studs
        minDist = dist
        nearestBoard = part
      end
    end
  end

  return nearestBoard
end

local function findTarget(mannequinPosition)
  -- Prioritize barricades over players (per acceptance criteria)
  local nearestBoard = findNearestBoard(mannequinPosition)
  if nearestBoard then
    return nearestBoard
  end

  -- If no boards, target nearest player
  local players = Players:GetPlayers()
  local nearestPlayer = nil
  local minDist = math.huge

  for _, player in ipairs(players) do
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
      local dist = (char.HumanoidRootPart.Position - mannequinPosition).Magnitude
      if dist < minDist then
        minDist = dist
        nearestPlayer = char.HumanoidRootPart
      end
    end
  end

  return nearestPlayer
end

local function playSFX_EnemyHit(board)
  -- Play enemy hit sound at -8 dB (ux-context.md)
  local sound = Instance.new("Sound")
  sound.Name = "SFX_EnemyHit"
  sound.SoundId = AssetConfig.Sounds.MannequinFootstep
  sound.Volume = 0.4 -- -8 dB approximately (louder than standard SFX)
  sound.Parent = board
  sound:Play()

  sound.Ended:Connect(function()
    sound:Destroy()
  end)
end

local function attackBoard(mannequin, board)
  if not board or not board.Parent then
    return
  end

  if _G.BarricadeSystem and _G.BarricadeSystem.damageBoard then
    _G.BarricadeSystem.damageBoard(board, DAMAGE_AMOUNT)

    local durability = board:FindFirstChild("Durability")
    if durability then
      print("[Mannequin] Damaged board, durability remaining:", durability.Value)
    end

    -- Play attack SFX
    playSFX_EnemyHit(board)
  end
end

local function behaviorLoop(mannequin)
  local humanoid = mannequin:FindFirstChild("Humanoid")
  local torso = mannequin:FindFirstChild("Torso")
  if not humanoid or not torso then
    mannequin:Destroy()
    return
  end

  local lastAttackTime = 0

  while mannequin.Parent and humanoid.Health > 0 do
    local target = findTarget(torso.Position)
    if target then
      -- Check if already in attack range
      local distanceToTarget = (target.Position - torso.Position).Magnitude

      if distanceToTarget <= 6 and target.Name == "Board" then
        -- Close enough to attack
        if os.clock() - lastAttackTime >= ATTACK_COOLDOWN then
          attackBoard(mannequin, target)
          lastAttackTime = os.clock()
        end
        task.wait(ATTACK_COOLDOWN) -- Wait for next attack
      else
        -- Pathfind toward target
        local path = PathfindingService:CreatePath({
          AgentRadius = 2,
          AgentHeight = 5,
          AgentCanJump = false,
        })
        local success, errorMsg = pcall(function()
          path:ComputeAsync(torso.Position, target.Position)
        end)

        if success and path.Status == Enum.PathStatus.Success then
          local waypoints = path:GetWaypoints()
          for i, waypoint in ipairs(waypoints) do
            if not mannequin.Parent or humanoid.Health <= 0 then
              return
            end

            -- Check for closer boards while moving
            local closerTarget = findTarget(torso.Position)
            if closerTarget and closerTarget ~= target then
              break -- Re-evaluate target
            end

            humanoid:MoveTo(waypoint.Position)

            -- Don't wait for full move completion, update more frequently
            local moveTimeout = 0
            repeat
              task.wait(0.1)
              moveTimeout = moveTimeout + 0.1

              -- Check if in attack range
              if closerTarget and closerTarget.Name == "Board" then
                local dist = (closerTarget.Position - torso.Position).Magnitude
                if dist <= 6 then
                  break
                end
              end
            until moveTimeout >= 3 or (torso.Position - waypoint.Position).Magnitude < 3
          end
        else
          -- Path failed, wait and retry
          task.wait(0.5)
        end
      end
    else
      -- No target found, wait
      task.wait(1)
    end

    task.wait(0.1) -- Small delay between behavior updates
  end

  -- Enemy died
  mannequin:Destroy()
end

local function spawnEnemies()
  local spawnPoints = CollectionService:GetTagged(SPAWN_TAG)
  if #spawnPoints == 0 then
    warn("[Mannequin] No spawn points tagged with 'EnemySpawn'")
    return
  end

  -- Spawn 2-3 enemies per night (simple stub)
  local spawnCount = math.random(2, 3)
  for i = 1, spawnCount do
    local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
    local mannequin = createMannequin(spawnPoint)
    table.insert(activeEnemies, mannequin)
    task.spawn(behaviorLoop, mannequin)
    print("[Mannequin] Spawned enemy #" .. i)
  end
end

local function despawnAllEnemies()
  for _, enemy in ipairs(activeEnemies) do
    if enemy and enemy.Parent then
      enemy:Destroy()
    end
  end
  activeEnemies = {}
  print("[Mannequin] All enemies despawned for day")
end

local function createHeartbeatSound()
  -- Create global heartbeat loop sound (ux-context.md: heartbeat loop volume 0→0.4 over 3s)
  local sound = Instance.new("Sound")
  sound.Name = "HeartbeatLoop"
  sound.SoundId = AssetConfig.Sounds.MannequinHeartbeat
  sound.Volume = 0
  sound.Looped = true
  sound.Parent = workspace
  return sound
end

local function startHeartbeatLoop()
  if not heartbeatSound then
    heartbeatSound = createHeartbeatSound()
  end

  heartbeatSound:Play()

  -- Ramp volume from 0 to 0.4 over 3 seconds
  local startTime = os.clock()
  local duration = 3
  local targetVolume = 0.4

  task.spawn(function()
    while heartbeatSound and heartbeatSound.Playing and os.clock() - startTime < duration do
      local elapsed = os.clock() - startTime
      local progress = math.min(elapsed / duration, 1)
      heartbeatSound.Volume = progress * targetVolume
      task.wait(0.1)
    end
    if heartbeatSound then
      heartbeatSound.Volume = targetVolume
    end
  end)

  print("[Mannequin] Heartbeat loop started, ramping to volume 0.4")
end

local function stopHeartbeatLoop()
  if heartbeatSound and heartbeatSound.Playing then
    -- Fade volume to 0
    local startVolume = heartbeatSound.Volume
    local fadeTime = 1
    local startTime = os.clock()

    task.spawn(function()
      while heartbeatSound and os.clock() - startTime < fadeTime do
        local elapsed = os.clock() - startTime
        local progress = math.min(elapsed / fadeTime, 1)
        heartbeatSound.Volume = startVolume * (1 - progress)
        task.wait(0.1)
      end
      if heartbeatSound then
        heartbeatSound.Volume = 0
        heartbeatSound:Stop()
      end
    end)

    print("[Mannequin] Heartbeat loop stopping, fading to volume 0")
  end
end

-- Spawn enemies when night starts
Signals.NightStarted.Event:Connect(function(nightCount)
  print("[Mannequin] Night " .. nightCount .. " - spawning enemies")
  spawnEnemies()
  startHeartbeatLoop()
end)

-- Despawn enemies when day starts
Signals.DayStarted.Event:Connect(function()
  print("[Mannequin] Day started - despawning enemies")
  despawnAllEnemies()
  stopHeartbeatLoop()
end)
