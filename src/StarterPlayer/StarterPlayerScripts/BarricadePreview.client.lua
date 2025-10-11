-- BarricadePreview.client.lua
-- Story 3: Ghost preview system for barricade placement
-- REFACTORED: ForceField material, improved visual feedback

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Signals = require(ReplicatedStorage.Shared.Signals)
local player = Players.LocalPlayer

local ghostPreview = nil
local currentAnchor = nil
local previewActive = false

local PREVIEW_KEY = Enum.KeyCode.B -- Press B to toggle preview mode

local function createGhostPart()
	-- Ghost material = ForceField per ux-context.md checklist
	local ghost = Instance.new("Part")
	ghost.Name = "BarricadeGhost"
	ghost.Size = Vector3.new(6, 6, 0.5)
	ghost.Anchored = true
	ghost.CanCollide = false
	ghost.Transparency = 0.5
	ghost.Material = Enum.Material.ForceField
	ghost.Parent = workspace
	return ghost
end

local function findNearestAnchor()
	local character = player.Character
	if not character then
		return nil
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return nil
	end

	local anchors = CollectionService:GetTagged("BarricadeAnchor")
	local nearest = nil
	local minDist = 15 -- Max interaction distance

	for _, anchor in ipairs(anchors) do
		local dist = (anchor.Position - rootPart.Position).Magnitude
		if dist < minDist then
			minDist = dist
			nearest = anchor
		end
	end

	return nearest
end

local function isValidPlacement(anchor)
	-- Simple client-side check (server will validate authoritatively)
	if not anchor then
		return false
	end
	-- Check if anchor already has a board child
	if anchor:FindFirstChild("Board") then
		return false
	end
	return true
end

local function updateGhostPreview()
	if not previewActive or not ghostPreview then
		return
	end

	currentAnchor = findNearestAnchor()

	if currentAnchor then
		ghostPreview.CFrame = currentAnchor.CFrame
		local valid = isValidPlacement(currentAnchor)
		if valid then
			ghostPreview.Color = Color3.fromRGB(0, 255, 0) -- Green = valid
		else
			ghostPreview.Color = Color3.fromRGB(255, 0, 0) -- Red = invalid
		end
		ghostPreview.Transparency = 0.5
	else
		ghostPreview.Transparency = 1 -- Hide if no anchor nearby
	end
end

local function togglePreviewMode()
	previewActive = not previewActive

	if previewActive then
		if not ghostPreview then
			ghostPreview = createGhostPart()
		end
		print("[BarricadePreview] Preview mode ON")
	else
		if ghostPreview then
			ghostPreview:Destroy()
			ghostPreview = nil
		end
		currentAnchor = nil
		print("[BarricadePreview] Preview mode OFF")
	end
end

local function requestPlacement()
	if not previewActive or not currentAnchor then
		return
	end

	if isValidPlacement(currentAnchor) then
		Signals.PlaceBarricade:FireServer(currentAnchor)
		print("[BarricadePreview] Placement requested")
	else
		warn("[BarricadePreview] Invalid placement")
	end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == PREVIEW_KEY then
		togglePreviewMode()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 and previewActive then
		requestPlacement()
	end
end)

-- Update ghost position every frame when active
RunService.RenderStepped:Connect(updateGhostPreview)

-- Listen for successful placement to toggle off preview
Signals.BarricadePlaced.OnClientEvent:Connect(function(success, message)
	if success and previewActive then
		togglePreviewMode() -- Auto-exit preview mode after placing
	end
	print("[BarricadePreview]", message)
end)
