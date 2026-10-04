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
local SecurityRules = require(shared.rules.SecurityRules)
local ZoneRules = require(shared.rules.ZoneRules)

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
local lastUnlockedOrder: { [Player]: number } = {}
local lastGateFeedback: { [Player]: number } = {}
local lastZoneId: { [Player]: string } = {}

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

local function dailyRewardShards(profile: any): number
	return DailyRules.rewardShards(
		profile.DailyStreak,
		GameConfig.Daily.RewardShards,
		GameConfig.Daily.StreakRewardEveryDays,
		GameConfig.Daily.StreakRewardStepShards,
		GameConfig.Daily.MaxStreakBonusShards
	)
end

local function updateDaily(profile: any, eventType: string, value: number): number?
	local mission = dailyMission(profile)
	if profile.DailyClaimed then
		return nil
	end
	profile.DailyProgress = DailyRules.progress(mission, profile.DailyProgress, eventType, value)
	if DailyRules.complete(mission, profile.DailyProgress) then
		local reward = dailyRewardShards(profile)
		profile.DailyClaimed = true
		profile.Shards += reward
		return reward
	end
	return nil
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
	local containing = ZoneRules.zoneContainingPosition(ZoneConfig, position.X, position.Z)
	if containing then
		return containing
	end
	return ZoneRules.highestUnlocked(ZoneConfig, profile.Gravity, profile.Cores) or ZoneConfig[1]
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
			Type = mission.Type,
			Label = mission.Label,
			Progress = profile.DailyProgress,
			Target = mission.Target,
			Claimed = profile.DailyClaimed,
			Streak = profile.DailyStreak,
			RewardShards = dailyRewardShards(profile),
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

function GameService.pushState(player: Player, eventName: string?, eventData: any?)
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
	state.EventData = eventData
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

local function zoneEventData(zone: any): any
	return {
		Id = zone.Id,
		DisplayName = zone.DisplayName,
		MinGravity = zone.MinGravity,
		MinCores = zone.MinCores,
	}
end

local function checkZoneUnlock(player: Player, profile: any)
	local highest = ZoneRules.highestUnlocked(ZoneConfig, profile.Gravity, profile.Cores)
	if not highest then
		return
	end

	local order = highest.Order or 0
	local previous = lastUnlockedOrder[player]
	if previous == nil then
		lastUnlockedOrder[player] = order
	elseif order > previous then
		lastUnlockedOrder[player] = order
		GameService.pushState(player, "ZoneUnlocked", zoneEventData(highest))
	end
end

local function enforceZoneGate(player: Player, profile: any, root: BasePart)
	local zone = ZoneRules.zoneContainingPosition(ZoneConfig, root.Position.X, root.Position.Z)
	if not zone then
		return
	end

	if ZoneRules.isUnlocked(zone, profile.Gravity, profile.Cores) then
		if lastZoneId[player] ~= zone.Id then
			lastZoneId[player] = zone.Id
			GameService.pushState(player, "ZoneEntered", zoneEventData(zone))
		end
		return
	end

	local safeX, safeZ = ZoneRules.safeReturnXZ(ZoneConfig, zone)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = CFrame.new(safeX, math.max(4, root.Position.Y), safeZ)

	local now = os.clock()
	if now - (lastGateFeedback[player] or 0) >= 1.25 then
		lastGateFeedback[player] = now
		GameService.pushState(player, "ZoneLocked", zoneEventData(zone))
	end
end

local function award(player: Player, gravityBase: number, xpBase: number, dailyType: string?): number?
	local profile = ProfileService.get(player)
	if not profile then
		return nil
	end
	local gravityBoost = boostMultiplier(profile.GravityBoostUntil)
	local xpBoost = boostMultiplier(profile.XpBoostUntil)
	if gravityBoost > 1 or xpBoost > 1 then
		profile.RunWasBoosted = true
	end
	LevelRules.applyAward(profile, gravityBase, xpBase, gravityBoost, xpBoost)
	local dailyReward: number? = nil
	if dailyType then
		dailyReward = updateDaily(profile, dailyType, if dailyType == "Gravity" then profile.Gravity else 1)
	end
	if not dailyReward then
		dailyReward = updateDaily(profile, "Gravity", profile.Gravity)
	end
	ProfileService.markDirty(player)
	checkZoneUnlock(player, profile)
	return dailyReward
end

local function collectForPlayer(player: Player)
	local profile = ProfileService.get(player)
	local root = getRoot(player)
	if not profile or not root then
		return
	end

	local radius = AttractionRules.radiusForGravity(profile.Gravity)
	local collected = 0
	local completedDailyReward: number? = nil
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
					local reward = award(player, gravityGain, xpGain, "Collect")
					completedDailyReward = completedDailyReward or reward
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
		if completedDailyReward then
			GameService.pushState(player, "DailyComplete", { RewardShards = completedDailyReward })
		else
			GameService.pushState(player, "Collected")
		end
	end
end

local function collapse(player: Player)
	local profile = ProfileService.get(player)
	if not profile then
		return
	end

	local result = LevelRules.applyCollapse(profile, os.time(), profile.RunWasBoosted ~= true)
	if not result then
		return
	end

	local dailyReward = updateDaily(profile, "Collapse", 1)
	ProfileService.markDirty(player)

	collapseFxRemote:FireClient(player, {
		Cores = result.Cores,
		Shards = result.Shards,
		RunSeconds = result.RunSeconds,
		Skin = profile.EquippedSingularitySkin,
	})
	if dailyReward then
		GameService.pushState(player, "DailyComplete", { RewardShards = dailyReward })
	else
		GameService.pushState(player, "Collapsed")
	end
end

local function onAction(player: Player, action: any)
	if not SecurityRules.validToken(action, 12) or action ~= "Collapse" then
		return
	end
	local now = os.clock()
	local previous = actionCooldown[player]
	if not SecurityRules.allow(now, previous, 0.25) then
		return
	end
	actionCooldown[player] = now
	collapse(player)
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
	local highest = ZoneRules.highestUnlocked(ZoneConfig, profile.Gravity, profile.Cores)
	lastUnlockedOrder[player] = if highest then highest.Order or 0 else 0
	local root = getRoot(player)
	local currentZone = if root then zoneForPosition(root.Position, profile) else ZoneConfig[1]
	lastZoneId[player] = currentZone.Id
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
		lastUnlockedOrder[player] = nil
		lastGateFeedback[player] = nil
		lastZoneId[player] = nil
	end)

	RunService.Heartbeat:Connect(function(dt)
		passiveAccumulator += dt
		attractionAccumulator += dt

		if passiveAccumulator >= 1 then
			local ticks = math.floor(passiveAccumulator)
			passiveAccumulator -= ticks
			for _, player in Players:GetPlayers() do
				if ProfileService.get(player) then
					local dailyReward = award(player, GameConfig.Progression.BaseGravityPerSecond * ticks, 0, nil)
					if dailyReward then
						GameService.pushState(player, "DailyComplete", { RewardShards = dailyReward })
					elseif os.clock() - (lastStatePush[player] or 0) >= 1 then
						GameService.pushState(player, "Tick")
					end
				end
			end
		end

		if attractionAccumulator >= GameConfig.Attraction.ScanInterval then
			attractionAccumulator = 0
			for _, player in Players:GetPlayers() do
				local profile = ProfileService.get(player)
				local root = getRoot(player)
				if profile and root then
					enforceZoneGate(player, profile, root)
					collectForPlayer(player)
				end
			end
		end
	end)
end

return GameService
