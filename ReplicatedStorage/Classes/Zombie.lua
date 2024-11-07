local Zombie = {}
Zombie.__index = Zombie

-- Construtor
function Zombie.new(model, mapa, zombiesFolder, whitelistedNames)
	local self = setmetatable({}, Zombie)

	self.model = model -- Model do zumbi
	
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
function Zombie:ChasePlayer()
	local humanoid = self.model:FindFirstChild("Humanoid")
	local distanciamax = 1000
	local distanciamin = 1 -- Distância mínima antes de atacar
	local isAlive = self.model.Config.isAlive.Value

	self.zombieAnimator:playAnimation("chaseAnim")
	
	while true do
		wait(0.1)

		
		-- Procura o jogador mais próximo
		local closestPlayer, closestDistance = nil, distanciamax
		for _, player in pairs(game.Players:GetPlayers()) do
			local character = player.Character
			local playerRoot = character and character:FindFirstChild("HumanoidRootPart")

		
			-- Verificacao pra parar caso nao tiver vivo
			if not isAlive or not self.model:FindFirstChild("HumanoidRootPart") then
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
			humanoid:MoveTo(closestPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, distanciamin, 0))

			if closestDistance <= distanciamin + 1.5 and not self.attacking then
				self:attackPlayer(closestPlayer)
			end
		end
	end	
end

-- Método para som de ataque do zumbi
function Zombie:playAttackSound()
	-- Randomiza o som de ataque da lista
	local soundFolder = game.ReplicatedStorage.Sounds.ZombieAttack
	local soundList = soundFolder:GetChildren()

	local randomSound = soundList[math.random(1, #soundList)]
	self.sound:playSound(randomSound, 1, false)
end


function Zombie:verifyDestroy()
	local humanoid = self.model:FindFirstChild("Humanoid")
	local isAlive = self.model.Config.isAlive
	
	humanoid.Died:Connect(function()

		isAlive.Value = false

		print("Excluindo zumbi...")
		wait(1)
		self.model:Destroy()

	end)
	
end


return Zombie
