-- Barricade.server.lua
-- Story 3: Ghost preview placement and board durability system
-- REFACTORED: Snap animation, SFX, particle burst on break, durability display

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local Signals = require(ReplicatedStorage.Shared.Signals)

local TAG = "BarricadeAnchor"
local anchorBoards = {} -- [anchor] = board reference

-- Tween constant from ux-context.md
local TWEEN_FEEDBACK = 0.2 -- Snap animation duration per acceptance criteria

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

local function createDurabilityDisplay(board, currentDurability, maxDurability)
	-- Create billboard GUI to show durability
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DurabilityDisplay"
	billboard.Size = UDim2.new(4, 0, 1, 0)
	billboard.StudsOffset = Vector3.new(0, 1, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = board

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0.15, 0)
	frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame.BorderSizePixel = 0
	frame.Parent = billboard

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(currentDurability / maxDurability, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown for wood
	fill.BorderSizePixel = 0
	fill.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = string.format("HP: %d/%d", currentDurability, maxDurability)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame

	return billboard
end

local function updateDurabilityDisplay(board, currentDurability, maxDurability)
	local display = board:FindFirstChild("DurabilityDisplay")
	if not display then return end

	local frame = display:FindFirstChild("Frame")
	if not frame then return end

	local fill = frame:FindFirstChild("Fill")
	local label = frame:FindFirstChild("Label")

	if fill and label then
		local ratio = currentDurability / maxDurability
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		label.Text = string.format("HP: %d/%d", currentDurability, maxDurability)

		-- Color feedback: brown -> yellow -> red as damage increases
		if ratio > 0.66 then
			fill.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown
		elseif ratio > 0.33 then
			fill.BackgroundColor3 = Color3.fromRGB(200, 150, 50) -- Yellow
		else
			fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
		end
	end
end

local function playSFX_BoardPlace(board)
	-- Play board placement sound at -8 dB (ux-context.md)
	local sound = Instance.new("Sound")
	sound.Name = "SFX_BoardPlace"
	sound.SoundId = "rbxasset://sounds/impact_wood_hollow_03.wav"
	sound.Volume = 0.4 -- -8 dB approximately
	sound.Parent = board
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function createBreakParticles(board)
	-- Particle burst on board break
	local particle = Instance.new("ParticleEmitter")
	particle.Name = "BreakBurst"
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 0
	particle.Lifetime = NumberRange.new(0.3, 0.6)
	particle.Speed = NumberRange.new(5, 10)
	particle.SpreadAngle = Vector2.new(180, 180)
	particle.Color = ColorSequence.new(Color3.fromRGB(139, 69, 19))
	particle.Size = NumberSequence.new(0.5, 1)
	particle.Transparency = NumberSequence.new(0, 1)
	particle.Parent = board
	return particle
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

	-- Create board
	local board = Instance.new("Part")
	board.Name = "Board"
	board.Size = Vector3.new(6, 6, 0.5)
	board.Anchored = true
	board.CanCollide = true
	board.BrickColor = BrickColor.new("Brown")
	board.Material = Enum.Material.Wood
	board.CFrame = anchor.CFrame
	board.Parent = workspace

	-- Set durability (3-5 range)
	local maxDurability = math.random(3, 5)
	local durability = Instance.new("IntValue")
	durability.Name = "Durability"
	durability.Value = maxDurability
	durability.Parent = board

	local maxDurabilityValue = Instance.new("IntValue")
	maxDurabilityValue.Name = "MaxDurability"
	maxDurabilityValue.Value = maxDurability
	maxDurabilityValue.Parent = board

	-- Create particles for breaking effect
	local particles = createBreakParticles(board)

	-- Create durability display
	createDurabilityDisplay(board, maxDurability, maxDurability)

	-- Play snap animation (0.2s TWEEN_FEEDBACK)
	local startCFrame = anchor.CFrame * CFrame.new(0, 2, 0)
	board.CFrame = startCFrame

	local tweenInfo = TweenInfo.new(TWEEN_FEEDBACK, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(board, tweenInfo, { CFrame = anchor.CFrame })
	tween:Play()

	-- Play placement sound
	playSFX_BoardPlace(board)

	anchorBoards[anchor] = board

	-- Remove board when durability reaches 0
	durability.Changed:Connect(function(newValue)
		print("[Barricade] Board durability:", newValue)

		-- Update display
		updateDurabilityDisplay(board, newValue, maxDurability)

		if newValue <= 0 then
			-- Emit particle burst
			if particles then
				particles:Emit(30)
			end

			-- Delay destruction to allow particles to show
			task.delay(0.5, function()
				board:Destroy()
			end)

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
	local maxDurabilityValue = board:FindFirstChild("MaxDurability")
	local maxDurability = maxDurabilityValue and maxDurabilityValue.Value or 5

	if durability then
		-- Increase durability by 1 up to max (per acceptance criteria)
		durability.Value = math.min(durability.Value + 1, maxDurability)
		print("[Barricade] Board repaired to durability:", durability.Value)

		-- Update display
		updateDurabilityDisplay(board, durability.Value, maxDurability)
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
