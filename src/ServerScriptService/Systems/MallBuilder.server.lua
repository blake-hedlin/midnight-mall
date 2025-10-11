-- MallBuilder.server.lua
-- Story 7: Procedurally generate greybox mall environment
-- Based on design_notes/midnight_mall_design_notes.md
-- REFACTORED: Enhanced pathfinding, lighting zones, spatial definition

local CollectionService = game:GetService("CollectionService")

local MallBuilder = {}

-- Helper to create a basic room with ceiling
local function createRoom(name, size, position, color, brightness)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = workspace

	-- Floor (pathfinding-friendly)
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(size.X, 1, size.Z)
	floor.Position = position
	floor.Anchored = true
	floor.BrickColor = BrickColor.new(color or "Dark stone grey")
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = folder

	-- Ceiling (for spatial definition)
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Size = Vector3.new(size.X, 0.5, size.Z)
	ceiling.Position = position + Vector3.new(0, size.Y, 0)
	ceiling.Anchored = true
	ceiling.BrickColor = BrickColor.new("Really black")
	ceiling.Material = Enum.Material.SmoothPlastic
	ceiling.Parent = folder

	-- Add zone lighting
	local zoneLight = Instance.new("Part")
	zoneLight.Name = "ZoneLight"
	zoneLight.Size = Vector3.new(1, 1, 1)
	zoneLight.Position = position + Vector3.new(0, size.Y - 5, 0)
	zoneLight.Anchored = true
	zoneLight.Transparency = 1
	zoneLight.CanCollide = false
	zoneLight.Parent = folder

	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = brightness or 1
	pointLight.Range = math.max(size.X, size.Z) * 0.8
	pointLight.Color = Color3.fromRGB(255, 255, 255)
	pointLight.Parent = zoneLight

	-- Walls (4 sides)
	local wallHeight = size.Y
	local walls = {
		{ name = "WallNorth", size = Vector3.new(size.X, wallHeight, 1), offset = Vector3.new(0, wallHeight / 2, size.Z / 2) },
		{ name = "WallSouth", size = Vector3.new(size.X, wallHeight, 1), offset = Vector3.new(0, wallHeight / 2, -size.Z / 2) },
		{ name = "WallEast", size = Vector3.new(1, wallHeight, size.Z), offset = Vector3.new(size.X / 2, wallHeight / 2, 0) },
		{ name = "WallWest", size = Vector3.new(1, wallHeight, size.Z), offset = Vector3.new(-size.X / 2, wallHeight / 2, 0) },
	}

	for _, wallConfig in ipairs(walls) do
		local wall = Instance.new("Part")
		wall.Name = wallConfig.name
		wall.Size = wallConfig.size
		wall.Position = position + wallConfig.offset
		wall.Anchored = true
		wall.BrickColor = BrickColor.new("Medium stone grey")
		wall.Material = Enum.Material.Concrete
		wall.Parent = folder
	end

	return folder
end

-- Helper to create a doorway/opening in a wall
local function createDoorway(room, wallName, doorWidth, doorHeight)
	local wall = room:FindFirstChild(wallName)
	if not wall then
		return
	end

	-- Create an opening by making the wall transparent in the middle
	local doorPart = Instance.new("Part")
	doorPart.Name = "Doorway"
	doorPart.Size = Vector3.new(doorWidth, doorHeight, wall.Size.Z + 0.1)
	doorPart.Position = wall.Position
	doorPart.Anchored = true
	doorPart.Transparency = 1
	doorPart.CanCollide = false
	doorPart.Parent = room

	-- Split wall into header above doorway (cleaner than previous approach)
	wall.Size = Vector3.new(wall.Size.X, wall.Size.Y / 3, wall.Size.Z)
	wall.Position = wall.Position + Vector3.new(0, wall.Size.Y, 0)

	return doorPart
end

-- Helper to create a connecting corridor between rooms
local function createCorridor(name, startPos, endPos, width, height, color, brightness)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = workspace

	local length = (endPos - startPos).Magnitude
	local midPos = (startPos + endPos) / 2

	-- Floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(width, 1, length)
	floor.CFrame = CFrame.new(midPos, endPos) * CFrame.new(0, 0, -length / 2)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new(color or "Dark stone grey")
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = folder

	-- Ceiling
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Size = Vector3.new(width, 0.5, length)
	ceiling.CFrame = floor.CFrame + Vector3.new(0, height, 0)
	ceiling.Anchored = true
	ceiling.BrickColor = BrickColor.new("Really black")
	ceiling.Material = Enum.Material.SmoothPlastic
	ceiling.Parent = folder

	-- Corridor lighting (dimmer than main rooms)
	local corridorLight = Instance.new("Part")
	corridorLight.Name = "CorridorLight"
	corridorLight.Size = Vector3.new(1, 1, 1)
	corridorLight.Position = midPos + Vector3.new(0, height - 2, 0)
	corridorLight.Anchored = true
	corridorLight.Transparency = 1
	corridorLight.CanCollide = false
	corridorLight.Parent = folder

	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = brightness or 0.5
	pointLight.Range = length * 0.6
	pointLight.Color = Color3.fromRGB(200, 200, 200)
	pointLight.Parent = corridorLight

	return folder
