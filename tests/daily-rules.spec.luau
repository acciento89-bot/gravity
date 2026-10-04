local DailyRules = require("../src/shared/rules/DailyRules")

return function()
	assert(DailyRules.dayKey(0) == 0, "epoch day")
	assert(DailyRules.dayKey(86400) == 1, "next day")
	assert(DailyRules.nextStreak(9, 10, 4) == 5, "consecutive streak")
	assert(DailyRules.nextStreak(7, 10, 4) == 1, "broken streak")
	local mission = { Type = "Collect", Target = 40 }
	assert(DailyRules.progress(mission, 0, "Collect", 3) == 3, "collect progress")
	assert(DailyRules.progress(mission, 39, "Collect", 10) == 40, "progress cap")
	assert(DailyRules.complete(mission, 40), "complete")
	local gravityMission = { Type = "Gravity", Target = 1500 }
	assert(DailyRules.progress(gravityMission, 800, "Gravity", 1200) == 1200, "gravity uses max")
	assert(DailyRules.rewardShards(1, 15, 3, 5, 30) == 15, "day 1 base reward")
	assert(DailyRules.rewardShards(4, 15, 3, 5, 30) == 20, "day 4 first streak bonus")
	assert(DailyRules.rewardShards(10, 15, 3, 5, 30) == 30, "day 10 streak bonus")
	assert(DailyRules.rewardShards(30, 15, 3, 5, 30) == 45, "streak bonus cap")
end
