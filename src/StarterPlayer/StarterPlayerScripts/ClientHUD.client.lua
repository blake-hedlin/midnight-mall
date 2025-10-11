-- ClientHUD.client.lua
-- Sprint 1, Story 5: Enhanced HUD with inventory icons and transition banner
-- Authoritative source: /docs/design_notes/ux-context.md

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Signals = require(ReplicatedStorage.Shared.Signals)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- UX Context tokens
local TWEEN_UI = 0.3 -- seconds (banner slide in)
local TWEEN_FEEDBACK = 0.15 -- seconds (inventory count updates)
local BANNER_FADE_OUT = 1.0 -- seconds
local HUD_SAFE_MARGIN = 32 -- px
local GRID_BASE = 8 -- px
local FS_MD = 18 -- font size medium
local FS_LG = 24 -- font size large

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Time Display (top-right per HUD_Root specification)
local timeFrame = Instance.new("Frame")
timeFrame.Name = "TimeFrame"
timeFrame.Size = UDim2.new(0, 250, 0, 40)
timeFrame.AnchorPoint = Vector2.new(1, 0)
timeFrame.Position = UDim2.new(1, -HUD_SAFE_MARGIN, 0, HUD_SAFE_MARGIN)
timeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
timeFrame.BackgroundTransparency = 0.2
timeFrame.BorderSizePixel = 0
timeFrame.Parent = screenGui

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Size = UDim2.new(1, 0, 1, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.TextSize = FS_MD
timeLabel.Font = Enum.Font.GothamSemibold -- Font_Primary per ux-context
timeLabel.Text = "Day 1 — 120s"
timeLabel.Parent = timeFrame

-- Inventory Display (bottom-left per HUD_Root specification)
local invFrame = Instance.new("Frame")
invFrame.Name = "InventoryFrame"
invFrame.Size = UDim2.new(0, 250, 0, 105)
invFrame.AnchorPoint = Vector2.new(0, 1)
invFrame.Position = UDim2.new(0, HUD_SAFE_MARGIN, 1, -HUD_SAFE_MARGIN)
invFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
invFrame.BackgroundTransparency = 0.2
invFrame.BorderSizePixel = 0
invFrame.Parent = screenGui

local inventory = { wood = 0, snack = 0, battery = 0, coins = 0 }

-- Item icons with labels (using 8px grid spacing)
local itemConfigs = {
	{ name = "wood", emoji = "🪵", label = "Wood" },
	{ name = "snack", emoji = "🍫", label = "Snack" },
	{ name = "battery", emoji = "🔋", label = "Battery" },
	{ name = "coins", emoji = "🪙", label = "Coins" },
}

-- Build lookup table for O(1) access during inventory updates
local itemConfigLookup = {}
for _, config in ipairs(itemConfigs) do
	itemConfigLookup[config.name] = config
end

local itemLabels = {}

for i, config in ipairs(itemConfigs) do
	local itemLabel = Instance.new("TextLabel")
	itemLabel.Name = config.name .. "Label"
	itemLabel.Size = UDim2.new(1, -(GRID_BASE * 2), 0, 22)
	itemLabel.Position = UDim2.new(0, GRID_BASE, 0, (i - 1) * (22 + GRID_BASE / 2) + GRID_BASE)
	itemLabel.BackgroundTransparency = 1
	itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemLabel.TextSize = FS_MD
	itemLabel.Font = Enum.Font.GothamSemibold -- Font_Primary per ux-context
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.Text = config.emoji .. " " .. config.label .. ": 0"
	itemLabel.Parent = invFrame
	itemLabels[config.name] = itemLabel
end

-- Transition Banner (full-width top banner per UI_Banner specification)
local banner = Instance.new("Frame")
banner.Name = "TransitionBanner"
banner.Size = UDim2.new(1, 0, 0, 80)
banner.Position = UDim2.new(0, 0, 0, -80) -- Start off-screen at top
banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
banner.BackgroundTransparency = 0.3
banner.BorderSizePixel = 0
banner.ZIndex = 10
banner.Parent = screenGui

local bannerText = Instance.new("TextLabel")
bannerText.Name = "BannerText"
bannerText.Size = UDim2.new(1, 0, 1, 0)
bannerText.BackgroundTransparency = 1
bannerText.TextColor3 = Color3.fromRGB(255, 255, 255)
bannerText.TextSize = FS_LG
bannerText.Font = Enum.Font.GothamSemibold -- Font_Primary per ux-context
bannerText.Text = ""
bannerText.Parent = banner

-- Track active banner tweens to prevent animation conflicts
local activeBannerTweens = {}

local function showBanner(text, color)
	-- Cancel any active tweens to prevent rapid-fire banner conflicts
	for _, tween in ipairs(activeBannerTweens) do
		tween:Cancel()
	end
	activeBannerTweens = {}
	bannerText.Text = text
	bannerText.TextColor3 = color or Color3.fromRGB(255, 255, 255)

	-- Slide in (0.3s per TWEEN_UI)
	local slideIn = TweenService:Create(
		banner,
		TweenInfo.new(TWEEN_UI, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ Position = UDim2.new(0, 0, 0, 0) }
	)

	-- Fade out (1.0s per ux-context)
	local fadeOut = TweenService:Create(
		banner,
		TweenInfo.new(BANNER_FADE_OUT, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ BackgroundTransparency = 1 }
	)

	local textFadeOut = TweenService:Create(
		bannerText,
		TweenInfo.new(BANNER_FADE_OUT, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ TextTransparency = 1 }
	)

	-- Reset to start position
	banner.Position = UDim2.new(0, 0, 0, -80)
	banner.BackgroundTransparency = 0.3
	bannerText.TextTransparency = 0

	-- Track tweens for cancellation
	table.insert(activeBannerTweens, slideIn)
	table.insert(activeBannerTweens, fadeOut)
	table.insert(activeBannerTweens, textFadeOut)

	-- Play slide in
	slideIn:Play()
	slideIn.Completed:Wait()

	-- Hold for 1.5 seconds
	task.wait(1.5)

	-- Fade out
	fadeOut:Play()
	textFadeOut:Play()
end

local function updateInventoryDisplay(itemName)
	-- Update specific item or all items
	local itemsToUpdate = itemName and { itemName } or { "wood", "snack", "battery", "coins" }

	for _, name in ipairs(itemsToUpdate) do
		local count = inventory[name] or 0
		local label = itemLabels[name]
		local config = itemConfigLookup[name] -- O(1) lookup instead of O(n) search

		if label and config then
			-- Animate count update with 0.15s tick (TWEEN_FEEDBACK)
			label.TextSize = FS_MD * 1.2 -- Slight scale up

			local scaleDown = TweenService:Create(
				label,
				TweenInfo.new(TWEEN_FEEDBACK, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ TextSize = FS_MD }
			)

			label.Text = config.emoji .. " " .. config.label .. ": " .. count
			scaleDown:Play()
		end
	end
end

-- Listen for inventory updates
Signals.InventoryChanged.OnClientEvent:Connect(function(id, value)
	inventory[id] = value
	updateInventoryDisplay(id)
end)

-- Listen for time updates
Signals.StateTick.OnClientEvent:Connect(function(state, time, nightCount)
	if state == "Day" then
		timeLabel.Text = ("Day %d — %ds left"):format(nightCount + 1, math.max(0, 120 - math.floor(time)))
		timeFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255) -- Blue for day
	else
		timeLabel.Text = ("Night %d — %ds left"):format(nightCount, math.max(0, 60 - math.floor(time)))
		timeFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 60) -- Purple for night
	end