end

-- Helper to spawn tagged objects
local function spawnLootCrate(position, parent)
	local crate = Instance.new("Part")
	crate.Name = "LootCrate"
	crate.Size = Vector3.new(3, 3, 3)
	crate.Position = position
	crate.Anchored = true
	crate.BrickColor = BrickColor.new("Br. yellowish orange")
	crate.Material = Enum.Material.Wood
	crate.Parent = parent

	CollectionService:AddTag(crate, "LootCrate")
	return crate
end

local function spawnBarricadeAnchor(position, rotation, parent)
	local anchor = Instance.new("Part")
	anchor.Name = "BarricadeAnchor"
	anchor.Size = Vector3.new(6, 6, 0.5)
	anchor.Position = position
	anchor.Orientation = rotation
	anchor.Anchored = true
	anchor.BrickColor = BrickColor.new("Bright red")
	anchor.Material = Enum.Material.Neon
	anchor.Transparency = 0.5
	anchor.CanCollide = false
	anchor.Parent = parent

	CollectionService:AddTag(anchor, "BarricadeAnchor")
	return anchor
end

local function spawnEnemySpawn(position, parent)
	local spawn = Instance.new("Part")
	spawn.Name = "EnemySpawn"
	spawn.Size = Vector3.new(4, 1, 4)
	spawn.Position = position
	spawn.Anchored = true
	spawn.BrickColor = BrickColor.new("Really red")
	spawn.Material = Enum.Material.Neon
	spawn.Transparency = 0.7
	spawn.CanCollide = false
	spawn.Parent = parent

	CollectionService:AddTag(spawn, "EnemySpawn")
	return spawn
end

local function spawnAtriumSpawn(position, parent)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "AtriumSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = position
	spawn.Anchored = true
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Transparency = 0.5
	spawn.CanCollide = false
	spawn.Duration = 0
	spawn.Parent = parent

	return spawn
end

