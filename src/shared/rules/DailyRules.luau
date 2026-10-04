--!strict

local DailyRules = {}

local MISSIONS = {
	{ Type = "Collect", Target = 40, Label = "Attract 40 objects" },
	{ Type = "Gravity", Target = 1500, Label = "Reach 1,500 Gravity" },
	{ Type = "Collect", Target = 80, Label = "Attract 80 objects" },
	{ Type = "Gravity", Target = 5000, Label = "Reach 5,000 Gravity" },
	{ Type = "Collapse", Target = 1, Label = "Collapse once" },
}

function DailyRules.dayKey(timestamp: number): number
	return math.floor(timestamp / 86400)
end

function DailyRules.missionForDay(dayKey: number): any
	local index = (math.abs(math.floor(dayKey)) % #MISSIONS) + 1
	local source = MISSIONS[index]
	return {
		Type = source.Type,
		Target = source.Target,
		Label = source.Label,
	}
end

function DailyRules.nextStreak(previousDay: number, currentDay: number, previousStreak: number): number
	if previousDay == currentDay then
		return math.max(1, previousStreak)
	elseif previousDay == currentDay - 1 then
		return math.max(1, previousStreak + 1)
	end
	return 1
end

function DailyRules.progress(mission: any, current: number, eventType: string, value: number): number
	local nextValue = current
	if mission.Type == eventType then
		if eventType == "Gravity" then
			nextValue = math.max(current, value)
		else
			nextValue += value
		end
	end
	return math.clamp(nextValue, 0, mission.Target)
end

function DailyRules.complete(mission: any, progress: number): boolean
	return progress >= mission.Target
end

function DailyRules.rewardShards(
	streak: number,
	baseReward: number,
	everyDays: number,
	stepShards: number,
	maxBonus: number
): number
	local safeStreak = math.max(1, math.floor(streak))
	local safeEvery = math.max(1, math.floor(everyDays))
	local steps = math.floor((safeStreak - 1) / safeEvery)
	local bonus = math.min(math.max(0, maxBonus), math.max(0, stepShards) * steps)
	return math.max(0, math.floor(baseReward)) + bonus
end

return table.freeze(DailyRules)
