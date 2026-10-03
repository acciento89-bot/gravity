--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)
local ZoneConfig = require(shared.config.ZoneConfig)
local AttractionRules = require(shared.rules.AttractionRules)
local DailyRules = require(shared.rules.DailyRules)
local LevelRules = require(shared.rules.LevelRules)

local ProfileService = require(script.Parent.ProfileService)
local RemotesService = require(script.Parent.RemotesService)
local WorldService = require(script.Parent.WorldService)

local GameService = {}

local stateRemote: RemoteEvent
local orbitRemote: RemoteEvent
local collapseFxRemote: RemoteEvent
local actionRemote: RemoteEvent
local queryState: RemoteFunction

local passiveAccumulator = 0
local attractionAccumulator = 0
local lastStatePush: { [Player]: number } = {}
local actionCooldown: { [Player]: number } = {}

local function colorArray(color: Color3): { number }
	return {
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5),
	}
end

local function getRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function dailyMission(profile: any): any
	return DailyRules.missionForDay(profile.DailyDay)
end

local function updateDaily(profile: any, eventType: string, value: number): boolean
	local mission = dailyMission(profile)
	if profile.DailyClaimed then
		return false
	end
	profile.DailyProgress = DailyRules.progress(mission, profile.DailyProgress, eventType, value)
	if DailyRules.complete(mission, profile.DailyProgress) then
		profile.DailyClaimed = true
		profile.Shards += GameConfig.Daily.RewardShards
		return true
	end
	return false
end

local function initializeDaily(profile: any)
	local currentDay = DailyRules.dayKey(os.time())
	if profile.DailyDay ~= currentDay then
		profile.DailyStreak = math.min(
			GameConfig.Daily.MaxStreak,
			DailyRules.nextStreak(profile.DailyDay, currentDay, profile.DailyStreak)
		)
		profile.DailyDay = currentDay
		profile.DailyProgress = 0
		profile.DailyClaimed = false
	end
end

local function zoneForPosition(position: Vector3, profile: any): any
	for _, zone in ZoneConfig do
		local center = Vector3.new(zone.Center[1], zone.Center[2], zone.Center[3])
		local size = Vector3.new(zone.Size[1], zone.Size[2], zone.Size[3])
		if math.abs(position.X - center.X) <= size.X / 2 and math.abs(position.Z - center.Z) <= size.Z / 2 then
			return zone
		end
	end

	local best = ZoneConfig[1]
	for _, zone in ZoneConfig do
		if profile.Gravity >= zone.MinGravity and profile.Cores >= zone.MinCores then
			best = zone
		end
	end
	return best
end

local function snapshot(player: Player): any
	local profile = ProfileService.get(player)
	if not profile then
		return { Ready = false }
	end
	local root = getRoot(player)
	local zone = if root then zoneForPosition(root.Position, profile) else ZoneConfig[1]
	local _, levelProgress, nextXp = LevelRules.progressWithinLevel(profile.XP)
	local mission = dailyMission(profile)

	return {
		Ready = true,
		Gravity = profile.Gravity,
		XP = profile.XP,
		Level = profile.Level,
		LevelProgress = levelProgress,
		NextLevelXP = nextXp,
		Cores = profile.Cores,
		Shards = profile.Shards,
		HighestGravity = profile.HighestGravity,
		TotalGravity = profile.TotalGravity,
		TotalObjects = profile.TotalObjects,
		CollapseCount = profile.CollapseCount,
		BestCollapseSeconds = profile.BestCollapseSeconds,
		CanCollapse = LevelRules.canCollapse(profile.Level, profile.Gravity),
		AttractionRadius = AttractionRules.radiusForGravity(profile.Gravity),
		Zone = {
			Id = zone.Id,
			DisplayName = zone.DisplayName,
			MinGravity = zone.MinGravity,
			MinCores = zone.MinCores,
		},
		Daily = {
			Label = mission.Label,
			Progress = profile.DailyProgress,
			Target = mission.Target,
			Claimed = profile.DailyClaimed,
			Streak = profile.DailyStreak,
			RewardShards = GameConfig.Daily.RewardShards,
		},
		EquippedOrbitSkin = profile.EquippedOrbitSkin,
		EquippedSingularitySkin = profile.EquippedSingularitySkin,
		OrbitSkins = profile.OrbitSkins,
		SingularitySkins = profile.SingularitySkins,
		GravityBoostUntil = profile.GravityBoostUntil,
		XpBoostUntil = profile.XpBoostUntil,
	}
end

function GameService.snapshot(player: Player): any
	return snapshot(player)
end

function GameService.pushState(player: Player, eventName: string?)
	if player.Parent ~= Players then
		return
	end
	local state = snapshot(player)
	if state.Ready then
		player:SetAttribute("Gravity", state.Gravity)
		player:SetAttribute("GravityLevel", state.Level)
		player:SetAttribute("GravityCores", state.Cores)
		player:SetAttribute("GravityCanCollapse", state.CanCollapse)
		player:SetAttribute("GravityZone", state.Zone.DisplayName)
	end
	state.Event = eventName or "State"
	stateRemote:FireClient(player, state)
	lastStatePush[player] = os.clock()
end

local function boostMultiplier(untilTimestamp: number): number
	return if untilTimestamp > os.time() then 2 else 1
