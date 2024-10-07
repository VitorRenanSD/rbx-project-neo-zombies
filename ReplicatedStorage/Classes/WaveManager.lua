local WaveManager = {}
WaveManager.__index = WaveManager

-- Construtor
function WaveManager.new(mapa, spawnLocation, config, zombieModels)
	local self = setmetatable({}, WaveManager)

	self.mapa = mapa  -- Config do mapa
	self.spawnLocation = spawnLocation  -- Local de spawn dos zumbis
	self.config = config  -- Configurações do jogo (número de waves, etc)
	self.zombieModels = zombieModels  -- Modelos dos zumbis
	self.canStartNewWave = true  -- Controla quando pode iniciar nova wave


	self.ZombieClass = require(game.ReplicatedStorage.Classes.Zombie)
	-- Chama a classe Zombie
	self.whitelistedNames = {"Classic Zombie", "Crawler Zombie", "Tank Zombie"}
	-- Lista branca para os zumbis, para eles não se baterem no chasePlayer()

	return self
end


-- Metodo para spawnar zombies
function WaveManager:createZombies(waveAtual, numZombies)
	
	local zombiesPerWave = {}
	
	-- Escolhendo os inimigos de acordo com o nível de onda
	for _, Zombie in pairs(self.zombieModels) do
		
		-- Spawna quem tem configurado onda mínima menor ou igual à atual
		if Zombie.Config.waveSpawn.Value <= waveAtual then
			table.insert(zombiesPerWave, Zombie)
		end
		
	end

	-- Lista os pontos de spawn, é usado abaixo
	local spawnPoints = self.spawnLocation:GetChildren()

	-- Spawnando os zumbis
	for i = 1, numZombies do
		local chosenZombie = zombiesPerWave[math.random(1, #zombiesPerWave)]

		-- Zombie será spawnado dentro de Workspace/Mapa/ZombiesAlive
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

	wait(5)
	self.canStartNewWave = true
end


-- Loop para criar waves
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
