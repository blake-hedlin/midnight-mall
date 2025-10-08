-- Currency.lua
-- Sprint 1, Story 10: Soft currency scaffolding
-- Provides data structure and API for future economy integration

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signals = require(ReplicatedStorage.Shared.Signals)

local Currency = {}
Currency._playerCoins = {} -- [userId] = coinAmount

-- Initialize currency for a player
function Currency.initPlayer(player)
  if not player or not player.UserId then
    return
  end

  local userId = tostring(player.UserId)
  Currency._playerCoins[userId] = Currency._playerCoins[userId] or 0

  -- Create IntValue under player for replication
  local coinsValue = player:FindFirstChild("Coins")
  if not coinsValue then
    coinsValue = Instance.new("IntValue")
    coinsValue.Name = "Coins"
    coinsValue.Value = Currency._playerCoins[userId]
    coinsValue.Parent = player
  end

  return Currency._playerCoins[userId]
end

-- Get player's current coin balance
function Currency.getCoins(player)
  if not player or not player.UserId then
    return 0
  end
  return Currency._playerCoins[tostring(player.UserId)] or 0
end

-- Add coins to player (Sprint 2: integrate with round rewards)
function Currency.addCoins(player, amount)
  if not player or not player.UserId or amount <= 0 then
    return
  end

  local userId = tostring(player.UserId)
  Currency._playerCoins[userId] = (Currency._playerCoins[userId] or 0) + amount

  -- Update replicated value
  local coinsValue = player:FindFirstChild("Coins")
  if coinsValue then
    coinsValue.Value = Currency._playerCoins[userId]
  end

  -- Fire signal for HUD update
  Signals.InventoryChanged:FireClient(player, "coins", Currency._playerCoins[userId])
end

-- Remove coins from player (Sprint 2: integrate with shop purchases)
function Currency.removeCoins(player, amount)
  if not player or not player.UserId or amount <= 0 then
    return false
  end

  local userId = tostring(player.UserId)
  local current = Currency._playerCoins[userId] or 0

  if current < amount then
    return false -- Insufficient funds
  end

  Currency._playerCoins[userId] = current - amount

  -- Update replicated value
  local coinsValue = player:FindFirstChild("Coins")
  if coinsValue then
    coinsValue.Value = Currency._playerCoins[userId]
  end

  return true
end

-- Save/Load integration placeholder (Sprint 2: DataStore)
function Currency.saveCoins(_player)
  -- TODO: Implement DataStore save
end

function Currency.loadCoins(_player)
  -- TODO: Implement DataStore load
  return 0
end

-- Initialize currency for all players
Players.PlayerAdded:Connect(function(player)
  Currency.initPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
  Currency.saveCoins(player)
end)

return Currency
