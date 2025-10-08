-- LightingController.server.lua
-- Sprint 1, Story 1: Apply lighting presets based on Day/Night cycle
-- Listens to DayStarted and NightStarted signals from Clock system

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Signals = require(ReplicatedStorage.Shared.Signals)
local LightingPresets = require(ReplicatedStorage.Shared.LightingPresets)

local TRANSITION_DURATION = 3 -- seconds

local function applyPreset(preset)
  local tweenInfo =
    TweenInfo.new(TRANSITION_DURATION, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

  -- Tween lighting properties
  local lightingTween = TweenService:Create(Lighting, tweenInfo, {
    Ambient = preset.Ambient,
    OutdoorAmbient = preset.OutdoorAmbient,
    Brightness = preset.Brightness,
    FogEnd = preset.FogEnd,
    FogStart = preset.FogStart,
    FogColor = preset.FogColor,
  })

  lightingTween:Play()

  -- Apply ColorCorrection if it exists
  local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
  if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
  end

  local ccTween = TweenService:Create(colorCorrection, tweenInfo, {
    TintColor = preset.TintColor or Color3.new(1, 1, 1),
    Contrast = preset.Contrast or 0,
    Saturation = preset.Saturation or 0,
  })

  ccTween:Play()
end

-- Listen to Day/Night state changes
Signals.DayStarted.OnServerEvent:Connect(function()
  applyPreset(LightingPresets.Day)
end)

Signals.NightStarted.OnServerEvent:Connect(function()
  applyPreset(LightingPresets.Night)
end)

-- TODO: Apply initial preset on server start
task.defer(function()
  applyPreset(LightingPresets.Day)
end)
