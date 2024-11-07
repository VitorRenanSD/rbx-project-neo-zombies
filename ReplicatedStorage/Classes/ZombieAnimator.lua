local ZombieAnimator = {}
ZombieAnimator.__index = ZombieAnimator

-- Construtor do Animator
function ZombieAnimator.new(model)
	local self = setmetatable({}, ZombieAnimator)


	self.model = model
	self.animations = {}  -- Array pra guardar as animacoes carregadas
	self.animator = model:FindFirstChild("Humanoid"):FindFirstChildOfClass("Animator")
	self.tool = model:FindFirstChildOfClass("Tool")


	if not self.animator then
		warn("sem nenhum Animator no " .. self.model.Name)
	end

	-- Carrega as animacoes dentro do zombiemodel
	for _, anim in ipairs(self.model:GetChildren()) do

		if anim:IsA("Animation") then
			self.animations[anim.Name] = self.animator:LoadAnimation(anim)
		end

	end


	return self
end


-- Inicia a animacao tal
function ZombieAnimator:playAnimation(animationName)

	local animationTrack = self.animations[animationName]

	if animationTrack then
		animationTrack:Play()

	else
		warn(animationName .. " n encontrada no modelo " .. self.model.Name)
	end

end


-- Para a animacao tal
function ZombieAnimator:stopAnimation(animationName)

	local animationTrack = self.animations[animationName]

	if animationTrack then

		-- Uma segunda thread pra parar a animacao ao terminar, sem afetar o resto do jogo
		coroutine.wrap(function()
			wait(animationTrack.Length)
			animationTrack:Stop()
		end)()
	end

end


return ZombieAnimator
