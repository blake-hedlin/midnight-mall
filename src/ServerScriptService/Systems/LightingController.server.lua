-- LightingController.server.lua
-- Sprint 1, Story 1: Apply lighting presets based on Day/Night cycle
-- Listens to DayStarted and NightStarted signals from Clock system

print("[LightingController] Loading...")

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Signals = require(ReplicatedStorage.Shared.Signals)
local LightingPresets = require(ReplicatedStorage.Shared.LightingPresets)

print("[LightingController] Modules loaded, setting up connections...")

local TRANSITION_DURATION = 3 -- seconds

local function applyPreset(preset)
  print("[LightingController] Applying preset - Ambient:", preset.Ambient, "FogEnd:", preset.FogEnd, "FogColor:", preset.FogColor)

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
  print("[LightingController] Lighting tween started")

  -- Apply ColorCorrection if it exists
  local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
  if not colorCorrection then
    colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = Lighting
    print("[LightingController] Created new ColorCorrectionEffect")
  end

  local ccTween = TweenService:Create(colorCorrection, tweenInfo, {
    TintColor = preset.TintColor or Color3.new(1, 1, 1),
    Contrast = preset.Contrast or 0,
    Saturation = preset.Saturation or 0,
  })

  ccTween:Play()
  print("[LightingController] ColorCorrection tween started")

  -- Debug: Check actual Lighting values after a moment
  task.delay(TRANSITION_DURATION + 0.5, function()
    print("[LightingController] Final values - Ambient:", Lighting.Ambient, "FogEnd:", Lighting.FogEnd)
  end)
end

-- Listen to Day/Night state changes
Signals.DayStarted.Event:Connect(function(nightCount)
  print("[LightingController] DayStarted received, applying Day preset")
  applyPreset(LightingPresets.Day)
end)

Signals.NightStarted.Event:Connect(function(nightCount)
  print("[LightingController] NightStarted received, applying Night preset")
  applyPreset(LightingPresets.Night)
end)

-- Apply initial preset on server start
print("[LightingController] Connections established, applying initial Day preset")
task.defer(function()
  applyPreset(LightingPresets.Day)
  print("[LightingController] Initial Day preset applied")
end)
