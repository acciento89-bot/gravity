--!strict

local ProfileRules = {}

local SCHEMA_VERSION = 2

local function finiteNumber(value: any, fallback: number): number
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return fallback
	end
	return value
end

local function nonNegativeNumber(value: any, fallback: number): number
	return math.max(0, finiteNumber(value, fallback))
end

local function integer(value: any, fallback: number): number
	return math.floor(finiteNumber(value, fallback))
end

local function nonNegativeInteger(value: any, fallback: number): number
	return math.max(0, integer(value, fallback))
end

local function copyBooleanMap(source: any, fallback: any): any
	local result = {}
	if type(fallback) == "table" then
		for key, value in fallback do
			if type(key) == "string" and type(value) == "boolean" then
				result[key] = value
			end
		end
	end
	if type(source) == "table" then
		for key, value in source do
			if type(key) == "string" and type(value) == "boolean" then
				result[key] = value
			end
		end
	end
	return result
end

local function copyReceiptMap(source: any): any
	local result = {}
	if type(source) == "table" then
		for key, value in source do
			if type(key) == "string" and key ~= "" and value == true then
				result[key] = true
			end
		end
	end
	return result
end

function ProfileRules.schemaVersion(): number
	return SCHEMA_VERSION
end

function ProfileRules.default(now: number?): any
	local timestamp = nonNegativeInteger(now, 0)
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

function ProfileRules.normalize(raw: any, now: number?): any
	local timestamp = nonNegativeInteger(now, 0)
	local result = ProfileRules.default(timestamp)
	if type(raw) ~= "table" then
		return result
	end

	result.Gravity = nonNegativeNumber(raw.Gravity, 0)
	result.XP = nonNegativeNumber(raw.XP, 0)
	result.Level = math.clamp(nonNegativeInteger(raw.Level, 0), 0, 50)
	result.Cores = nonNegativeInteger(raw.Cores, 0)
	result.Shards = nonNegativeInteger(raw.Shards, 0)
	result.TotalGravity = nonNegativeNumber(raw.TotalGravity, 0)
	result.HighestGravity = nonNegativeNumber(raw.HighestGravity, 0)
	result.TotalObjects = nonNegativeInteger(raw.TotalObjects, 0)
	result.CollapseCount = nonNegativeInteger(raw.CollapseCount, 0)

	result.RunStartedAt = nonNegativeInteger(raw.RunStartedAt, timestamp)
	if result.RunStartedAt <= 0 and timestamp > 0 then
		result.RunStartedAt = timestamp
	end
	result.BestCollapseSeconds = nonNegativeInteger(raw.BestCollapseSeconds, 0)

	result.DailyDay = math.max(-1, integer(raw.DailyDay, -1))
	result.DailyStreak = math.clamp(nonNegativeInteger(raw.DailyStreak, 0), 0, 365)
	result.DailyProgress = nonNegativeNumber(raw.DailyProgress, 0)
	result.DailyClaimed = if type(raw.DailyClaimed) == "boolean" then raw.DailyClaimed else false

	result.OrbitSkins = copyBooleanMap(raw.OrbitSkins, result.OrbitSkins)
	result.SingularitySkins = copyBooleanMap(raw.SingularitySkins, result.SingularitySkins)
	result.OrbitSkins.Default = true
	result.SingularitySkins.Default = true

	if type(raw.EquippedOrbitSkin) == "string" and result.OrbitSkins[raw.EquippedOrbitSkin] == true then
		result.EquippedOrbitSkin = raw.EquippedOrbitSkin
	end
	if
		type(raw.EquippedSingularitySkin) == "string"
		and result.SingularitySkins[raw.EquippedSingularitySkin] == true
	then
		result.EquippedSingularitySkin = raw.EquippedSingularitySkin
	end

	result.GravityBoostUntil = nonNegativeInteger(raw.GravityBoostUntil, 0)
	result.XpBoostUntil = nonNegativeInteger(raw.XpBoostUntil, 0)
	result.ProcessedReceipts = copyReceiptMap(raw.ProcessedReceipts)
	result.SchemaVersion = SCHEMA_VERSION

	return result
end

function ProfileRules.needsMigration(raw: any): boolean
	if type(raw) ~= "table" then
		return raw ~= nil
	end
	return raw.SchemaVersion ~= SCHEMA_VERSION
end

function ProfileRules.snapshot(profile: any, now: number?): any
	return ProfileRules.normalize(profile, now)
end

return table.freeze(ProfileRules)
