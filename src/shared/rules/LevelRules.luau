--!strict

local LevelRules = {}

local MAX_LEVEL = 50
local CORE_XP_BONUS = 0.25
local COLLAPSE_LEVEL = 50
local COLLAPSE_MIN_GRAVITY = 5000
local COLLAPSE_SHARD_BASE = 10
local COLLAPSE_SHARD_PER_FIVE_CORES = 2

function LevelRules.xpForNextLevel(level: number): number
	local safeLevel = math.max(0, math.floor(level))
	return math.floor(80 + (safeLevel ^ 1.55) * 18)
end

function LevelRules.totalXpForLevel(level: number): number
	local total = 0
	for current = 0, math.max(0, math.floor(level)) - 1 do
		total += LevelRules.xpForNextLevel(current)
	end
	return total
end

function LevelRules.levelFromXp(xp: number): number
	local safeXp = math.max(0, xp)
	local level = 0
	local remaining = safeXp
	while level < MAX_LEVEL do
		local required = LevelRules.xpForNextLevel(level)
		if remaining < required then
			break
		end
		remaining -= required
		level += 1
	end
	return level
end

function LevelRules.progressWithinLevel(xp: number): (number, number, number)
	local level = LevelRules.levelFromXp(xp)
	if level >= MAX_LEVEL then
		return level, 1, 0
	end
	local floorXp = LevelRules.totalXpForLevel(level)
	local required = LevelRules.xpForNextLevel(level)
	return level, math.clamp((math.max(0, xp) - floorXp) / required, 0, 1), required
end

function LevelRules.xpMultiplier(cores: number, boostMultiplier: number?): number
	local coreMultiplier = 1 + math.max(0, math.floor(cores)) * CORE_XP_BONUS
	return coreMultiplier * math.max(1, boostMultiplier or 1)
end

function LevelRules.canCollapse(level: number, gravity: number): boolean
	return level >= COLLAPSE_LEVEL and gravity >= COLLAPSE_MIN_GRAVITY
end

function LevelRules.collapseShardReward(currentCores: number): number
	return COLLAPSE_SHARD_BASE + math.floor(math.max(0, currentCores) / 5) * COLLAPSE_SHARD_PER_FIVE_CORES
end

function LevelRules.applyAward(
	profile: any,
	gravityBase: number,
	xpBase: number,
	gravityBoostMultiplier: number?,
	xpBoostMultiplier: number?
): (number, number)
	local gravityMultiplier = math.max(1, gravityBoostMultiplier or 1)
	local xpMultiplier = LevelRules.xpMultiplier(profile.Cores or 0, xpBoostMultiplier)
	local gravityGain = math.max(0, gravityBase) * gravityMultiplier
	local xpGain = math.floor(math.max(0, xpBase) * xpMultiplier + 0.5)

	profile.Gravity = math.max(0, profile.Gravity or 0) + gravityGain
	profile.TotalGravity = math.max(0, profile.TotalGravity or 0) + gravityGain
	profile.XP = math.max(0, profile.XP or 0) + xpGain
	profile.Level = LevelRules.levelFromXp(profile.XP)
	profile.HighestGravity = math.max(profile.HighestGravity or 0, profile.Gravity)

	return gravityGain, xpGain
end

function LevelRules.applyCollapse(profile: any, now: number, countForFastest: boolean?): any?
	if not LevelRules.canCollapse(profile.Level or 0, profile.Gravity or 0) then
		return nil
	end

	local safeNow = math.max(0, math.floor(now))
	local startedAt = math.max(0, math.floor(profile.RunStartedAt or safeNow))
	if startedAt <= 0 or startedAt > safeNow then
		startedAt = safeNow
	end
	local runSeconds = math.max(1, safeNow - startedAt)
	local currentCores = math.max(0, math.floor(profile.Cores or 0))
	local shards = LevelRules.collapseShardReward(currentCores)

	profile.Cores = currentCores + 1
	profile.CollapseCount = math.max(0, math.floor(profile.CollapseCount or 0)) + 1
	profile.Shards = math.max(0, math.floor(profile.Shards or 0)) + shards
	local eligibleForFastest = countForFastest ~= false
	if eligibleForFastest and ((profile.BestCollapseSeconds or 0) <= 0 or runSeconds < profile.BestCollapseSeconds) then
		profile.BestCollapseSeconds = runSeconds
	end
	profile.Gravity = 0
	profile.XP = 0
	profile.Level = 0
	profile.RunStartedAt = safeNow
	profile.RunWasBoosted = false

	return {
		Cores = profile.Cores,
		Shards = shards,
		RunSeconds = runSeconds,
		FastestEligible = eligibleForFastest,
	}
end

return table.freeze(LevelRules)
