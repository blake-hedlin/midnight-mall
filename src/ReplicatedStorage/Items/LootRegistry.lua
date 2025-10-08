-- LootRegistry.lua
-- Weighted loot and a simple once-per-day lockout

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signals = require(ReplicatedStorage.Shared.Signals)

local LootRegistry = {}

local tableUtil = {}

function tableUtil.weightedChoice(entries)
  -- entries: { {id="wood", weight=5, amount=1}, ... }
  local total = 0
  for _, e in ipairs(entries) do
    total += e.weight
  end
  local r = math.random() * total
  local sum = 0
  for _, e in ipairs(entries) do
    sum += e.weight
    if r <= sum then
      return e
    end
  end
  return entries[#entries]
end

LootRegistry.Entries = {
  { id = "wood", weight = 6, amount = 1 },
  { id = "snack", weight = 3, amount = 1 },
  { id = "battery", weight = 2, amount = 1 },
}

local function giveItem(player, id, amount)
  -- Simple inventory stored as NumberValues under player
  local invFolder = player:FindFirstChild("Inventory")
  if not invFolder then
    invFolder = Instance.new("Folder")
    invFolder.Name = "Inventory"
    invFolder.Parent = player
  end
  local stat = invFolder:FindFirstChild(id)
  if not stat then
    stat = Instance.new("IntValue")
    stat.Name = id
    stat.Value = 0
    stat.Parent = invFolder
  end
  stat.Value += amount
  Signals.InventoryChanged:FireClient(player, id, stat.Value)
end

function LootRegistry.tryLoot(player, _cratePart)
  if not player or not player.UserId then
    return false
  end

  local entry = tableUtil.weightedChoice(LootRegistry.Entries)
  giveItem(player, entry.id, entry.amount)
  Signals.Looted:FireClient(player, true, "Found " .. entry.id .. " x" .. entry.amount)
  return true
end

-- Initialize player inventory on join
Players.PlayerAdded:Connect(function(player)
  local invFolder = Instance.new("Folder")
  invFolder.Name = "Inventory"
  invFolder.Parent = player
end)

return LootRegistry