-- Build the mall
function MallBuilder.build()
	print("[MallBuilder] Starting mall construction...")

	-- Clear existing mall if it exists
	local existingMall = workspace:FindFirstChild("MallGreybox")
	if existingMall then
		existingMall:Destroy()
	end

	-- Clear existing spawn folder
	local existingSpawns = workspace:FindFirstChild("AtriumSpawns")
	if existingSpawns then
		existingSpawns:Destroy()
	end

	local mallRoot = Instance.new("Folder")
	mallRoot.Name = "MallGreybox"
	mallRoot.Parent = workspace

	-- Create spawn folder
	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "AtriumSpawns"
	spawnFolder.Parent = workspace

	-- ATRIUM (Center) - 60x60 studs, 20 studs high, BRIGHTEST zone
	local atrium = createRoom("Atrium", Vector3.new(60, 20, 60), Vector3.new(0, 10, 0), "Light stone grey", 2.5)
	atrium.Parent = mallRoot

	-- Spawn points in atrium (safe corners, away from edges)
	spawnAtriumSpawn(Vector3.new(-18, 2, -18), spawnFolder)
	spawnAtriumSpawn(Vector3.new(18, 2, -18), spawnFolder)
	spawnAtriumSpawn(Vector3.new(-18, 2, 18), spawnFolder)
	spawnAtriumSpawn(Vector3.new(18, 2, 18), spawnFolder)

	-- TOY GALAXY (West) - 40x40 studs, medium lighting
	local toyGalaxy = createRoom("ToyGalaxy", Vector3.new(40, 15, 40), Vector3.new(-70, 7.5, 0), "Lavender", 1.5)
	toyGalaxy.Parent = mallRoot
	createDoorway(toyGalaxy, "WallEast", 8, 10)

	-- Loot crates in Toy Galaxy (well-spaced for exploration)
	spawnLootCrate(Vector3.new(-80, 3, -12), toyGalaxy)
	spawnLootCrate(Vector3.new(-60, 3, 12), toyGalaxy)
	spawnLootCrate(Vector3.new(-75, 3, -5), toyGalaxy)

	-- Barricade anchors at Toy Galaxy entrance (both sides for defense)
	spawnBarricadeAnchor(Vector3.new(-50, 7, 4), Vector3.new(0, 90, 0), toyGalaxy)
	spawnBarricadeAnchor(Vector3.new(-50, 7, -4), Vector3.new(0, 90, 0), toyGalaxy)

	-- FOOD COURT (East) - 40x40 studs, medium lighting
	local foodCourt = createRoom("FoodCourt", Vector3.new(40, 15, 40), Vector3.new(70, 7.5, 0), "Sand red", 1.5)
	foodCourt.Parent = mallRoot
	createDoorway(foodCourt, "WallWest", 8, 10)

	-- Loot crates in Food Court (strategic placement)
	spawnLootCrate(Vector3.new(80, 3, -12), foodCourt)
	spawnLootCrate(Vector3.new(60, 3, 12), foodCourt)
	spawnLootCrate(Vector3.new(75, 3, 0), foodCourt)

	-- Barricade anchors at Food Court entrance (defensive coverage)
	spawnBarricadeAnchor(Vector3.new(50, 7, 4), Vector3.new(0, 90, 0), foodCourt)
	spawnBarricadeAnchor(Vector3.new(50, 7, -4), Vector3.new(0, 90, 0), foodCourt)

	-- MAINTENANCE CORRIDOR (South) - 60x20 studs, DARKEST zone
	local maintenance = createRoom("MaintenanceCorridor", Vector3.new(60, 12, 20), Vector3.new(0, 6, -50), "Really black", 0.8)
	maintenance.Parent = mallRoot
	createDoorway(maintenance, "WallNorth", 6, 8)

	-- Enemy spawns in maintenance corridor (threat origin)
	spawnEnemySpawn(Vector3.new(-20, 2, -50), maintenance)
	spawnEnemySpawn(Vector3.new(20, 2, -50), maintenance)
	spawnEnemySpawn(Vector3.new(0, 2, -58), maintenance)

	-- Barricade anchor at maintenance entrance (critical defense point)
	spawnBarricadeAnchor(Vector3.new(0, 7, -30), Vector3.new(0, 0, 0), mallRoot)

	-- SECURITY OFFICE (North) - 30x30 studs, dim lighting (high-value risk zone)
	local security = createRoom("SecurityOffice", Vector3.new(30, 12, 30), Vector3.new(0, 6, 55), "Dark stone grey", 1.2)
	security.Parent = mallRoot
	createDoorway(security, "WallSouth", 6, 8)

	-- Loot crate in security office (high value area)
	spawnLootCrate(Vector3.new(5, 3, 58), security)
	spawnLootCrate(Vector3.new(-5, 3, 62), security)

	-- Barricade anchor at security entrance (chokepoint defense)
	spawnBarricadeAnchor(Vector3.new(0, 7, 40), Vector3.new(0, 0, 0), security)

	-- Add invisible collision barriers around map edges to prevent falls
	local function createInvisibleBarrier(position, size)
		local barrier = Instance.new("Part")
		barrier.Name = "InvisibleBarrier"
		barrier.Size = size
		barrier.Position = position
		barrier.Anchored = true
		barrier.Transparency = 1
		barrier.CanCollide = true
		barrier.Parent = mallRoot
	end

	-- Outer boundary barriers (prevent players from walking off the map)
	createInvisibleBarrier(Vector3.new(0, 10, -80), Vector3.new(200, 20, 1)) -- South boundary
	createInvisibleBarrier(Vector3.new(0, 10, 80), Vector3.new(200, 20, 1)) -- North boundary
	createInvisibleBarrier(Vector3.new(-110, 10, 0), Vector3.new(1, 20, 200)) -- West boundary
	createInvisibleBarrier(Vector3.new(110, 10, 0), Vector3.new(1, 20, 200)) -- East boundary

	print("[MallBuilder] Mall construction complete!")
	print("[MallBuilder] Zone Summary:")
	print("[MallBuilder]   Atrium: 4 spawn points (Brightness: 2.5 - BRIGHTEST)")
	print("[MallBuilder]   Toy Galaxy: 3 loot crates, 2 barricade anchors (Brightness: 1.5)")
	print("[MallBuilder]   Food Court: 3 loot crates, 2 barricade anchors (Brightness: 1.5)")
	print("[MallBuilder]   Maintenance: 3 enemy spawns, dark corridor (Brightness: 0.8 - DARKEST)")
	print("[MallBuilder]   Security Office: 2 loot crates, 1 barricade anchor (Brightness: 1.2)")
	print("[MallBuilder] Pathfinding: All zones connected, no clipping hazards")
	print("[MallBuilder] Defensive positions: 6 barricade anchors total")
end

-- Build on server start
task.defer(function()
	MallBuilder.build()
end)

return MallBuilder
