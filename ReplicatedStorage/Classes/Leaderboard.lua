local Leaderboard = {}
Leaderboard.__index = Leaderboard

local DataStoreService = game:GetService("DataStoreService")
local playerStatsDataStore = DataStoreService:GetDataStore("PlayerStats")

-- Construtor
function Leaderboard.new(player)
	local self = setmetatable({}, Leaderboard)
	self.player = player

	-- Cria a pasta leaderstats
	self.leaderstats = Instance.new("Folder")
	self.leaderstats.Name = "leaderstats"
	self.leaderstats.Parent = player


	-- Cria os valores Deaths e Minutes
	self.deaths = Instance.new("IntValue")
	self.deaths.Name = "Deaths"
	self.deaths.Parent = self.leaderstats

	self.minutes = Instance.new("IntValue")
	self.minutes.Name = "Minutes"
	self.minutes.Parent = self.leaderstats


	self:LoadPlayerStats()
	self:StartMinuteTracking()

	return self
end

-- Metodo q carrega numeros do player
function Leaderboard:LoadPlayerStats()
	
	local success, data = pcall(function()
		return playerStatsDataStore:GetAsync(self.player.UserId)
	end)

	if success and data then
		self.deaths.Value = data.Deaths or 0
		self.minutes.Value = data.Minutes or 0
	else
		warn("Erro ao carregar os dados do jogador: " .. tostring(self.player.UserId))
	end
	
end


-- Metodo q salva os numeros do player
function Leaderboard:SavePlayerStats()
	
	local success, errorMessage = pcall(function()
		
		playerStatsDataStore:SetAsync(self.player.UserId, {
			
			Deaths = self.deaths.Value,
			Minutes = self.minutes.Value
			
		})
		
	end)

	if not success then
		warn("Erro ao salvar os dados do jogador: " .. errorMessage)
	end
	
end

-- Metodo pra iniciar o contador de minutos
function Leaderboard:StartMinuteTracking()
	
	spawn(function()
		while self.player.Parent do
			wait(60) -- Espera 60 segundos
			self.minutes.Value = self.minutes.Value + 1
		end
	end)
	
end

return Leaderboard
