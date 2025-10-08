-- Barricade.server.lua
-- Place basic Boards on anchors during the Day

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Signals = require(ReplicatedStorage.Shared.Signals)

local TAG = "BarricadeAnchor"

local function ensureInventory(player)
    local inv = player:FindFirstChild("Inventory")
    if not inv then
        inv = Instance.new("Folder")
        inv.Name = "Inventory"
        inv.Parent = player
    end
    local wood = inv:FindFirstChild("wood")
    if not wood then
        wood = Instance.new("IntValue")
        wood.Name = "wood"
        wood.Value = 0
        wood.Parent = inv
    end
    return inv, wood
end

local function placeBoard(anchor, player)
    local inv, wood = ensureInventory(player)
    if wood.Value <= 0 then
        Signals.Looted:FireClient(player, false, "No wood to barricade.")
        return
    end
    wood.Value -= 1
    Signals.InventoryChanged:FireClient(player, "wood", wood.Value)

    local board = Instance.new("Part")
    board.Name = "Board"
    board.Size = Vector3.new(4, 0.2, 0.5)
    board.Anchored = true
    board.CanCollide = false
    board.CFrame = anchor.CFrame
    board.Parent = anchor

    local durability = Instance.new("IntValue")
    durability.Name = "Durability"
    durability.Value = 50
    durability.Parent = board
end

-- Simple server-side binding:
-- Add a ProximityPrompt to each anchor, Action "Barricade"
local function setupAnchor(anchor)
    local prompt = anchor:FindFirstChildWhichIsA("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Barricade"
        prompt.ObjectText = "Doorway"
        prompt.HoldDuration = 0.5
        prompt.Parent = anchor
    end
    prompt.Triggered:Connect(function(player)
        placeBoard(anchor, player)
    end)
end

for _, inst in ipairs(CollectionService:GetTagged(TAG)) do
    setupAnchor(inst)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(setupAnchor)
