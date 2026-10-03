--!strict

return table.freeze({
	Products = table.freeze({
		GravityBoost = table.freeze({
			Key = "gravity_2x_15m",
			ProductId = 0,
			ExpectedRobux = 29,
			DisplayName = "2× Gravity · 15 min",
			DurationSeconds = 15 * 60,
		}),
		XpBoost = table.freeze({
			Key = "xp_2x_15m",
			ProductId = 0,
			ExpectedRobux = 29,
			DisplayName = "2× XP · 15 min",
			DurationSeconds = 15 * 60,
		}),
		ShardPack = table.freeze({
			Key = "shards_100",
			ProductId = 0,
			ExpectedRobux = 39,
			DisplayName = "100 Shards",
			Amount = 100,
		}),
	}),
})
