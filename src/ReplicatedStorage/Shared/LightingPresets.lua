-- LightingPresets.lua
-- Sprint 1, Story 8: Lighting configurations for Day/Night phases
-- Referenced by: ServerScriptService/Systems/LightingController.server.lua

local LightingPresets = {}

-- Day Phase: Bright, warm, safe feeling
LightingPresets.Day = {
  Ambient = Color3.fromRGB(200, 200, 200), -- Bright ambient (0.8 brightness)
  OutdoorAmbient = Color3.fromRGB(150, 150, 150),
  Brightness = 2.5,
  FogEnd = 500, -- Clear visibility
  FogStart = 0,
  FogColor = Color3.fromRGB(200, 210, 220),

  -- ColorCorrection properties
  TintColor = Color3.fromRGB(255, 250, 240), -- Warm white
  Contrast = 0.1,
  Saturation = 0,
}

-- Night Phase: Dark, red-tinted, oppressive atmosphere
LightingPresets.Night = {
  Ambient = Color3.fromRGB(25, 25, 25), -- Very dark ambient (0.1 brightness)
  OutdoorAmbient = Color3.fromRGB(15, 10, 10),
  Brightness = 0.5,
  FogEnd = 80, -- Heavy fog, reduced visibility
  FogStart = 10,
  FogColor = Color3.fromRGB(60, 20, 20), -- Red fog

  -- ColorCorrection properties
  TintColor = Color3.fromRGB(255, 200, 200), -- Red tint
  Contrast = 0.2,
  Saturation = -0.2, -- Slightly desaturated
}

return LightingPresets
