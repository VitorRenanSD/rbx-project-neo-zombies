local Zombie = {}
Zombie.__index = Zombie

-- Construtor
function Zombie.new(model, mapa, zombiesFolder, whitelistedNames)
	local self = setmetatable({}, Zombie)

	self.model = model -- Model do zumbi
	self.humanoid = model:WaitForChild("Humanoid")
	self.isAlive = self.model.Config.isAlive
	
	self.mapa = mapa  -- Puxa a pasta mapa, onde tem as configs
	self.lastHitTime = 0 
	self.cooldown = 2
	self.zombiesFolder = zombiesFolder -- Pasta onde ficam os zumbis
	self.whitelistedNames = whitelistedNames -- Nomes que não serão atacados pelos zumbis
	self.attacking = false -- Indica se o zumbi está atacando

	-- Chama as classes necessárias e suas instâncias
	self.SoundClass = require(game.ReplicatedStorage.Classes.Sound)
	self.ZombieAnimatorClass = require(game.ReplicatedStorage.Classes.ZombieAnimator)

	self.zombieAnimator = self.ZombieAnimatorClass.new(model)
	self.sound = self.SoundClass.new()

	return self
end


-- Método para atacar o jogador
function Zombie:attackPlayer(player)
	local currentTime = tick()

	-- Verifica se o cooldown de ataque já passou
	if currentTime - self.lastHitTime >= self.cooldown then
		self.lastHitTime = currentTime
		self.attacking = true

		-- Acha o Humanoid do jogador
		local humanoid = player.Character:FindFirstChild("Humanoid")

		if humanoid then
			-- Calcula o dano de acordo com a wave atual 
			local zombieATK = self.model.Config.attackDamage.Value
			local attackDamage = zombieATK + (0.6 * (self.mapa.Config.currentWave.Value))

			-- Aplica o dano, animacao e som
			self.zombieAnimator:playAnimation("attackAnim")
			self:playAttackSound()
			humanoid:TakeDamage(attackDamage)

			print("HITADO EM " .. attackDamage .. " pelo " .. self.model.Name)

		end
		
		self.zombieAnimator:stopAnimation("attackAnim")
		self.attacking = false
		
	else
		print("Em cooldown")
	end
end


-- Método para perseguir o jogador, usa attackPlayer()
function Zombie:chasePlayer()
	local distanciamax = 1000
	local minAttackDistance = 2.5 -- em studs

	self.zombieAnimator:playAnimation("chaseAnim")
	
	while true do
		wait(0.1)

		-- Procura o jogador mais próximo
		local closestPlayer, closestDistance = nil, distanciamax
		for _, player in pairs(game.Players:GetPlayers()) do
			local character = player.Character
			local playerRoot = character and character:FindFirstChild("HumanoidRootPart")

			-- Verificacao pra parar caso nao tiver vivo
			if not self.isAlive.Value or not self.model.HumanoidRootPart then
				break
			end
			
			local zombieRootPart = self.model.HumanoidRootPart
			
			if playerRoot then
				local distance = (playerRoot.Position - zombieRootPart.Position).Magnitude
				if distance < closestDistance then
					closestPlayer, closestDistance = player, distance
				end
			end
		end

		-- Se encontrar um jogador dentro do range, move o zumbi e verifica se deve atacar
		if closestPlayer and closestDistance <= distanciamax then
			self.humanoid:MoveTo(closestPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 0, 0))

			if closestDistance <= minAttackDistance and not self.attacking then
				self:attackPlayer(closestPlayer)
			end
		end
	end	
end

-- Método para escolher som de ataque do zumbi
function Zombie:playAttackSound()
	local soundFolder = game.ReplicatedStorage.Sounds.ZombieAttack
	local soundList = soundFolder:GetChildren()
	
	-- Randomiza o som de ataque, escolhendo um da lista
	local randomSound = soundList[math.random(1, #soundList)]
	self.sound:playSound(randomSound, 1, false)
	
end


-- Metodo para excluir zumbi caso morto
function Zombie:verifyDestroy()
	-- Quando morto, inicia:
	self.humanoid.Died:Connect(function() 
		
		-- Altera a variável isAlive para FALSO
		self.isAlive.Value = false

		-- Aguarda 1 segundo e exclui o proprio
		print("Excluindo zumbi...")
		wait(1)
		self.model:Destroy()

	end)
	
end


return Zombie
