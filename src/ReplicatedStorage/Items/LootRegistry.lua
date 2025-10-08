-- LootRegistry.lua
-- Weighted loot and a simple once-per-day lockout

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signals = require(ReplicatedStorage.Shared.Signals)

local LootRegistry = {}
LootRegistry._lootedToday = {} -- [player.UserId] = count

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
    return
  end
  local uid = tostring(player.UserId)
  LootRegistry._lootedToday[uid] = LootRegistry._lootedToday[uid] or 0
  if LootRegistry._lootedToday[uid] >= 3 then
    Signals.Looted:FireClient(player, false, "You already looted enough today.")
    return
  end

  local entry = tableUtil.weightedChoice(LootRegistry.Entries)
  giveItem(player, entry.id, entry.amount)
  LootRegistry._lootedToday[uid] += 1
  Signals.Looted:FireClient(player, true, "Found " .. entry.id)
end

Players.PlayerAdded:Connect(function(player)
  LootRegistry._lootedToday[tostring(player.UserId)] = 0
end)

-- Reset loot counts at the start of each day
Signals.DayStarted.Event:Connect(function()
  LootRegistry._lootedToday = {}
  print("[LootRegistry] Loot counts reset for new day")
end)

return LootRegistry
