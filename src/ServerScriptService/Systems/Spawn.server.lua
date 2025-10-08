-- Spawn.server.lua
-- Sprint 1, Story 6: Player spawn and respawn logic
-- Players spawn at random AtriumSpawn locations
-- On death during Night, queue respawn for next DayStart

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signals = require(ReplicatedStorage.Shared.Signals)

local ATRIUM_SPAWN_FOLDER = "AtriumSpawns" -- TODO: Create workspace/AtriumSpawns folder with SpawnLocation parts

local respawnQueue = {} -- [userId] = true for players waiting to respawn

local function getRandomSpawnLocation()
  local spawnFolder = workspace:FindFirstChild(ATRIUM_SPAWN_FOLDER)
  if not spawnFolder then
    warn("[Spawn] Missing workspace/" .. ATRIUM_SPAWN_FOLDER .. " folder")
    return workspace:FindFirstChildOfClass("SpawnLocation") -- Fallback to default spawn
  end

  local spawns = spawnFolder:GetChildren()
  if #spawns == 0 then
    warn("[Spawn] No spawn locations in " .. ATRIUM_SPAWN_FOLDER)
    return nil
  end

  return spawns[math.random(1, #spawns)]
end

local function spawnPlayer(player)
  local character = player.Character or player.CharacterAdded:Wait()
  local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

  if not humanoidRootPart then
    return
  end

  local spawnLocation = getRandomSpawnLocation()
  if spawnLocation then
    humanoidRootPart.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
  end

  -- Clear respawn queue
  respawnQueue[player.UserId] = nil
end

local function resetPlayerInventory(player)
  local inventory = player:FindFirstChild("Inventory")
  if inventory then
    inventory:Destroy()
  end
end

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
  player.CharacterAdded:Connect(function(character)
    spawnPlayer(player)

    -- Handle death
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
      respawnQueue[player.UserId] = true
      resetPlayerInventory(player)
    end)
  end)
end)

-- Respawn queued players at DayStart with 5-second delay
Signals.DayStarted.Event:Connect(function()
  local queueCount = 0
  for userId, _ in pairs(respawnQueue) do
    queueCount += 1
  end

  if queueCount > 0 then
    print("[Spawn] Day started, respawning " .. queueCount .. " queued players in 5 seconds")
    task.wait(5) -- 5-second delay as per acceptance criteria

    for userId, _ in pairs(respawnQueue) do
      local player = Players:GetPlayerByUserId(userId)
      if player then
        player:LoadCharacter()
        print("[Spawn] Respawned player:", player.Name)
      end
    end

    respawnQueue = {}
  end
end)
