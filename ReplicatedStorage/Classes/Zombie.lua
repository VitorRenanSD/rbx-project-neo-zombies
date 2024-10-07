local Zombie = {}
Zombie.__index = Zombie

-- Construtor
function Zombie.new(model, mapa, zombiesFolder, whitelistedNames)
	local self = setmetatable({}, Zombie)

	if not model:FindFirstChild("Humanoid") or not model:FindFirstChild("HumanoidRootPart") then
		warn("Modelo de zumbi n tem Humanoid ou HumanoidRootPart")
	end

	self.model = model -- Model do zumbi
	self.mapa = mapa  -- Puxa a pasta mapa, onde tem as configs
	self.lastHitTime = 0 
	self.cooldown = 2 -- Tempo de cooldown entre ataques
	self.zombiesFolder = zombiesFolder -- Pasta onde fica os zumbis
	self.zombieHitbox = model:FindFirstChild("Hitbox") -- Objeto Hitbox de cada zumbi
	self.whitelistedNames = whitelistedNames -- Nomes que não serao atacados pelos zumbis
	self.attacking = false -- Indica se o zumbi está atacando

	return self
end


-- Metodo para atacar o jogador
function Zombie:attackPlayer(player)
	local currentTime = tick()

	-- Verifica se o cooldown de ataque ja passou
	if currentTime - self.lastHitTime >= self.cooldown then
		self.lastHitTime = currentTime

		-- Acha o Humanoid do jogador
		local humanoid = player.Character:FindFirstChild("Humanoid")

		if humanoid then
			
			-- Calcula o dano de acordo com a wave atual 
			local zombieATK = self.model.Config.attackDamage.Value
			local attackDamage = zombieATK + (1.6 * (self.mapa.Config.currentWave.Value - 1))
			
			-- Aplica o dano
			humanoid:TakeDamage(attackDamage)
			print(player.Name .. " HITADO EM " .. attackDamage .. " DE DANO")

		else
			warn("Humanoid não encontrado no jogador " .. player.Name)
		end

	else
		print("Em cooldown")
	end
end


-- Metodo para perseguir o jogador, usa attackPlayer()
function Zombie:ChasePlayer()
	local distanciamax = 1000 
	local distanciamin = 1 -- Distancia mínima antes de atacar

	while true do
		wait(0.1)
		local closestPlayer = nil
		local closestDistance = distanciamax

		if not self.model or not self.model:FindFirstChild("HumanoidRootPart") then
			warn("Zombie model is missing HumanoidRootPart")
			break
		end

		-- Procura o jogador mais proximo
		for _, player in pairs(game.Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local distance = (player.Character.HumanoidRootPart.Position - self.model.HumanoidRootPart.Position).Magnitude

				if distance < closestDistance then
					closestPlayer = player
					closestDistance = distance
				end
			end
		end

		-- Se encontrar um jogador dentro do range, move o zumbi e verifica se deve atacar
		if closestPlayer then
			local humanoid = self.model:FindFirstChild("Humanoid")

			if humanoid then
				humanoid:MoveTo(closestPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, distanciamin, 0))

				-- Se o zumbi estiver suficientemente perto e nao estiver atacando
				if closestDistance <= distanciamin + 1 and not self.attacking then
					self:attackPlayer(closestPlayer)
				end

			else
				warn("Zombie model is missing Humanoid")
			end
		end
	end
end


-- Metodo para dar Destroy no zumbi caso Humanoid.health = 0
--function Zombie:destroyZombie()
-- PARA FAZER
-- PARA FAZER
-- PARA FAZER
-- PARA FAZER
-- PARA FAZER
-- PARA FAZER
-- PARA FAZER

return Zombie
