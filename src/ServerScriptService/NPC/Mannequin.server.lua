-- Mannequin.server.lua
-- Basic enemy AI stub for testing barricades

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")

local Signals = require(ReplicatedStorage.Shared.Signals)

local activeEnemies = {}
local DAMAGE_AMOUNT = 1
local ATTACK_COOLDOWN = 2 -- seconds between attacks
local SPAWN_TAG = "EnemySpawn"

local function createMannequin(spawnPoint)
	local mannequin = Instance.new("Model")
	mannequin.Name = "Mannequin"

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.BrickColor = BrickColor.new("Dark stone grey")
	torso.Material = Enum.Material.Concrete
	torso.Position = spawnPoint.Position + Vector3.new(0, 3, 0)
	torso.Parent = mannequin

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1, 1, 1)
	head.Shape = Enum.PartType.Ball
	head.BrickColor = BrickColor.new("White")
	head.Position = torso.Position + Vector3.new(0, 1.5, 0)
	head.Parent = mannequin

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 50
	humanoid.Health = 50
	humanoid.WalkSpeed = 8
	humanoid.Parent = mannequin

	-- Weld head to torso
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = head
	weld.Parent = torso

	mannequin.PrimaryPart = torso
	mannequin.Parent = workspace

	return mannequin
end

local function findTarget()
	-- Find nearest player or barricade anchor
	local players = Players:GetPlayers()
	local nearestPlayer = nil
	local minDist = math.huge

	for _, player in ipairs(players) do
		local char = player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local dist = (char.HumanoidRootPart.Position).Magnitude
			if dist < minDist then
				minDist = dist
				nearestPlayer = char.HumanoidRootPart
			end
		end
	end

	-- For now, prioritize players. In Sprint 2, add logic to target barricades
	return nearestPlayer
end

local function attackBoard(mannequin, board)
	if not board or not board.Parent then
		return
	end

	if _G.BarricadeSystem and _G.BarricadeSystem.damageBoard then
		_G.BarricadeSystem.damageBoard(board, DAMAGE_AMOUNT)
		print("[Mannequin] Damaged board, durability remaining:", board:FindFirstChild("Durability").Value)
		-- TODO: Play attack SFX here
	end
end

local function behaviorLoop(mannequin)
	local humanoid = mannequin:FindFirstChild("Humanoid")
	local torso = mannequin:FindFirstChild("Torso")
	if not humanoid or not torso then
		mannequin:Destroy()
		return
	end

	local lastAttackTime = 0

	while mannequin.Parent and humanoid.Health > 0 do
		local target = findTarget()
		if target then
			-- Pathfind toward target
			local path = PathfindingService:CreatePath({
				AgentRadius = 2,
				AgentHeight = 5,
				AgentCanJump = false,
			})
			local success, errorMsg = pcall(function()
				path:ComputeAsync(torso.Position, target.Position)
			end)

			if success and path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()
				for _, waypoint in ipairs(waypoints) do
					if not mannequin.Parent or humanoid.Health <= 0 then
						return
					end
					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()
				end
			end

			-- Check if close enough to attack a board
			local nearbyParts = workspace:GetPartBoundsInRadius(torso.Position, 5)
			for _, part in ipairs(nearbyParts) do
				if part.Name == "Board" and os.clock() - lastAttackTime >= ATTACK_COOLDOWN then
					attackBoard(mannequin, part)
					lastAttackTime = os.clock()
					break
				end
			end
		end

		task.wait(1) -- Update pathfinding every second
	end

	-- Enemy died
	mannequin:Destroy()
end

local function spawnEnemies()
	local spawnPoints = CollectionService:GetTagged(SPAWN_TAG)
	if #spawnPoints == 0 then
		warn("[Mannequin] No spawn points tagged with 'EnemySpawn'")
		return
	end

	-- Spawn 2-3 enemies per night (simple stub)
	local spawnCount = math.random(2, 3)
	for i = 1, spawnCount do
		local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
		local mannequin = createMannequin(spawnPoint)
		table.insert(activeEnemies, mannequin)
		task.spawn(behaviorLoop, mannequin)
		print("[Mannequin] Spawned enemy #" .. i)
	end
end

local function despawnAllEnemies()
	for _, enemy in ipairs(activeEnemies) do
		if enemy and enemy.Parent then
			enemy:Destroy()
		end
	end
	activeEnemies = {}
	print("[Mannequin] All enemies despawned for day")
end

-- Spawn enemies when night starts
Signals.NightStarted.Event:Connect(function(nightCount)
	print("[Mannequin] Night " .. nightCount .. " - spawning enemies")
	spawnEnemies()
end)

-- Despawn enemies when day starts
Signals.DayStarted.Event:Connect(function()
	print("[Mannequin] Day started - despawning enemies")
	despawnAllEnemies()
end)
