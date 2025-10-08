-- Mannequin.server.lua
-- Sprint 2 stub: listens to NightStarted to animate 'awake' mannequins

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signals = require(ReplicatedStorage.Shared.Signals)

Signals.NightStarted.OnClientEvent:Connect(function() end) -- placeholder (server->client in practice)

-- In Sprint 2:
-- 1) Spawn mannequins at tagged spawn points on Night start
-- 2) Use PathfindingService to patrol and chase players
-- 3) Deal damage to boards and players