end)

-- Listen for state changes to show banner
-- Colorblind-safe colors per ux-context accessibility guidelines
local BANNER_COLORS = {
	["Night Falling"] = Color3.fromRGB(255, 100, 100), -- Red tint for night (colorblind-safe)
	["Dawn Breaking"] = Color3.fromRGB(100, 180, 255), -- Blue tint for dawn (colorblind-safe)
	["Day"] = Color3.fromRGB(255, 220, 100), -- Yellow for day
	["Night"] = Color3.fromRGB(255, 100, 100), -- Red for night
}

Signals.StateChanged.OnClientEvent:Connect(function(newState)
	-- Support both old format (Day/Night) and new custom text format (Night Falling/Dawn Breaking)
	local bannerColor = BANNER_COLORS[newState] or Color3.fromRGB(255, 255, 255)

	if newState == "Day" then
		task.spawn(showBanner, "☀️ DAY BREAK ☀️", BANNER_COLORS["Day"])
	elseif newState == "Night" then
		task.spawn(showBanner, "🌙 NIGHT FALLS 🌙", BANNER_COLORS["Night"])
	elseif newState == "Night Falling" or newState == "Dawn Breaking" then
		-- Custom text from LightingController
		task.spawn(showBanner, newState, bannerColor)
	end
end)

-- Feedback for loot/barricade actions
Signals.Looted.OnClientEvent:Connect(function(_ok, msg)
	if not msg then
		return
	end
	-- Briefly show message in time label
	local originalText = timeLabel.Text
	timeLabel.Text = msg
	task.delay(1.5, function()
		timeLabel.Text = originalText
	end)
end)
