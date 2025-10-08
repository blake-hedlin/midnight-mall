-- Loot.server.lua
-- Connect ProximityPrompts named 'LootCratePrompt' to LootRegistry

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Signals = require(ReplicatedStorage.Shared.Signals)
local LootRegistry = require(ReplicatedStorage.Items.LootRegistry)

local TAG = "LootCrate"

local function wireCrate(part)
    if not part:FindFirstChildWhichIsA("ProximityPrompt") then
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "LootCratePrompt"
        prompt.ActionText = "Loot"
        prompt.ObjectText = "Crate"
        prompt.HoldDuration = 0.5
        prompt.Parent = part
    end
    part.Looted = false
    part:FindFirstChild("LootCratePrompt").Triggered:Connect(function(player)
        if part.Looted then
            return
        end
        LootRegistry.tryLoot(player, part)
        part.Looted = true
        task.delay(5, function()
            part.Looted = false
        end)
    end)
end

-- Tag crates in Studio with CollectionService Tag "LootCrate"
for _, part in ipairs(CollectionService:GetTagged(TAG)) do
    wireCrate(part)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(wireCrate)
