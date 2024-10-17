local WaveManager = {}
WaveManager.__index = WaveManager

-- Constructor
function WaveManager.new(map, spawnLocation, config, zombieModels)
	local self = setmetatable({}, WaveManager)

	self.map = map  -- Folder called "Map" inside Workspace
	self.spawnLocation = spawnLocation  -- Folder used to spawn zombies into the game
	self.config = config  -- Game configs folder (maxWaves, currentWave...)
	self.zombieModels = zombieModels  -- Zombie models folder
	self.canStartNewWave = true  -- Boolean to control when to start next wave

	-- Require Zombie class
	self.ZombieClass = require(game.ReplicatedStorage.Classes.Zombie)
	-- Whitelist with the zombies model names, used to avoid damaging each other
	self.whitelistedNames = {"Classic Zombie", "Crawler Zombie", "Tank Zombie"}

	return self
end


-- Method to spawn zombies
function WaveManager:createZombies(waveAtual, numZombies)
	
	local zombiesPerWave = {}
	
	-- Escolhendo os inimigos de acordo com o nível de onda
	for _, Zombie in pairs(self.zombieModels) do
		
		-- Spawna quem tem configurado onda mínima menor ou igual à atual
		if Zombie.Config.waveSpawn.Value <= waveAtual then
			table.insert(zombiesPerWave, Zombie)
		end
		
	end

	-- List the spawn points inside the folder (Parts)
	local spawnPoints = self.spawnLocation:GetChildren()

	-- Spawning the zombies
	for i = 1, numZombies do
		local chosenZombie = zombiesPerWave[math.random(1, #zombiesPerWave)]

		-- Zombie will be spawned into Workspace/Map/ZombiesAlive
		local newZombie = chosenZombie:Clone()
		newZombie.Parent = self.mapa.ZombiesAlive

		if newZombie.PrimaryPart then
			
			-- Escolhe um ponto de spawn aleatorio
			local randomSpawnPoint = spawnPoints[math.random(1, #spawnPoints)]
			-- Spawna nesse ponto escolhido
			newZombie:SetPrimaryPartCFrame(CFrame.new(randomSpawnPoint.Position) + Vector3.new(0, 1, 0))

			-- Puxa os valores de hp e movespeed do Config dentro do model de Zumbi
			local zombieConfig = newZombie:WaitForChild("Config")
			local zombieHP = zombieConfig.health.Value
			local zombieMS = zombieConfig.moveSpeed.Value

			-- Formula pro multiplicador de HP e MS por wave
			local maxHealth = zombieHP + (10 * self.config.currentWave.Value)
			local moveSpeed = zombieMS + (0.6 * self.config.currentWave.Value)

			-- Adiciona os valores de HP e MS
			local humanoid = newZombie:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.MaxHealth = maxHealth
				humanoid.Health = maxHealth
				humanoid.WalkSpeed = moveSpeed
			end

			-- Inicia o chasePlayer, logo apos spawnar
			local zombieInstance = self.ZombieClass.new(newZombie, self.mapa, self.mapa.ZombiesAlive, self.whitelistedNames)  -- Ajuste aqui
			coroutine.wrap(function()
				zombieInstance:ChasePlayer()
			end)()

		else
			warn("Zombie está sem PrimaryPart")
		end
	end
end


-- Metodo pra criar uma nova wave
function WaveManager:createNewWave()
	self.canStartNewWave = false
	wait(2)

	self.config.currentWave.Value = self.config.currentWave.Value + 1
	print("Wave atual: " .. self.config.currentWave.Value)

	-- Fórmula para quantidade de zumbis * waveAtual
	local currentWave = self.config.currentWave.Value
	local quantZombies = math.random(4, 10) * (currentWave / 2)

	self:createZombies(currentWave, quantZombies)

	wait(2)
	self.canStartNewWave = true
end


-- Loop to create new waves
function WaveManager:startWaveLoop()
	local RunService = game:GetService("RunService")
	RunService.Stepped:Connect(function()
		local remainingZombies = #(self.mapa:WaitForChild("ZombiesAlive"):GetChildren())

		-- Ja chegou ao numero maximo de waves
		if self.config.currentWave.Value >= self.config.maxWaves.Value and remainingZombies == 0 then
			print("Fim do jogo. ganhou!")

		-- Ainda nao chegou ao numero maximo de waves
		else

			if (remainingZombies == 0) and self.canStartNewWave == true then
				self:createNewWave()
			end
		end
	end)
end

return WaveManager
