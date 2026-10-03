--!strict

local ProfileRules = {}

local SCHEMA_VERSION = 1

function ProfileRules.default(now: number?): any
	local timestamp = now or 0
	return {
		SchemaVersion = SCHEMA_VERSION,
		Gravity = 0,
		XP = 0,
		Level = 0,
		Cores = 0,
		Shards = 0,
		TotalGravity = 0,
		HighestGravity = 0,
		TotalObjects = 0,
		CollapseCount = 0,
		RunStartedAt = timestamp,
		BestCollapseSeconds = 0,
		DailyDay = -1,
		DailyStreak = 0,
		DailyProgress = 0,
		DailyClaimed = false,
		OrbitSkins = { Default = true },
		SingularitySkins = { Default = true },
		EquippedOrbitSkin = "Default",
		EquippedSingularitySkin = "Default",
		GravityBoostUntil = 0,
		XpBoostUntil = 0,
		ProcessedReceipts = {},
	}
end

local function copyMap(source: any, fallback: any): any
	local result = {}
	if type(fallback) == "table" then
		for key, value in fallback do
			result[key] = value
		end
	end
	if type(source) == "table" then
		for key, value in source do
			result[key] = value
		end
	end
	return result
end

function ProfileRules.normalize(raw: any, now: number?): any
	local result = ProfileRules.default(now)
	if type(raw) ~= "table" then
		return result
	end
	local defaultOrbitSkins = copyMap(result.OrbitSkins, {})
	local defaultSingularitySkins = copyMap(result.SingularitySkins, {})
	for key, defaultValue in result do
		local value = raw[key]
		if value ~= nil and type(value) == type(defaultValue) then
			result[key] = value
		end
	end
	result.OrbitSkins = copyMap(raw.OrbitSkins, defaultOrbitSkins)
	result.SingularitySkins = copyMap(raw.SingularitySkins, defaultSingularitySkins)
	result.ProcessedReceipts = copyMap(raw.ProcessedReceipts, {})
	result.SchemaVersion = SCHEMA_VERSION
	result.Gravity = math.max(0, result.Gravity)
	result.XP = math.max(0, result.XP)
	result.Level = math.clamp(math.floor(result.Level), 0, 50)
	result.Cores = math.max(0, math.floor(result.Cores))
	result.Shards = math.max(0, math.floor(result.Shards))
	result.TotalObjects = math.max(0, math.floor(result.TotalObjects))
	result.CollapseCount = math.max(0, math.floor(result.CollapseCount))
	return result
end

return table.freeze(ProfileRules)
