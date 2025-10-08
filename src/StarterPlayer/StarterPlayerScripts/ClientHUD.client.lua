-- ClientHUD.client.lua
-- Displays time and a tiny inventory readout

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signals = require(ReplicatedStorage.Shared.Signals)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Name = "TimeLabel"
label.Size = UDim2.new(0, 240, 0, 28)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 0.3
label.TextScaled = true
label.Text = "Time: --"
label.Parent = screenGui

local inv = Instance.new("TextLabel")
inv.Name = "InvLabel"
inv.Size = UDim2.new(0, 300, 0, 28)
inv.Position = UDim2.new(0, 10, 0, 44)
inv.BackgroundTransparency = 0.3
inv.TextScaled = true
inv.Text = "Inv: wood=0 snack=0 battery=0"
inv.Parent = screenGui

local inventory = { wood = 0, snack = 0, battery = 0 }

Signals.InventoryChanged.OnClientEvent:Connect(function(id, value)
    inventory[id] = value
    inv.Text = ("Inv: wood=%d snack=%d battery=%d"):format(inventory.wood or 0, inventory.snack or 0, inventory.battery or 0)
end)

Signals.StateTick.OnClientEvent:Connect(function(state, time, nightCount)
    if state == "Day" then
        label.Text = ("Day %d — %ds left"):format(nightCount + 1, math.max(0, 120 - math.floor(time)))
    else
        label.Text = ("Night %d — %ds left"):format(nightCount, math.max(0, 60 - math.floor(time)))
    end
end)

Signals.Looted.OnClientEvent:Connect(function(ok, msg)
    if not msg then
        return
    end
    label.Text = msg
    task.delay(1.5, function()
        label.Text = label.Text -- keep last tick
    end)
end)
