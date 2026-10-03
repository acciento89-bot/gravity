--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)

local ProfileService = require(script.Parent.ProfileService)
local RemotesService = require(script.Parent.RemotesService)

local LeaderboardService = {}

local localStudioMode = RunService:IsStudio() and game.PlaceId == 0
local highestStore: OrderedDataStore? = nil
local coresStore: OrderedDataStore? = nil
local fastestStore: OrderedDataStore? = nil
local nameCache: { [number]: string } = {}
local queryCooldown: { [Player]: number } = {}

local function ensureStores(): boolean
	if localStudioMode then
		return false
	end
	if highestStore and coresStore and fastestStore then
		return true
	end

	local ok, err = pcall(function()
		highestStore = DataStoreService:GetOrderedDataStore(GameConfig.Leaderboard.HighestGravity)
		coresStore = DataStoreService:GetOrderedDataStore(GameConfig.Leaderboard.TotalCores)
		fastestStore = DataStoreService:GetOrderedDataStore(GameConfig.Leaderboard.FastestCollapse)
	end)
	if not ok then
		warn("[+1 Gravity] leaderboard stores unavailable: " .. tostring(err))
		return false
	end
	return true
end

local function set(store: OrderedDataStore?, player: Player, value: number)
	if not store then
		return
	end
	pcall(function()
		store:SetAsync(tostring(player.UserId), value)
	end)
end

local function record(player: Player)
	if not ensureStores() then
		return
	end
	local profile = ProfileService.get(player)
	if not profile then
		return
	end
	set(highestStore, player, math.floor(profile.HighestGravity))
	set(coresStore, player, math.floor(profile.Cores))
	if profile.BestCollapseSeconds > 0 then
		set(fastestStore, player, math.floor(profile.BestCollapseSeconds))
	end
end

local function username(userId: number): string
	if nameCache[userId] then
		return nameCache[userId]
	end
	local name = ("Player %d"):format(userId)
	local ok, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	if ok then
		name = result
	end
	nameCache[userId] = name
	return name
end

local function query(store: OrderedDataStore?, ascending: boolean): { any }
	local result = {}
	if not store then
		return result
	end
	local ok, pages = pcall(function()
		return store:GetSortedAsync(ascending, 10)
	end)
	if not ok then
		return result
	end
	for rank, entry in pages:GetCurrentPage() do
		local userId = tonumber(entry.key)
		table.insert(result, {
			Rank = rank,
			UserId = userId,
			Name = if userId then username(userId) else entry.key,
			Value = entry.value,
		})
	end
	return result
end

function LeaderboardService.start()
	ensureStores()

	local remote = RemotesService.getFolder():WaitForChild("LeaderboardQuery") :: RemoteFunction
	remote.OnServerInvoke = function(player: Player)
		local now = os.clock()
		if now - (queryCooldown[player] or 0) < 4 then
			return nil
		end
		queryCooldown[player] = now
		if not ensureStores() then
			return {
				HighestGravity = {},
				TotalCores = {},
				FastestCollapse = {},
			}
		end
		return {
			HighestGravity = query(highestStore, false),
			TotalCores = query(coresStore, false),
			FastestCollapse = query(fastestStore, true),
		}
	end

	Players.PlayerRemoving:Connect(function(player)
		record(player)
		queryCooldown[player] = nil
	end)

	if localStudioMode then
		print("[+1 Gravity] local Studio leaderboards disabled")
		return
	end

	task.spawn(function()
		while true do
			task.wait(45)
			for _, player in Players:GetPlayers() do
				record(player)
			end
		end
	end)
end

return LeaderboardService
