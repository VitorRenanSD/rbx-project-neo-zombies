-- ModuleScript: ReplicatedStorage/Classes/WaveManager

local WaveManager = {}
WaveManager.__index = WaveManager

-- Construtor
function WaveManager.new(map, spawnLocation, config, zombieModels)
    local self = setmetatable({}, WaveManager)
    self.map = map  -- Config do mapa
    self.spawnLocation = spawnLocation  -- Local de spawn dos zumbis
    self.config = config  -- Configurações do jogo (como número de ondas)
    self.zombieModels = zombieModels  -- Modelos dos zumbi
    self.canStartNewWave = true  -- Controla quando pode iniciar nova wave
    return self
end

-- Função para spawnar zombies
function WaveManager:createZombies(waveAtual, numZombies)
    
    -- Escolhendo os inimigos de acordo com o nível de onda
    local zombiesPerWave = {}
    
    for _, Zombie in pairs(self.zombieModels) do
        
        -- Spawna quem tem configurado onda mínima menor ou igual à atual
        if Zombie.Config.waveSpawn.Value <= waveAtual then
            table.insert(zombiesPerWave, Zombie)
        end
        
    end
    
    -- Listar os pontos de spawn para usar abaixo
    local spawnPoints = self.spawnLocation:GetChildren()
    
    -- Spawnando os inimigos
    for i = 1, numZombies do
        
        local chosenZombie = zombiesPerWave[math.random(1, #zombiesPerWave)]
        
        -- Zombie será spawnado dentro de ZombiesAlive (pasta)
        local newZombie = chosenZombie:Clone()
        newZombie.Parent = self.map.ZombiesAlive
        
        if newZombie.PrimaryPart then
            
            -- Escolher um ponto de spawn random
            local randomSpawnPoint = spawnPoints[math.random(1, #spawnPoints)]
            -- Spawna nesse ponto escolhido
			newZombie:SetPrimaryPartCFrame(CFrame.new(randomSpawnPoint.Position) + Vector3.new(0, 1, 0))
			
			-- Puxando os valores de atk, hp e movespeed do Config dentro de model
			local zombieConfig = newZombie:WaitForChild("Config")
			local zombieHP = zombieConfig.health.Value
			local zombieMS = zombieConfig.moveSpeed.Value

			-- Formula pra multiplicador de atributos, difculdade no jogo
			local maxHealth = zombieHP + (8 * self.config.currentWave.Value)
			local moveSpeed = zombieMS + (0.4 * self.config.currentWave.Value)

			-- Adiciona os valores de HP e MS
			local humanoid = newZombie:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.MaxHealth = maxHealth
				humanoid.Health = maxHealth
				humanoid.WalkSpeed = moveSpeed
			end

		else
            warn("Zombie está sem PrimaryPart")
        end
        
        wait(0.3)
    end
end

-- Função para criar uma nova wave
function WaveManager:createNewWave()
    self.canStartNewWave = false
    wait(5)
    
    self.config.currentWave.Value = self.config.currentWave.Value + 1
    print("Wave atual: " .. self.config.currentWave.Value)
    
    -- Fórmula para quantidade de zumbis * waveAtual
    local currentWave = self.config.currentWave.Value
    local quantZombies = math.random(4, 6) * currentWave
    
    self:createZombies(currentWave, quantZombies)
    
    wait(10)
    self.canStartNewWave = true
end

-- Loop para criar waves
function WaveManager:startWaveLoop()
    local RunService = game:GetService("RunService")
    RunService.Stepped:Connect(function()
        
        local remainingZombies = #(self.map:WaitForChild("ZombiesAlive"):GetChildren())
        
        -- Já chegou ao número máximo de ondas (Mapa/Config/MaxWaves)
        if self.config.currentWave.Value >= self.config.maxWaves.Value and remainingZombies == 0 then
            print("Fim do jogo. ganhou!")
        
        -- Ainda não chegou ao número máximo de ondas
        else
            
            -- Existe inimigos no mapa?
            if (remainingZombies == 0) and self.canStartNewWave == true then
                self:createNewWave()
			end
			
		end
		
	end)
	
end

return WaveManager
