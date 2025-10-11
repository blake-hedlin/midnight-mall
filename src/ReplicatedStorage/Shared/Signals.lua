-- Signals.lua
-- BindableEvents for server-to-server and RemoteEvents for client/server communication

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local folder = Instance.new("Folder")
folder.Name = "Signals"
folder.Parent = ReplicatedStorage

local function newRemoteEvent(name)
  local ev = Instance.new("RemoteEvent")
  ev.Name = name
  ev.Parent = folder
  return ev
end

local function newBindableEvent(name)
  local ev = Instance.new("BindableEvent")
  ev.Name = name
  ev.Parent = folder
  return ev
end

local M = {
  -- Server-to-server signals (BindableEvents)
  DayStarted = newBindableEvent("DayStarted"),
  NightStarted = newBindableEvent("NightStarted"),
  BoardDamaged = newBindableEvent("BoardDamaged"), -- Enemy → Barricade system

  -- Client/server communication (RemoteEvents)
  StateTick = newRemoteEvent("StateTick"),
  StateChanged = newRemoteEvent("StateChanged"),
  RequestState = newRemoteEvent("RequestState"), -- client → server
  Looted = newRemoteEvent("Looted"), -- server → client feedback
  InventoryChanged = newRemoteEvent("InventoryChanged"), -- server → client
  PlaceBarricade = newRemoteEvent("PlaceBarricade"), -- client → server placement request
  RepairBarricade = newRemoteEvent("RepairBarricade"), -- client → server repair request
  BarricadePlaced = newRemoteEvent("BarricadePlaced"), -- server → client confirmation
}

return M
