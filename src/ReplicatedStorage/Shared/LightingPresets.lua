-- LightingPresets.lua
-- Sprint 1, Story 8: Lighting configurations for Day/Night/Dawn phases
-- Authoritative source: /docs/design_notes/ux-context.md
-- Referenced by: ServerScriptService/Systems/LightingController.server.lua

-- Named color constants for designer-friendly maintenance
local Colors = {
  Day = {
    Ambient = Color3.fromRGB(180, 190, 210),
    Fog = Color3.fromRGB(190, 210, 230),
    ShiftTop = Color3.fromRGB(180, 190, 210),
    ShiftBottom = Color3.fromRGB(160, 170, 190),
  },
  Night = {
    Ambient = Color3.fromRGB(25, 20, 30),
    Fog = Color3.fromRGB(120, 20, 20), -- Reddish tint for tension
    ShiftTop = Color3.fromRGB(120, 110, 140),
    ShiftBottom = Color3.fromRGB(80, 70, 90),
  },
  Dawn = {
    Ambient = Color3.fromRGB(120, 130, 160),
    Fog = Color3.fromRGB(170, 180, 200),
    ShiftTop = Color3.fromRGB(150, 160, 180),
    ShiftBottom = Color3.fromRGB(120, 130, 160),
  },
}

-- Named fog distance constants (in studs)
local Fog = {
  Day = { Start = 80, End = 800 },
  Night = { Start = 40, End = 260 }, -- Reduced visibility at night
  Dawn = { Start = 60, End = 600 },
}

-- Named brightness constants
local Brightness = {
  Day = 2.0, -- Full brightness
  Night = 1.3, -- Reduced for atmosphere
  Dawn = 1.8, -- Slightly dimmed
}

-- Named exposure constants
local Exposure = {
  Day = 0, -- Neutral
  Night = -0.35, -- Darker for tension
  Dawn = -0.1, -- Slightly dark
}

return {
  Day = {
    Ambient = Colors.Day.Ambient,
    OutdoorAmbient = Colors.Day.Ambient,
    FogColor = Colors.Day.Fog,
    FogStart = Fog.Day.Start,
    FogEnd = Fog.Day.End,
    ColorShift_Top = Colors.Day.ShiftTop,
    ColorShift_Bottom = Colors.Day.ShiftBottom,
    Brightness = Brightness.Day,
    ExposureCompensation = Exposure.Day,
  },
  Night = {
    Ambient = Colors.Night.Ambient,
    OutdoorAmbient = Colors.Night.Ambient,
    FogColor = Colors.Night.Fog,
    FogStart = Fog.Night.Start,
    FogEnd = Fog.Night.End,
    ColorShift_Top = Colors.Night.ShiftTop,
    ColorShift_Bottom = Colors.Night.ShiftBottom,
    Brightness = Brightness.Night,
    ExposureCompensation = Exposure.Night,
  },
  Dawn = {
    Ambient = Colors.Dawn.Ambient,
    OutdoorAmbient = Colors.Dawn.Ambient,
    FogColor = Colors.Dawn.Fog,
    FogStart = Fog.Dawn.Start,
    FogEnd = Fog.Dawn.End,
    ColorShift_Top = Colors.Dawn.ShiftTop,
    ColorShift_Bottom = Colors.Dawn.ShiftBottom,
    Brightness = Brightness.Dawn,
    ExposureCompensation = Exposure.Dawn,
  },
}
