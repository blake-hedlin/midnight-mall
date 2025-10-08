-- Signals.lua
-- RemoteEvents/Functions for client/server communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = Instance.new("Folder")
folder.Name = "Signals"
folder.Parent = ReplicatedStorage

local function newEvent(name)
  local ev = Instance.new("RemoteEvent")
  ev.Name = name
  ev.Parent = folder
  return ev
end

local M = {
  DayStarted = newEvent("DayStarted"),
  NightStarted = newEvent("NightStarted"),
  StateTick = newEvent("StateTick"),
  StateChanged = newEvent("StateChanged"),
  RequestState = newEvent("RequestState"), -- client → server
  Looted = newEvent("Looted"), -- server → client feedback
  InventoryChanged = newEvent("InventoryChanged"), -- server → client
}

return M
