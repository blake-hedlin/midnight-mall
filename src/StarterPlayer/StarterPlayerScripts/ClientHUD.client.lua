-- ClientHUD.client.lua
-- Enhanced HUD with inventory icons and transition banner

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Signals = require(ReplicatedStorage.Shared.Signals)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Time Display (top-left)
local timeFrame = Instance.new("Frame")
timeFrame.Name = "TimeFrame"
timeFrame.Size = UDim2.new(0, 250, 0, 40)
timeFrame.Position = UDim2.new(0, 15, 0, 15)
timeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
timeFrame.BackgroundTransparency = 0.2
timeFrame.BorderSizePixel = 0
timeFrame.Parent = screenGui

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimeLabel"
timeLabel.Size = UDim2.new(1, 0, 1, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeLabel.TextSize = 20
timeLabel.Font = Enum.Font.GothamBold
timeLabel.Text = "Day 1 — 120s"
timeLabel.Parent = timeFrame

-- Inventory Display (top-left, below time)
local invFrame = Instance.new("Frame")
invFrame.Name = "InventoryFrame"
invFrame.Size = UDim2.new(0, 250, 0, 105)
invFrame.Position = UDim2.new(0, 15, 0, 65)
invFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
invFrame.BackgroundTransparency = 0.2
invFrame.BorderSizePixel = 0
invFrame.Parent = screenGui

local inventory = { wood = 0, snack = 0, battery = 0, coins = 0 }

-- Item icons with labels
local itemConfigs = {
	{ name = "wood", emoji = "🪵", label = "Wood" },
	{ name = "snack", emoji = "🍫", label = "Snack" },
	{ name = "battery", emoji = "🔋", label = "Battery" },
	{ name = "coins", emoji = "🪙", label = "Coins" },
}

local itemLabels = {}

for i, config in ipairs(itemConfigs) do
	local itemLabel = Instance.new("TextLabel")
	itemLabel.Name = config.name .. "Label"
	itemLabel.Size = UDim2.new(1, -20, 0, 22)
	itemLabel.Position = UDim2.new(0, 10, 0, (i - 1) * 26 + 5)
	itemLabel.BackgroundTransparency = 1
	itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemLabel.TextSize = 16
	itemLabel.Font = Enum.Font.Gotham
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.Text = config.emoji .. " " .. config.label .. ": 0"
	itemLabel.Parent = invFrame
	itemLabels[config.name] = itemLabel
end

-- Transition Banner (center screen)
local banner = Instance.new("Frame")
banner.Name = "TransitionBanner"
banner.Size = UDim2.new(0, 600, 0, 100)
banner.Position = UDim2.new(0.5, -300, 0.5, -50)
banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
banner.BackgroundTransparency = 1
banner.BorderSizePixel = 0
banner.ZIndex = 10
banner.Parent = screenGui

local bannerText = Instance.new("TextLabel")
bannerText.Name = "BannerText"
bannerText.Size = UDim2.new(1, 0, 1, 0)
bannerText.BackgroundTransparency = 1
bannerText.TextColor3 = Color3.fromRGB(255, 255, 255)
bannerText.TextSize = 48
bannerText.Font = Enum.Font.GothamBold
bannerText.TextTransparency = 1
bannerText.Text = ""
bannerText.Parent = banner

local function showBanner(text, color)
	bannerText.Text = text
	bannerText.TextColor3 = color

	local fadeIn = TweenService:Create(bannerText, TweenInfo.new(0.5), { TextTransparency = 0 })
	local fadeOut = TweenService:Create(bannerText, TweenInfo.new(0.5), { TextTransparency = 1 })

	fadeIn:Play()
	fadeIn.Completed:Wait()
	task.wait(2)
	fadeOut:Play()
end

local function updateInventoryDisplay(itemId)
	-- Update display with 0.15s tick animation (TWEEN_FEEDBACK from ux-context.md)
	for _, config in ipairs(itemConfigs) do
		if not itemId or config.name == itemId then
			local count = inventory[config.name] or 0
			local label = itemLabels[config.name]

			-- Animate scale and color to show change
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local scaleUp = TweenService:Create(label, tweenInfo, { TextSize = 20 })
			local scaleDown = TweenService:Create(label, tweenInfo, { TextSize = 16 })
			local colorPulse = TweenService:Create(
				label,
				tweenInfo,
				{ TextColor3 = Color3.fromRGB(100, 255, 100) }
			)
			local colorRestore = TweenService:Create(
				label,
				tweenInfo,
				{ TextColor3 = Color3.fromRGB(255, 255, 255) }
			)

			-- Update text
			label.Text = config.emoji .. " " .. config.label .. ": " .. count

			-- Play tick animation
			scaleUp:Play()
			colorPulse:Play()
			scaleUp.Completed:Connect(function()
				scaleDown:Play()
				colorRestore:Play()
			end)
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
Signals.StateChanged.OnClientEvent:Connect(function(newState)
	if newState == "Day" then
		task.spawn(showBanner, "☀️ DAY BREAK ☀️", Color3.fromRGB(255, 220, 100))
	elseif newState == "Night" then
		task.spawn(showBanner, "🌙 NIGHT FALLS 🌙", Color3.fromRGB(150, 100, 255))
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
