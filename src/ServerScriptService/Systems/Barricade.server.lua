-- Barricade.server.lua
-- Ghost preview placement and board durability system

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Signals = require(ReplicatedStorage.Shared.Signals)

local TAG = "BarricadeAnchor"
local anchorBoards = {} -- [anchor] = board reference

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

local function isValidPlacement(anchor)
  -- Check if anchor already has a board
  if anchorBoards[anchor] and anchorBoards[anchor].Parent then
    return false, "Already barricaded"
  end

  -- Check for overlapping parts
  local testRegion = Region3.new(
    anchor.Position - Vector3.new(2, 2, 0.5),
    anchor.Position + Vector3.new(2, 2, 0.5)
  )
  local parts = workspace:FindPartsInRegion3(testRegion, nil, 100)
  for _, part in ipairs(parts) do
    if part ~= anchor and part.CanCollide then
      return false, "Blocked by obstacle"
    end
  end

  return true, "Valid"
end

local function placeBoard(anchor, player)
  local _, wood = ensureInventory(player)
  if wood.Value <= 0 then
    Signals.Looted:FireClient(player, false, "Need 1 wood to barricade")
    return false
  end

  local valid, reason = isValidPlacement(anchor)
  if not valid then
    Signals.Looted:FireClient(player, false, reason)
    return false
  end

  wood.Value -= 1
  Signals.InventoryChanged:FireClient(player, "wood", wood.Value)

  local board = Instance.new("Part")
  board.Name = "Board"
  board.Size = Vector3.new(4, 0.2, 0.5)
  board.Anchored = true
  board.CanCollide = true
  board.BrickColor = BrickColor.new("Brown")
  board.Material = Enum.Material.Wood
  board.CFrame = anchor.CFrame
  board.Parent = workspace

  local durability = Instance.new("IntValue")
  durability.Name = "Durability"
  durability.Value = math.random(3, 5) -- 3-5 hits as per acceptance criteria
  durability.Parent = board

  anchorBoards[anchor] = board

  -- Remove board when durability reaches 0
  durability.Changed:Connect(function(newValue)
    print("[Barricade] Board durability:", newValue)
    if newValue <= 0 then
      board:Destroy()
      anchorBoards[anchor] = nil
      print("[Barricade] Board destroyed at anchor")
    end
  end)

  Signals.BarricadePlaced:FireClient(player, true, "Barricade placed")
  return true
end

local function repairBoard(anchor, player)
  local board = anchorBoards[anchor]
  if not board or not board.Parent then
    Signals.Looted:FireClient(player, false, "No board to repair")
    return false
  end

  local _, wood = ensureInventory(player)
  if wood.Value <= 0 then
    Signals.Looted:FireClient(player, false, "Need 1 wood to repair")
    return false
  end

  wood.Value -= 1
  Signals.InventoryChanged:FireClient(player, "wood", wood.Value)

  local durability = board:FindFirstChild("Durability")
  if durability then
    durability.Value = math.min(durability.Value + 3, 5) -- Restore up to 3 hits, max 5
    print("[Barricade] Board repaired to durability:", durability.Value)
  end

  Signals.Looted:FireClient(player, true, "Board repaired")
  return true
end

-- Handle client placement requests
Signals.PlaceBarricade.OnServerEvent:Connect(function(player, anchor)
  if not anchor or not anchor:IsA("BasePart") then
    return
  end
  if not CollectionService:HasTag(anchor, TAG) then
    return
  end
  placeBoard(anchor, player)
end)

-- Handle client repair requests
Signals.RepairBarricade.OnServerEvent:Connect(function(player, anchor)
  if not anchor or not anchor:IsA("BasePart") then
    return
  end
  if not CollectionService:HasTag(anchor, TAG) then
    return
  end
  repairBoard(anchor, player)
end)

-- Setup ProximityPrompts for quick placement (fallback UI)
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

-- Expose damage function for enemy AI
function damageBoard(board, damageAmount)
  local durability = board:FindFirstChild("Durability")
  if durability then
    durability.Value -= damageAmount
  end
end

_G.BarricadeSystem = {
  damageBoard = damageBoard,
}
