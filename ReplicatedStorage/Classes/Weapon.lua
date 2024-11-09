local Weapon = {}
Weapon.__index = Weapon

-- Construtor
function Weapon.new(tool) -- construtor da classe 
	local self = setmetatable({}, Weapon)
	
	
	self.tool = tool
	self.config = tool:WaitForChild("Config") -- pegar as configuraçoes da arma
	self.fireRate = self.config:WaitForChild("fireRate").Value
	self.handle = tool:WaitForChild("Handle")
	self.canFire = true -- bolleano que indica se vai desparar ou nao
	self.holdMouse = false
	self.fireEvent = game.ReplicatedStorage:WaitForChild("fireEvent") 
	
	self.SoundClass = require(game.ReplicatedStorage.Classes.Sound)
	self.sound = self.SoundClass.new()
	self.WeaponAnimatorClass = require(game.ReplicatedStorage.Classes.WeaponAnimator)
	self.weaponAnimator = self.WeaponAnimatorClass.new(tool, tool)
	
	self:connectEvents()
	
	
	return self
end

function Weapon:connectEvents()
	self.tool.Equipped:Connect(function()
		self:initializeWeapon() -- Usa o método fire da classe Weapon
	end)
	self.tool.Unequipped:Connect(function()
		self:stopAutoFire()
	end)
end

function Weapon:initializeWeapon()
	local player = game:GetService("Players").LocalPlayer
	local mouse = player:GetMouse()

	mouse.Button1Down:Connect(function()
		if self.tool:IsDescendantOf(player.Character) then
			self:startAutoFire(player)
			self.weaponAnimator:playAnimation("fireAnim")
		end
	end)
	mouse.Button1Up:Connect(function()
		self:stopAutoFire()
	end)
end

function Weapon:autoFire(player)
	while self.holdMouse and self.tool:IsDescendantOf(player.Character) do
		if self.canFire then
			
			self.canFire = false

			local mouse = player:GetMouse()
			local posicaoMouse = mouse.Hit.Position
			
			self:fire(player, posicaoMouse) -- Usa o método fire da classe Weapon
	
			-- Parte visual do impacto
			local Part = Instance.new('Part')
			Part.Parent = workspace
			Part.Position = posicaoMouse
			Part.Material = Enum.Material.Neon
			Part.Color = Color3.fromRGB(255, 255, 0)
			Part.Size = Vector3.new(0.2, 0.2, 0.2)
			Part.Anchored = true
			Part.CanCollide = false
			Part.Transparency = 0.5

			wait(self.fireRate)
			Part:Destroy(0.75)

			self.canFire = true
		end
		wait()
	end
end

-- Função para ativar disparo contínuo
function Weapon:startAutoFire(player)
	self.holdMouse = true
	self:autoFire(player) -- Inicia o disparo automático

end

-- Função para parar disparo contínuo
function Weapon:stopAutoFire()
	self.holdMouse = false
	
end

-- Método para disparar
function Weapon:fire(player, posicaoMouse)

	local SFX = game.ReplicatedStorage.Sounds.SFX
	self.sound:playSound(SFX.fire, 0.5, false)

	local RCparams = RaycastParams.new()
	RCparams.FilterType = Enum.RaycastFilterType.Blacklist
	RCparams.FilterDescendantsInstances = {self.tool.Parent}
	local rayDirection = (posicaoMouse - self.handle.Position).Unit * self.config.range.Value
	local RaycastResult = workspace:Raycast(self.handle.Position, rayDirection, RCparams)

	if RaycastResult and RaycastResult.Instance then
		local hitInstance = RaycastResult.Instance
		if hitInstance.Parent:FindFirstChild("Humanoid") then
			local zombieHumanoid = hitInstance.Parent:FindFirstChildWhichIsA("Humanoid")
			local baseDamage = self.config.damage.Value

			-- Aplica dano
			if hitInstance.Name == "Head" then
				self.sound:playSound(SFX.headshot, 0.5, false)
				zombieHumanoid:TakeDamage(baseDamage * 2)
				print(self.tool.Name .. " deu " .. baseDamage * 2 .. " de dano (Headshot)")
			else
				zombieHumanoid:TakeDamage(baseDamage)
				print(self.tool.Name .. " deu " .. baseDamage .. " de dano")
			end

		end
	end
end



return Weapon
