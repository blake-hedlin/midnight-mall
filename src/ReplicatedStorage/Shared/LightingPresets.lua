-- LightingPresets.lua
-- Sprint 1, Story 8: Lighting configurations for Day/Night/Dawn phases
-- Authoritative source: /docs/design_notes/ux-context.md
-- Referenced by: ServerScriptService/Systems/LightingController.server.lua

return {
  Day = {
    Ambient = Color3.fromRGB(180, 190, 210),
    OutdoorAmbient = Color3.fromRGB(180, 190, 210),
    FogColor = Color3.fromRGB(190, 210, 230),
    FogStart = 80,
    FogEnd = 800,
    ColorShift_Top = Color3.fromRGB(180, 190, 210),
    ColorShift_Bottom = Color3.fromRGB(160, 170, 190),
    Brightness = 2.0,
    ExposureCompensation = 0,
  },
  Night = {
    Ambient = Color3.fromRGB(25, 20, 30),
    OutdoorAmbient = Color3.fromRGB(25, 20, 30),
    FogColor = Color3.fromRGB(120, 20, 20),
    FogStart = 40,
    FogEnd = 260,
    ColorShift_Top = Color3.fromRGB(120, 110, 140),
    ColorShift_Bottom = Color3.fromRGB(80, 70, 90),
    Brightness = 1.3,
    ExposureCompensation = -0.35,
  },
  Dawn = {
    Ambient = Color3.fromRGB(120, 130, 160),
    OutdoorAmbient = Color3.fromRGB(120, 130, 160),
    FogColor = Color3.fromRGB(170, 180, 200),
    FogStart = 60,
    FogEnd = 600,
    ColorShift_Top = Color3.fromRGB(150, 160, 180),
    ColorShift_Bottom = Color3.fromRGB(120, 130, 160),
    Brightness = 1.8,
    ExposureCompensation = -0.1,
  }
}
