-- MallBuilder.server.lua
-- Story 7: Procedurally generate greybox mall environment
-- Based on design_notes/midnight_mall_design_notes.md

local CollectionService = game:GetService("CollectionService")

local MallBuilder = {}

-- Helper to create a basic room
local function createRoom(name, size, position, color)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = workspace

	-- Floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(size.X, 1, size.Z)
	floor.Position = position
	floor.Anchored = true
	floor.BrickColor = BrickColor.new(color or "Dark stone grey")
	floor.Material = Enum.Material.SmoothPlastic
	floor.Parent = folder

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

	-- Split wall into two parts around doorway
	wall.Size = Vector3.new(wall.Size.X, wall.Size.Y / 3, wall.Size.Z)
	wall.Position = wall.Position + Vector3.new(0, wall.Size.Y, 0)

	return doorPart
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

	local mallRoot = Instance.new("Folder")
	mallRoot.Name = "MallGreybox"
	mallRoot.Parent = workspace

	-- Create spawn folder
	local spawnFolder = Instance.new("Folder")
	spawnFolder.Name = "AtriumSpawns"
	spawnFolder.Parent = workspace

	-- ATRIUM (Center) - 60x60 studs, 20 studs high
	local atrium = createRoom("Atrium", Vector3.new(60, 20, 60), Vector3.new(0, 10, 0), "Light stone grey")
	atrium.Parent = mallRoot

	-- Spawn points in atrium (4 corners)
	spawnAtriumSpawn(Vector3.new(-20, 2, -20), spawnFolder)
	spawnAtriumSpawn(Vector3.new(20, 2, -20), spawnFolder)
	spawnAtriumSpawn(Vector3.new(-20, 2, 20), spawnFolder)
	spawnAtriumSpawn(Vector3.new(20, 2, 20), spawnFolder)

	-- TOY GALAXY (West) - 40x40 studs
	local toyGalaxy = createRoom("ToyGalaxy", Vector3.new(40, 15, 40), Vector3.new(-70, 7.5, 0), "Lavender")
	toyGalaxy.Parent = mallRoot
	createDoorway(toyGalaxy, "WallEast", 8, 10)

	-- Loot crates in Toy Galaxy
	spawnLootCrate(Vector3.new(-80, 3, -10), toyGalaxy)
	spawnLootCrate(Vector3.new(-60, 3, 10), toyGalaxy)
	spawnLootCrate(Vector3.new(-75, 3, 15), toyGalaxy)

	-- Barricade anchors at Toy Galaxy entrance
	spawnBarricadeAnchor(Vector3.new(-50, 7, 0), Vector3.new(0, 90, 0), toyGalaxy)

	-- FOOD COURT (East) - 40x40 studs
	local foodCourt = createRoom("FoodCourt", Vector3.new(40, 15, 40), Vector3.new(70, 7.5, 0), "Sand red")
	foodCourt.Parent = mallRoot
	createDoorway(foodCourt, "WallWest", 8, 10)

	-- Loot crates in Food Court
	spawnLootCrate(Vector3.new(80, 3, -10), foodCourt)
	spawnLootCrate(Vector3.new(60, 3, 10), foodCourt)

	-- Barricade anchors at Food Court entrance
	spawnBarricadeAnchor(Vector3.new(50, 7, 0), Vector3.new(0, 90, 0), foodCourt)

	-- MAINTENANCE CORRIDOR (South) - 20x60 studs (narrow hallway)
	local maintenance = createRoom("MaintenanceCorridor", Vector3.new(60, 12, 20), Vector3.new(0, 6, -50), "Really black")
	maintenance.Parent = mallRoot
	createDoorway(maintenance, "WallNorth", 6, 8)

	-- Enemy spawns in maintenance corridor
	spawnEnemySpawn(Vector3.new(-20, 2, -50), maintenance)
	spawnEnemySpawn(Vector3.new(20, 2, -50), maintenance)
	spawnEnemySpawn(Vector3.new(0, 2, -60), maintenance)

	-- SECURITY OFFICE (North) - 30x30 studs
	local security = createRoom("SecurityOffice", Vector3.new(30, 12, 30), Vector3.new(0, 6, 55), "Dark stone grey")
	security.Parent = mallRoot
	createDoorway(security, "WallSouth", 6, 8)

	-- Loot crate in security office (high value area)
	spawnLootCrate(Vector3.new(0, 3, 60), security)

	-- Barricade anchor at security entrance
	spawnBarricadeAnchor(Vector3.new(0, 7, 40), Vector3.new(0, 0, 0), security)

	-- Add some ambient lighting
	local lighting = game:GetService("Lighting")
	if not lighting:FindFirstChild("MallAmbientLight") then
		local ambientLight = Instance.new("Part")
		ambientLight.Name = "MallAmbientLight"
		ambientLight.Size = Vector3.new(1, 1, 1)
		ambientLight.Position = Vector3.new(0, 50, 0)
		ambientLight.Anchored = true
		ambientLight.Transparency = 1
		ambientLight.CanCollide = false
		ambientLight.Parent = mallRoot

		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 2
		pointLight.Range = 100
		pointLight.Color = Color3.fromRGB(255, 255, 255)
		pointLight.Parent = ambientLight
	end

	print("[MallBuilder] Mall construction complete!")
	print("[MallBuilder] - Atrium: 4 spawn points")
	print("[MallBuilder] - Toy Galaxy: 3 loot crates, 1 barricade anchor")
	print("[MallBuilder] - Food Court: 2 loot crates, 1 barricade anchor")
	print("[MallBuilder] - Maintenance Corridor: 3 enemy spawns")
	print("[MallBuilder] - Security Office: 1 loot crate, 1 barricade anchor")
end

-- Build on server start
task.defer(function()
	MallBuilder.build()
end)

return MallBuilder
