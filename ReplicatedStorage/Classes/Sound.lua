local Sound = {}
Sound.__index = Sound

-- Construtor
function Sound.new()
	local self = setmetatable({}, Sound)
	
	return self
end


-- Metodo pra tocar sons, qualquer som
function Sound:playSound(location, volume, looped)
	
	if not location then
		warn("Sound not found: " .. tostring(location))
		return
	end
	
	if not workspace:FindFirstChild("ActiveSounds") then
		warn("ActiveSounds folder not found")
		return
	end
	
	
	-- Clona o som para criar uma instancia independente
	local sound = location:Clone()
	sound.Parent = workspace.ActiveSounds
	sound.Volume = volume
	sound.Looped = looped
	
	sound:Play()


	-- Exclui apos o uso, caso nao estiver em loop
	if not looped then

		sound.Ended:Connect(function()
			sound:Destroy()
		end)

	end

end


return Sound
