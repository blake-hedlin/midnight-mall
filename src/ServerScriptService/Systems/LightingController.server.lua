-- LightingController.server.lua
-- Sprint 1, Story 1: Apply lighting presets based on Day/Night cycle
-- Listens to DayStarted and NightStarted signals from Clock system
-- Authoritative source: /docs/design_notes/ux-context.md

-- Debug flag: Set to false to disable verbose logging in production
local DEBUG = true

local function debugPrint(...)
  if DEBUG then
    print("[LightingController]", ...)
  end
end

debugPrint("Loading...")

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Signals = require(ReplicatedStorage.Shared.Signals)
local LightingPresets = require(ReplicatedStorage.Shared.LightingPresets)

debugPrint("Modules loaded, setting up connections...")

-- UX Context tokens
local TWEEN_SCENE = 1.5 -- seconds (per ux-context.md)
local DAWN_HOLD_DURATION = 1.0 -- seconds before transitioning to full Day
local HEARTBEAT_FADEIN_DURATION = 3 -- seconds
local HEARTBEAT_VOLUME = 0.4

local heartbeatSound = nil
local heartbeatTween = nil
local activeLightingTween = nil

-- Remove deprecated ColorCorrectionEffect from previous implementation
local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if colorCorrection then
  colorCorrection:Destroy()
  debugPrint("Removed deprecated ColorCorrectionEffect")
end

local function applyPreset(preset, bannerText, playNightSFX)
  debugPrint(
    "Applying preset - Ambient:",
    preset.Ambient,
    "FogEnd:",
    preset.FogEnd,
    "FogColor:",
    preset.FogColor
  )

  -- Cancel active tween to prevent memory leak and animation conflicts
  if activeLightingTween then
    activeLightingTween:Cancel()
    activeLightingTween = nil
  end

  local tweenInfo = TweenInfo.new(TWEEN_SCENE, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

  -- Tween lighting properties including ColorShift and ExposureCompensation
  activeLightingTween = TweenService:Create(Lighting, tweenInfo, {
    Ambient = preset.Ambient,
    OutdoorAmbient = preset.OutdoorAmbient,
    Brightness = preset.Brightness,
    FogEnd = preset.FogEnd,
    FogStart = preset.FogStart,
    FogColor = preset.FogColor,
    ColorShift_Top = preset.ColorShift_Top,
    ColorShift_Bottom = preset.ColorShift_Bottom,
    ExposureCompensation = preset.ExposureCompensation,
  })

  activeLightingTween:Play()
  debugPrint("Lighting tween started")

  -- Fire UI Banner if specified
  if bannerText then
    Signals.StateChanged:FireAllClients(bannerText)
    debugPrint("UI_Banner fired:", bannerText)
  end

  -- Play SFX_NightStart if specified
  if playNightSFX then
    local nightStartSound = SoundService:FindFirstChild("SFX_NightStart")
    if not nightStartSound then
      warn("[LightingController] SFX_NightStart sound missing in SoundService - skipping audio")
    else
      nightStartSound:Play()
      debugPrint("SFX_NightStart played")
    end
  end

  -- Debug: Check actual Lighting values after a moment
  task.delay(TWEEN_SCENE + 0.5, function()
    debugPrint("Final values - Ambient:", Lighting.Ambient, "FogEnd:", Lighting.FogEnd)
  end)
end

local function startHeartbeat()
  -- Start heartbeat loop with fade-in from 0 → 0.4 over 3 seconds
  debugPrint("Starting heartbeat loop")

  heartbeatSound = SoundService:FindFirstChild("HeartbeatLoop")
  if not heartbeatSound then
    warn("[LightingController] HeartbeatLoop sound missing in SoundService - skipping audio")
    return
  end

  heartbeatSound.Volume = 0
  heartbeatSound.Looped = true
  heartbeatSound:Play()
  heartbeatTween = TweenService:Create(
    heartbeatSound,
    TweenInfo.new(HEARTBEAT_FADEIN_DURATION),
    { Volume = HEARTBEAT_VOLUME }
  )
  heartbeatTween:Play()
end

local function stopHeartbeat()
  -- Stop heartbeat loop
  debugPrint("Stopping heartbeat loop")

  if heartbeatTween then
    heartbeatTween:Cancel()
    heartbeatTween = nil
  end

  if heartbeatSound then
    heartbeatSound:Stop()
    heartbeatSound = nil
  end
end

-- Listen to Day/Night state changes
Signals.DayStarted.Event:Connect(function(nightCount)
  debugPrint("DayStarted received, applying Dawn then Day preset")

  -- Stop heartbeat loop when day starts
  stopHeartbeat()

  -- Apply Dawn preset first (brief transition)
  applyPreset(LightingPresets.Dawn, "Dawn Breaking", false)

  -- Then transition to Day after a short delay
  task.delay(TWEEN_SCENE + DAWN_HOLD_DURATION, function()
    applyPreset(LightingPresets.Day, nil, false)
  end)
end)

Signals.NightStarted.Event:Connect(function(nightCount)
  debugPrint("NightStarted received, applying Night preset")

  -- Apply Night preset with banner and SFX
  applyPreset(LightingPresets.Night, "Night Falling", true)

  -- Start heartbeat loop
  startHeartbeat()
end)

-- Apply initial preset on server start
debugPrint("Connections established, applying initial Day preset")
task.spawn(function()
  task.wait() -- Yield once to ensure Lighting service is fully initialized
  applyPreset(LightingPresets.Day, nil, false)
  debugPrint("Initial Day preset applied")
end)
