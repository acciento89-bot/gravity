--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)
local ProfileRules = require(shared.profile.ProfileRules)
local LevelRules = require(shared.rules.LevelRules)

local store = DataStoreService:GetDataStore(GameConfig.Persistence.DataStoreName)

local ProfileService = {}

local profiles: { [Player]: any } = {}
local dirty: { [Player]: boolean } = {}
local loading: { [Player]: boolean } = {}

local function keyFor(player: Player): string
	return ("u_%d"):format(player.UserId)
end

local function loadProfile(player: Player)
	loading[player] = true
	local raw = nil
	local ok, err = pcall(function()
		raw = store:GetAsync(keyFor(player))
	end)
	if not ok then
		warn(("[+1 Gravity] profile load failed for %d: %s"):format(player.UserId, tostring(err)))
	end

	local profile = ProfileRules.normalize(raw, os.time())
	profile.Level = LevelRules.levelFromXp(profile.XP)
	profiles[player] = profile
	dirty[player] = not ok
	loading[player] = nil
	player:SetAttribute("GravityProfileReady", true)
end

function ProfileService.get(player: Player): any?
	return profiles[player]
end

function ProfileService.isLoading(player: Player): boolean
	return loading[player] == true
end

function ProfileService.markDirty(player: Player)
	if profiles[player] then
		dirty[player] = true
	end
end

function ProfileService.save(player: Player): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	if not dirty[player] then
		return true
	end

	local ok, err = pcall(function()
		store:SetAsync(keyFor(player), profile)
	end)
	if not ok then
		warn(("[+1 Gravity] profile save failed for %d: %s"):format(player.UserId, tostring(err)))
		return false
	end
	dirty[player] = nil
	return true
end

function ProfileService.start()
	Players.PlayerAdded:Connect(loadProfile)
	for _, player in Players:GetPlayers() do
		task.spawn(loadProfile, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		ProfileService.save(player)
		profiles[player] = nil
		dirty[player] = nil
		loading[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(GameConfig.Persistence.AutoSaveSeconds)
			for player in profiles do
				ProfileService.save(player)
			end
		end
	end)

	game:BindToClose(function()
		for player in profiles do
			ProfileService.save(player)
		end
		if RunService:IsStudio() then
			task.wait(0.2)
		end
	end)
end

return ProfileService
