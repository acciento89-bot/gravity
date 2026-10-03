local ProfileRules = require("../src/shared/profile/ProfileRules")

return function()
	local fresh = ProfileRules.default(100)
	assert(fresh.Level == 0 and fresh.Gravity == 0 and fresh.Cores == 0, "fresh profile")
	local normalized = ProfileRules.normalize({
		Gravity = -5,
		XP = 50,
		Level = 999,
		Cores = 2.8,
		Shards = -1,
		OrbitSkins = { Plasma = true },
	}, 200)
	assert(normalized.Gravity == 0, "gravity clamp")
	assert(normalized.Level == 50, "level clamp")
	assert(normalized.Cores == 2, "integer cores")
	assert(normalized.Shards == 0, "shard clamp")
	assert(normalized.OrbitSkins.Default and normalized.OrbitSkins.Plasma, "skin merge")
end