end

local function recalculate(profile: any)
	profile.Level = LevelRules.levelFromXp(profile.XP)
	profile.HighestGravity = math.max(profile.HighestGravity, profile.Gravity)
end

local function award(player: Player, gravityBase: number, xpBase: number, dailyType: string?)
	local profile = ProfileService.get(player)
	if not profile then
		return
	end
	LevelRules.applyAward(
		profile,
		gravityBase,
		xpBase,
		boostMultiplier(profile.GravityBoostUntil),
		boostMultiplier(profile.XpBoostUntil)
	)
	if dailyType then
		updateDaily(profile, dailyType, if dailyType == "Gravity" then profile.Gravity else 1)
	end
	updateDaily(profile, "Gravity", profile.Gravity)
	ProfileService.markDirty(player)
end

local function collectForPlayer(player: Player)
	local profile = ProfileService.get(player)
	local root = getRoot(player)
	if not profile or not root then
		return
	end

	local radius = AttractionRules.radiusForGravity(profile.Gravity)
	local collected = 0
	for _, candidate in CollectionService:GetTagged("GravityCollectible") do
		if collected >= GameConfig.Attraction.MaxCollectionsPerScan then
			break
		end
		if candidate:IsA("BasePart") and candidate:GetAttribute("Active") == true then
			local requiredGravity = tonumber(candidate:GetAttribute("RequiredGravity")) or math.huge
			if AttractionRules.canAttract(profile.Gravity, requiredGravity) then
				local distance = (candidate.Position - root.Position).Magnitude
				if distance <= radius and WorldService.collect(candidate) then
					local gravityGain = tonumber(candidate:GetAttribute("GravityGain")) or 0
					local xpGain = tonumber(candidate:GetAttribute("XP")) or 0
					award(player, gravityGain, xpGain, "Collect")
					profile.TotalObjects += 1
					ProfileService.markDirty(player)
					collected += 1
					orbitRemote:FireClient(player, {
						ObjectId = candidate:GetAttribute("ObjectId"),
						DisplayName = candidate:GetAttribute("DisplayName"),
						Size = { candidate.Size.X, candidate.Size.Y, candidate.Size.Z },
						Color = colorArray(candidate.Color),
						WorldPosition = { candidate.Position.X, candidate.Position.Y, candidate.Position.Z },
						GravityGain = gravityGain,
						XP = xpGain,
					})
				end
			end
		end
	end
	if collected > 0 then
		GameService.pushState(player, "Collected")
	end
end

local function collapse(player: Player)
	local profile = ProfileService.get(player)
	if not profile then
		return
	end

	local result = LevelRules.applyCollapse(profile, os.time())
	if not result then
		return
	end

	updateDaily(profile, "Collapse", 1)
	ProfileService.markDirty(player)

	collapseFxRemote:FireClient(player, {
		Cores = result.Cores,
		Shards = result.Shards,
		RunSeconds = result.RunSeconds,
		Skin = profile.EquippedSingularitySkin,
	})
	GameService.pushState(player, "Collapsed")
end

local function onAction(player: Player, action: any)
	if type(action) ~= "string" then
		return
	end
	local now = os.clock()
	if now - (actionCooldown[player] or 0) < 0.25 then
		return
	end
	actionCooldown[player] = now

	if action == "Collapse" then
		collapse(player)
	end
end

local function preparePlayer(player: Player)
	while player.Parent == Players and not ProfileService.get(player) do
		task.wait(0.05)
	end
	local profile = ProfileService.get(player)
	if not profile then
		return
	end
	initializeDaily(profile)
	recalculate(profile)
	ProfileService.markDirty(player)
	GameService.pushState(player, "Ready")
end

function GameService.start()
	local remotes = RemotesService.getFolder()
	stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	orbitRemote = remotes:WaitForChild("OrbitCollect") :: RemoteEvent
	collapseFxRemote = remotes:WaitForChild("CollapseFx") :: RemoteEvent
	actionRemote = remotes:WaitForChild("Action") :: RemoteEvent
	queryState = remotes:WaitForChild("QueryState") :: RemoteFunction

	queryState.OnServerInvoke = function(player: Player)
		return snapshot(player)
	end
	actionRemote.OnServerEvent:Connect(onAction)

	Players.PlayerAdded:Connect(function(player)
		task.spawn(preparePlayer, player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(preparePlayer, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		lastStatePush[player] = nil
		actionCooldown[player] = nil
	end)

	RunService.Heartbeat:Connect(function(dt)
		passiveAccumulator += dt
		attractionAccumulator += dt

		if passiveAccumulator >= 1 then
			local ticks = math.floor(passiveAccumulator)
			passiveAccumulator -= ticks
			for _, player in Players:GetPlayers() do
				if ProfileService.get(player) then
					award(player, GameConfig.Progression.BaseGravityPerSecond * ticks, 0, nil)
					if os.clock() - (lastStatePush[player] or 0) >= 1 then
						GameService.pushState(player, "Tick")
					end
				end
			end
		end

		if attractionAccumulator >= GameConfig.Attraction.ScanInterval then
			attractionAccumulator = 0
			for _, player in Players:GetPlayers() do
				collectForPlayer(player)
			end
		end
	end)
end

return GameService
