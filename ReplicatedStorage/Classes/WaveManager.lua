local WaveManager = {}
WaveManager.__index = WaveManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Construtor
function WaveManager.new(map, config, zombieModels, player)
	local self = setmetatable({}, WaveManager)

	self.map = map  -- pasta Mapa no workspace
	self.config = config

	self.zombieModels = zombieModels  -- Modelos dos zumbis
	self.player = player

	self.canStartNewWave = true  -- Controla quando pode iniciar nova wave

	-- Instancia das classes que estao sendo usadas dentro de WaveManager
	self.ZombieClass = require(game.ReplicatedStorage.Classes.Zombie)
	self.SoundClass = require(game.ReplicatedStorage.Classes.Sound)
	self.PlayerClass = require(game.ReplicatedStorage.Classes.Player)

	-- Lista branca para os zumbis, para eles não se baterem no chasePlayer()
	self.whitelistedNames = {"Classic Zombie", "Crawler Zombie", "Tank Zombie"}

	return self
end

-- Método para spawnar zumbis
function WaveManager:createZombies(waveAtual, numZombies)
	local zombiesPerWave = {}

	-- Escolhendo os inimigos de acordo com o nível de onda
	for _, Zombie in pairs(self.zombieModels) do
		if Zombie.Config.waveSpawn.Value <= waveAtual then
			table.insert(zombiesPerWave, Zombie)
		end
	end

	-- Lista os pontos de spawn
	local spawnPoints = self.map.SpawnLocation:GetChildren()

	-- Spawnando os zumbis
	for i = 1, numZombies do
		local chosenZombie = zombiesPerWave[math.random(1, #zombiesPerWave)]
		local newZombie = chosenZombie:Clone()
		newZombie.Parent = self.map.ZombiesAlive

		if newZombie.PrimaryPart then
			-- Escolhe um ponto de spawn aleatório
			local randomSpawnPoint = spawnPoints[math.random(1, #spawnPoints)]
			newZombie:SetPrimaryPartCFrame(CFrame.new(randomSpawnPoint.Position) + Vector3.new(0, 1, 0))

			-- Puxa os valores de hp e movespeed do Config dentro do model de Zumbi
			local zombieConfig = newZombie:WaitForChild("Config")
			local zombieHP = zombieConfig.health.Value
			local zombieMS = zombieConfig.moveSpeed.Value

			-- Fórmula para multiplicador de HP e MS por wave
			local maxHealth = zombieHP + (10 * self.config.currentWave.Value)
			local moveSpeed = zombieMS + (1.2 * self.config.currentWave.Value)

			-- Adiciona os valores de HP e MS
			local humanoid = newZombie:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.MaxHealth = maxHealth
				humanoid.Health = maxHealth
				humanoid.WalkSpeed = moveSpeed
			end

			-- Inicia o chasePlayer, logo após spawnar
			local zombieInstance = self.ZombieClass.new(newZombie, self.map, self.map.ZombiesAlive, self.whitelistedNames)
			coroutine.wrap(function()
				zombieInstance:ChasePlayer()
			end)()

			wait(0.3)
		else
			warn("Zombie está sem PrimaryPart")
		end
	end
end

-- Método para criar uma nova wave
function WaveManager:createNewWave()
	self.canStartNewWave = false
	wait(1)

	self.config.currentWave.Value = self.config.currentWave.Value + 1
	print("Wave atual: " .. self.config.currentWave.Value)

	-- Dispara o evento remoto para atualizar o HUD do cliente
	local updateWaveHUD = ReplicatedStorage:WaitForChild("UpdateWaveHUD")
	updateWaveHUD:FireAllClients(self.config.currentWave.Value)

	-- Determina a quantidade de zumbis da próxima wave
	local currentWave = self.config.currentWave.Value
	local quantZombies = math.random(4, 6) * (currentWave * 0.75)

	self:createZombies(currentWave, quantZombies)

	wait(5)
	self.canStartNewWave = true
end

-- Loop para criar waves e atualizar HUD de zumbis vivos
function WaveManager:startWaveLoop()
	local sound = self.SoundClass.new()
	local SFX = game.ReplicatedStorage.Sounds.SFX
	local hasWon = false

	RunService.Stepped:Connect(function()
		local remainingZombies = #(self.map:WaitForChild("ZombiesAlive"):GetChildren())

		-- Atualiza o número de zumbis vivos no HUD
		local updateZombieHUD = ReplicatedStorage:WaitForChild("updateZombieHUD")
		updateZombieHUD:FireAllClients(remainingZombies)

		-- Verifica se as condições de vitória foram atingidas
		if self.config.currentWave.Value >= self.config.maxWaves.Value and remainingZombies == 0 and not hasWon then
			hasWon = true
			-- Mensagem de kick e som ao vencer
			local minutes = self.player.leaderstats.Minutes.Value
			
			sound:playSound(SFX.winSound, 1.0, false)
			
			self.player:Kick("You won, but at what cost? You lost like ".. minutes .. " minutes here. GO TOUCH GRASS!!!")

			-- Se ainda não chegou ao número máximo de waves
		else
			if (remainingZombies == 0) and self.canStartNewWave == true and not hasWon then
				
				sound:playSound(SFX.newWave, 0.4, false)
				self:createNewWave()
				
			end
		end
	end)
end

return WaveManager
