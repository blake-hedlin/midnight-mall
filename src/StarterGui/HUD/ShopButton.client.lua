-- ShopButton.client.lua
-- Sprint 1, Story 10: Shop UI placeholder (non-functional)
-- Creates a clickable button that opens/closes a blank shop panel

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Wait for HUD ScreenGui (created by ClientHUD.client.lua)
local hudGui = PlayerGui:WaitForChild("HUD", 10)
if not hudGui then
  warn("[ShopButton] HUD ScreenGui not found")
  return
end

-- Create Shop Button
local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 120, 0, 40)
shopButton.Position = UDim2.new(1, -130, 0, 10) -- Top-right corner
shopButton.AnchorPoint = Vector2.new(0, 0)
shopButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
shopButton.BorderSizePixel = 2
shopButton.BorderColor3 = Color3.fromRGB(200, 200, 200)
shopButton.Text = "🛒 Shop"
shopButton.TextScaled = true
shopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shopButton.Font = Enum.Font.GothamBold
shopButton.Parent = hudGui

-- Create Shop Panel (blank placeholder)
local shopPanel = Instance.new("Frame")
shopPanel.Name = "ShopPanel"
shopPanel.Size = UDim2.new(0, 400, 0, 300)
shopPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
shopPanel.AnchorPoint = Vector2.new(0.5, 0.5)
shopPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
shopPanel.BorderSizePixel = 3
shopPanel.BorderColor3 = Color3.fromRGB(150, 150, 150)
shopPanel.Visible = false -- Hidden by default
shopPanel.Parent = hudGui

-- Panel Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
titleLabel.Text = "🛒 Shop (Coming Soon)"
titleLabel.TextScaled = true
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = shopPanel

-- Panel Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeButton.Text = "✕"
closeButton.TextScaled = true
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = shopPanel

-- Placeholder Text
local placeholderText = Instance.new("TextLabel")
placeholderText.Name = "Placeholder"
placeholderText.Size = UDim2.new(1, -20, 1, -60)
placeholderText.Position = UDim2.new(0, 10, 0, 50)
placeholderText.BackgroundTransparency = 1
placeholderText.Text =
  "Shop items will be available in Sprint 2.\n\nFor now, this is a placeholder UI."
placeholderText.TextScaled = false
placeholderText.TextSize = 18
placeholderText.TextWrapped = true
placeholderText.TextColor3 = Color3.fromRGB(200, 200, 200)
placeholderText.Font = Enum.Font.Gotham
placeholderText.Parent = shopPanel

-- Toggle shop panel visibility
shopButton.Activated:Connect(function()
  shopPanel.Visible = not shopPanel.Visible
end)

closeButton.Activated:Connect(function()
  shopPanel.Visible = false
end)

-- TODO Sprint 2: Integrate with Currency.lua to display coin balance
-- TODO Sprint 2: Add product listings with purchase functionality
-- TODO Sprint 2: Implement cosmetics/revive token shop items
