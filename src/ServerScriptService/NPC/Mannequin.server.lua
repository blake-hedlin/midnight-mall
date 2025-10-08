-- Mannequin.server.lua
-- Sprint 2 stub: listens to NightStarted to animate 'awake' mannequins

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signals = require(ReplicatedStorage.Shared.Signals)

Signals.NightStarted.Event:Connect(function(nightCount)
  -- Placeholder: In Sprint 2, spawn and activate mannequins here
  print("[Mannequin] Night " .. nightCount .. " started - would spawn enemies here")
end)

-- In Sprint 2:
-- 1) Spawn mannequins at tagged spawn points on Night start
-- 2) Use PathfindingService to patrol and chase players
-- 3) Deal damage to boards and players
