-- AssetConfig.lua
-- Centralized asset path management for easy asset swapping and maintenance
-- All rbxasset:// and rbxassetid:// paths should be referenced here

local AssetConfig = {}

-- ============================================================================
-- PARTICLE TEXTURES
-- ============================================================================
AssetConfig.Particles = {
  -- Loot system particles
  Smoke = "rbxasset://textures/particles/smoke_main.dds",

  -- Barricade system particles
  Sparkles = "rbxasset://textures/particles/sparkles_main.dds",
}

-- ============================================================================
-- SOUND EFFECTS
-- ============================================================================
AssetConfig.Sounds = {
  -- Loot system
  LootOpen = "rbxasset://sounds/switch.wav", -- TODO: Replace with custom SFX

  -- Barricade system
  BarricadePlace = "rbxasset://sounds/impact_wood_hollow_03.wav",

  -- Mannequin/Enemy system
  MannequinFootstep = "rbxasset://sounds/collide.wav",
  MannequinHeartbeat = "rbxasset://sounds/bass.wav", -- TODO: Replace with heartbeat loop
}

-- ============================================================================
-- AUDIO SETTINGS (from ux-context.md)
-- ============================================================================
AssetConfig.Volume = {
  SFX_Standard = 0.3, -- -10 dB approximately
  SFX_Quiet = 0.15, -- -20 dB approximately
  Music_Ambient = 0.2, -- -15 dB approximately
}

-- ============================================================================
-- FUTURE: Custom Asset IDs
-- ============================================================================
-- When uploading custom assets to Roblox, add them here:
-- AssetConfig.CustomSounds = {
--     LootOpen = "rbxassetid://1234567890",
--     BarricadeBreak = "rbxassetid://0987654321",
-- }
--
-- AssetConfig.CustomParticles = {
--     DustCloud = "rbxassetid://1111111111",
-- }

return AssetConfig
