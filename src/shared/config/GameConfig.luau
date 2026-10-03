--!strict

return table.freeze({
	Progression = table.freeze({
		MaxLevel = 50,
		BaseGravityPerSecond = 1,
		CoreXpBonus = 0.25,
		CollapseLevel = 50,
		CollapseMinGravity = 5000,
		CollapseShardBase = 10,
		CollapseShardPerFiveCores = 2,
	}),
	Attraction = table.freeze({
		BaseRadius = 10,
		MaxRadius = 30,
		RadiusLogScale = 2.35,
		ScanInterval = 0.2,
		MaxCollectionsPerScan = 5,
	}),
	Orbit = table.freeze({
		VisibleSlots = 14,
		InnerRadius = 4.4,
		OuterRadius = 9.8,
		BaseRotationSpeed = 0.78,
		MaxVisualSize = 3.8,
	}),
	Persistence = table.freeze({
		DataStoreName = "Plus1Gravity_Profile_v1",
		AutoSaveSeconds = 60,
		LoadAttempts = 4,
		SaveAttempts = 3,
		RetryBaseSeconds = 0.35,
	}),
	Leaderboard = table.freeze({
		HighestGravity = "Plus1Gravity_HighestGravity_v1",
		TotalCores = "Plus1Gravity_TotalCores_v1",
		FastestCollapse = "Plus1Gravity_FastestCollapse_v1",
	}),
	Daily = table.freeze({
		RewardShards = 15,
		MaxStreak = 30,
	}),
})
