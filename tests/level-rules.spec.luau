local LevelRules = require("../src/shared/rules/LevelRules")

return function()
	assert(LevelRules.levelFromXp(0) == 0, "new run should start at level 0")
	assert(LevelRules.xpForNextLevel(0) == 80, "level 0 threshold")
	local level10Xp = LevelRules.totalXpForLevel(10)
	assert(LevelRules.levelFromXp(level10Xp) == 10, "cumulative XP should resolve exactly")
	assert(LevelRules.xpMultiplier(0) == 1, "no cores = base XP")
	assert(LevelRules.xpMultiplier(4) == 2, "four cores = +100% XP")
	assert(not LevelRules.canCollapse(49, 999999), "level gate")
	assert(not LevelRules.canCollapse(50, 4999), "gravity gate")
	assert(LevelRules.canCollapse(50, 5000), "collapse should unlock")
	assert(LevelRules.collapseShardReward(0) == 10, "base collapse shards")
	assert(LevelRules.collapseShardReward(10) == 14, "core milestone shards")

	local profile = {
		Gravity = 10,
		TotalGravity = 100,
		XP = 0,
		Level = 0,
		Cores = 2,
		HighestGravity = 15,
	}
	local gravityGain, xpGain = LevelRules.applyAward(profile, 10, 100, 2, 2)
	assert(gravityGain == 20, "gravity boost")
	assert(xpGain == 300, "core and xp boost stack")
	assert(profile.Gravity == 30 and profile.TotalGravity == 120, "gravity totals")
	assert(profile.HighestGravity == 30, "highest gravity")
	assert(profile.XP == 300 and profile.Level == LevelRules.levelFromXp(300), "xp recalculation")

	local denied = {
		Level = 49,
		Gravity = 999999,
		Cores = 0,
		CollapseCount = 0,
		Shards = 0,
		RunStartedAt = 100,
		BestCollapseSeconds = 0,
		XP = 0,
	}
	assert(LevelRules.applyCollapse(denied, 200) == nil, "ineligible collapse rejected")
	assert(denied.Cores == 0, "rejected collapse must not mutate progression")

	local collapsible = {
		Level = 50,
		Gravity = 6000,
		Cores = 4,
		CollapseCount = 4,
		Shards = 7,
		RunStartedAt = 100,
		BestCollapseSeconds = 0,
		XP = LevelRules.totalXpForLevel(50),
	}
	local first = LevelRules.applyCollapse(collapsible, 220)
	assert(first ~= nil, "eligible collapse")
	assert(first.Cores == 5 and first.Shards == 10 and first.RunSeconds == 120, "collapse result")
	assert(collapsible.Gravity == 0 and collapsible.XP == 0 and collapsible.Level == 0, "run reset")
	assert(collapsible.Cores == 5 and collapsible.CollapseCount == 5, "permanent collapse progression")
	assert(collapsible.Shards == 17, "collapse shards granted")
	assert(collapsible.BestCollapseSeconds == 120, "first best time")
	assert(collapsible.RunStartedAt == 220, "next run timestamp")

	collapsible.Level = 50
	collapsible.Gravity = 5000
	collapsible.XP = LevelRules.totalXpForLevel(50)
	collapsible.RunStartedAt = 250
	local second = LevelRules.applyCollapse(collapsible, 300)
	assert(second ~= nil and second.RunSeconds == 50, "second collapse result")
	assert(collapsible.BestCollapseSeconds == 50, "best collapse time improves")
	assert(collapsible.Cores == 6, "second core granted")
end
