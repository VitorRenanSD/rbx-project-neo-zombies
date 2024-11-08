local WeaponAnimator = {}
WeaponAnimator.__index = WeaponAnimator

-- Construtor do Animator
function WeaponAnimator.new(model, tool)
	local self = setmetatable({}, WeaponAnimator)


	self.model = model
	self.animations = {}  -- Array pra guardar as animacoes carregadas
	self.animator = model:FindFirstChild("Humanoid"):FindFirstChildOfClass("Animator")
	self.tool = tool


	if not self.animator then
		warn("sem nenhum Animator no " .. self.model.Name)
	end

	-- Carrega as animacoes da tool
	for _, anim in ipairs(self.tool:GetChildren()) do

		if anim:IsA("Animation") then
			self.animations[anim.Name] = self.animator:LoadAnimation(anim)
		end

	end


	return self
end


-- Inicia a animacao tal
function WeaponAnimator:playAnimation(animationName)

	local animationTrack = self.animations[animationName]

	if animationTrack then
		animationTrack:Play()

	else
		warn(animationName .. " n encontrada no modelo " .. self.model.Name)
	end

end


-- Para a animacao tal
function WeaponAnimator:stopAnimation(animationName)

	local animationTrack = self.animations[animationName]

	if animationTrack then

		animationTrack:Stop()

	end

end


return WeaponAnimator
