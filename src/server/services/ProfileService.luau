--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)
local ProfileRules = require(shared.profile.ProfileRules)
local LevelRules = require(shared.rules.LevelRules)

local store = DataStoreService:GetDataStore(GameConfig.Persistence.DataStoreName)

local ProfileService = {}

local profiles: { [Player]: any } = {}
local revisions: { [Player]: number } = {}
local savedRevisions: { [Player]: number } = {}
local loading: { [Player]: boolean } = {}
local saving: { [Player]: boolean } = {}

local function keyFor(player: Player): string
	return ("u_%d"):format(player.UserId)
end

local function retryDelay(attempt: number)
	task.wait(GameConfig.Persistence.RetryBaseSeconds * (2 ^ math.max(0, attempt - 1)))
end

local function getWithRetry(player: Player): (boolean, any, any)
	local lastError = nil
	for attempt = 1, GameConfig.Persistence.LoadAttempts do
		local raw = nil
		local ok, err = pcall(function()
			raw = store:GetAsync(keyFor(player))
		end)
		if ok then
			return true, raw, nil
		end
		lastError = err
		if attempt < GameConfig.Persistence.LoadAttempts then
			retryDelay(attempt)
		end
	end
	return false, nil, lastError
end

local function setWithRetry(player: Player, snapshot: any): (boolean, any)
	local lastError = nil
	for attempt = 1, GameConfig.Persistence.SaveAttempts do
		local ok, err = pcall(function()
			store:SetAsync(keyFor(player), snapshot)
		end)
		if ok then
			return true, nil
		end
		lastError = err
		if attempt < GameConfig.Persistence.SaveAttempts then
			retryDelay(attempt)
		end
	end
	return false, lastError
end

local function loadProfile(player: Player)
	if loading[player] or profiles[player] then
		return
	end

	loading[player] = true
	player:SetAttribute("GravityProfileReady", false)
	player:SetAttribute("GravityProfileLoadFailed", false)

	local ok, raw, err = getWithRetry(player)
	if not ok then
		loading[player] = nil
		player:SetAttribute("GravityProfileLoadFailed", true)
		warn(("[+1 Gravity] profile load failed for %d after retries: %s"):format(player.UserId, tostring(err)))
		if player.Parent == Players then
			player:Kick("Your save data could not be loaded safely. Please rejoin in a moment.")
		end
		return
	end

	local profile = ProfileRules.normalize(raw, os.time())
	local normalizedLevel = profile.Level
	profile.Level = LevelRules.levelFromXp(profile.XP)

	profiles[player] = profile
	local needsWrite = raw == nil or ProfileRules.needsMigration(raw) or normalizedLevel ~= profile.Level
	revisions[player] = if needsWrite then 1 else 0
	savedRevisions[player] = 0
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
		revisions[player] = (revisions[player] or 0) + 1
	end
end

function ProfileService.save(player: Player): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end

	while saving[player] do
		if player.Parent ~= Players and not profiles[player] then
			return false
		end
		task.wait()
	end

	local revision = revisions[player] or 0
	if revision <= (savedRevisions[player] or 0) then
		return true
	end

	saving[player] = true
	local snapshot = ProfileRules.snapshot(profile, os.time())
	local ok, err = setWithRetry(player, snapshot)
	saving[player] = nil

	if not ok then
		warn(("[+1 Gravity] profile save failed for %d after retries: %s"):format(player.UserId, tostring(err)))
		return false
	end

	savedRevisions[player] = math.max(savedRevisions[player] or 0, revision)
	return true
end

function ProfileService.start()
	Players.PlayerAdded:Connect(function(player)
		task.spawn(loadProfile, player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(loadProfile, player)
	end

	Players.PlayerRemoving:Connect(function(player)
		ProfileService.save(player)
		profiles[player] = nil
		revisions[player] = nil
		savedRevisions[player] = nil
		loading[player] = nil
		saving[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(GameConfig.Persistence.AutoSaveSeconds)
			for player in profiles do
				task.spawn(function()
					ProfileService.save(player)
				end)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for player in profiles do
			pending += 1
			task.spawn(function()
				ProfileService.save(player)
				pending -= 1
			end)
		end

		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

return ProfileService
