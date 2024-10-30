local Player = {}
Player.__index = Player

-- Construtor
function Player.new(player)
	local self = setmetatable({}, Player)
	
	self.player = player
	
	return self
end


-- Metodo para lockar camera em primeira pessoa (usa remoteevent chamado startGame)
function Player:lockFirstPerson()
	
	local player = game.Players.LocalPlayer
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	
end


-- Metodo para kickar o player ao morrer
function Player:kickWhenDie()
	
	self.player.CharacterAdded:Connect(function(character)
		
		local humanoid = character:WaitForChild("Humanoid")
		
		humanoid.Died:Connect(function()
			
			-- +1 no leaderboard
			self.player.leaderstats.Deaths.Value = self.player.leaderstats.Deaths.Value + 1
			
			self.player:Kick("You died! Looks like you're not cut out for this. Want to try again?")
			
		end)
	end)
	
	if self.player.Character then
		self.player.CharacterAdded:Fire(self.player.Character)
	end
	
end

	
function Player:createLeaderboard()
	
	-- Cria a pasta leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = self.player


	-- Cria o valor Deaths e Minutes
	local deaths = Instance.new("IntValue")
	deaths.Name = "Deaths"
	deaths.Value = 0 -- Inicia com 0 mortes
	deaths.Parent = leaderstats

	local minutes = Instance.new("IntValue")
	minutes.Name = "Minutes"
	minutes.Value = 0 -- Inicia com 0 minutos
	minutes.Parent = leaderstats
	
end
	
	
-- Metodo para lanterna no player
function Player:createFlashlight(brightness, range, angle)
	
	local character = self.player.Character or self.player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")
	
	-- Cria o objeto Part pra colocar a luz
	local lightPart = Instance.new("Part", character)
	lightPart.CanCollide = false
	lightPart.Transparency = 1
	lightPart.CFrame = head.CFrame
	lightPart.Name = "Flashlight"
	
	-- Cria o objeto de luz, usando os atributos do metodo
	local light = Instance.new("SpotLight", lightPart)
	light.Brightness = brightness
	light.Range = range
	light.Angle = angle
	light.Color = Color3.fromRGB(0, 251, 255)
	
	
	-- Attachments necessarios pra alinhar a luz em head
	local lightAttachment = Instance.new("Attachment", lightPart)
	local alignPosition = Instance.new("AlignPosition", lightPart)
	alignPosition.Attachment0 = lightAttachment
	alignPosition.Attachment1 = head:WaitForChild("FaceCenterAttachment")
	alignPosition.Responsiveness = 200

	local alignOrientation = Instance.new("AlignOrientation", lightPart)
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = lightAttachment
	alignOrientation.Responsiveness = 200
	
	
	-- Atualiza a luz de acordo com a camera
	local camera = workspace.CurrentCamera
	local connection = camera:GetPropertyChangedSignal("CFrame"):Connect(function()
		alignOrientation.CFrame = camera.CFrame.Rotation
	end)
	
end


-- Metodo para correr com LShift
function Player:shiftToRun(boostedSpeed)
	
	local UserInputService = game:GetService("UserInputService")
	local character = self.player.Character or self.player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Detecta quando o shift é pressionado
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			humanoid.WalkSpeed = boostedSpeed
		end
	end)

	-- Detecta quando o shift é solto
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift then
			humanoid.WalkSpeed = 16 -- Volta a velocidade normal
		end
	end)

end

return Player
