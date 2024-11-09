local WeaponAnimator = {}
WeaponAnimator.__index = WeaponAnimator

-- Construtor do WeaponAnimator
function WeaponAnimator.new(model, tool)
	local self = setmetatable({}, WeaponAnimator)

	self.model = model
	self.animations = {}  -- Array para guardar as animações carregadas
	self.tool = tool

	-- Carrega as animações da tool diretamente
	for _, anim in ipairs(self.tool:GetChildren()) do
		if anim:IsA("Animation") then
			self.animations[anim.Name] = anim  -- Guarda a referência à animação
		end
	end

	return self
end

-- Inicia a animação especificada
function WeaponAnimator:playAnimation(animationName)
	local animationTrack = self.animations[animationName]

	if animationTrack then
		-- Reproduz a animação com o Animator do Character do jogador
		local player = game:GetService("Players").LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local animator = humanoid:FindFirstChildOfClass("Animator")
			if animator then
				local track = animator:LoadAnimation(animationTrack)
				track:Play()
			else
				warn("Nenhum Animator encontrado no personagem do jogador.")
			end
		else
			warn("Nenhum Humanoid encontrado no personagem do jogador.")
		end
	else
		warn("A animação '" .. animationName .. "' não foi encontrada no modelo " .. self.model.Name)
	end
end

-- Para a animação especificada
function WeaponAnimator:stopAnimation(animationName)
	local animationTrack = self.animations[animationName]

	if animationTrack then
		local player = game:GetService("Players").LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local animator = humanoid:FindFirstChildOfClass("Animator")
			if animator then
				local track = animator:LoadAnimation(animationTrack)
				track:Stop()
			end
		end
	end
end

return WeaponAnimator
