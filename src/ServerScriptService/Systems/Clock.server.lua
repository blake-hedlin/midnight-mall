-- Clock.server.lua
-- Simple Day/Night state with signals

print("[Clock] Clock.server.lua is loading... (v2)")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signals = require(ReplicatedStorage.Shared.Signals)
print("[Clock] Signals loaded successfully")

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
  print("[Clock] State changed to:", newState, "| Night count:", Clock.nightCount)

  -- Fire state change to all clients for banner
  Signals.StateChanged:FireAllClients(newState)

  if newState == "Day" then
    Signals.DayStarted:Fire(Clock.nightCount)
    print("[Clock] DayStarted signal fired")
  else
    Clock.nightCount += 1
    Signals.NightStarted:Fire(Clock.nightCount)
    print("[Clock] NightStarted signal fired")
  end
end

Signals.RequestState.OnServerEvent:Connect(function(player)
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
