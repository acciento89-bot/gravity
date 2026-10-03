local ProfileRules = require("../src/shared/profile/ProfileRules")

return function()
	local fresh = ProfileRules.default(100)
	assert(ProfileRules.schemaVersion() == 2, "schema version")
	assert(fresh.Level == 0 and fresh.Gravity == 0 and fresh.Cores == 0, "fresh profile")
	assert(fresh.RunStartedAt == 100, "fresh run timestamp")

	local normalized = ProfileRules.normalize({
		SchemaVersion = 1,
		Gravity = -5,
		XP = 50,
		Level = 999,
		Cores = 2.8,
		Shards = -1,
		TotalGravity = -100,
		HighestGravity = -20,
		TotalObjects = -4,
		CollapseCount = -3,
		RunStartedAt = -50,
		BestCollapseSeconds = -7,
		DailyDay = -20,
		DailyStreak = 999,
		DailyProgress = -3,
		OrbitSkins = { Plasma = true, Invalid = "yes" },
		SingularitySkins = { Inferno = true },
		EquippedOrbitSkin = "NotOwned",
		EquippedSingularitySkin = "Inferno",
		ProcessedReceipts = { receiptA = true, receiptB = false, [123] = true },
	}, 200)

	assert(normalized.Gravity == 0, "gravity clamp")
	assert(normalized.Level == 50, "level clamp")
	assert(normalized.Cores == 2, "integer cores")
	assert(normalized.Shards == 0, "shard clamp")
	assert(normalized.TotalGravity == 0 and normalized.HighestGravity == 0, "gravity statistics clamp")
	assert(normalized.TotalObjects == 0 and normalized.CollapseCount == 0, "count clamp")
	assert(normalized.RunStartedAt == 200, "invalid run timestamp repaired")
	assert(normalized.BestCollapseSeconds == 0, "best time clamp")
	assert(normalized.DailyDay == -1, "daily day clamp")
	assert(normalized.DailyStreak == 365, "daily streak upper bound")
	assert(normalized.DailyProgress == 0, "daily progress clamp")
	assert(normalized.OrbitSkins.Default and normalized.OrbitSkins.Plasma, "orbit skin merge")
	assert(normalized.OrbitSkins.Invalid == nil, "invalid orbit map value removed")
	assert(normalized.SingularitySkins.Default and normalized.SingularitySkins.Inferno, "singularity skin merge")
	assert(normalized.EquippedOrbitSkin == "Default", "unowned equipped orbit skin repaired")
	assert(normalized.EquippedSingularitySkin == "Inferno", "owned singularity skin preserved")
	assert(normalized.ProcessedReceipts.receiptA == true, "valid receipt preserved")
	assert(normalized.ProcessedReceipts.receiptB == nil, "false receipt removed")
	assert(ProfileRules.needsMigration({ SchemaVersion = 1 }), "old schema must migrate")
	assert(not ProfileRules.needsMigration({ SchemaVersion = 2 }), "current schema must not migrate")

	local snapshot = ProfileRules.snapshot(normalized, 300)
	snapshot.Gravity = 999
	assert(normalized.Gravity == 0, "snapshot must not alias scalar state")
end
