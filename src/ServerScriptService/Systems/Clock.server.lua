-- Clock.server.lua
-- Simple Day/Night state with signals

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signals = require(ReplicatedStorage.Shared.Signals)

local Clock = {}
Clock.state = "Day" -- "Day" | "Night"
Clock.dayLength = 120 -- seconds
Clock.nightLength = 60 -- seconds
Clock.time = 0
Clock.nightCount = 0

local function setState(newState)
  if Clock.state == newState then
    return
  end
  Clock.state = newState
  if newState == "Day" then
    Signals.DayStarted:Fire(Clock.nightCount)
  else
    Clock.nightCount += 1
    Signals.NightStarted:Fire(Clock.nightCount)
  end
end

Signals.RequestState:Connect(function(player)
  Signals.StateChanged:FireClient(player, Clock.state, Clock.time, Clock.nightCount)
end)

RunService.Heartbeat:Connect(function(dt)
  Clock.time += dt
  if Clock.state == "Day" and Clock.time >= Clock.dayLength then
    Clock.time = 0
    setState("Night")
  elseif Clock.state == "Night" and Clock.time >= Clock.nightLength then
    Clock.time = 0
    setState("Day")
  end
  Signals.StateTick:FireAllClients(Clock.state, Clock.time, Clock.nightCount)
end)

-- Kick off initial signals
task.defer(function()
  Signals.DayStarted:Fire(Clock.nightCount)
end)

return Clock
