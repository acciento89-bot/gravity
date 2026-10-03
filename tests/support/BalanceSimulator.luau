local LevelRules = require("../../src/shared/rules/LevelRules")

local BalanceSimulator = {}

function BalanceSimulator.simulateRun(cores, collectIntervalSeconds, objectDefinitions, zoneDefinitions, maxSeconds)
	local zoneById = {}
	for _, zone in zoneDefinitions do
		zoneById[zone.Id] = zone
	end

	local gravity = 0
	local xp = 0
	local elapsed = 0
	local nextCollection = 0
	local collections = 0
	local step = 0.05
	local limit = maxSeconds or 3600
	local xpMultiplier = LevelRules.xpMultiplier(cores)

	while elapsed < limit do
		local level = LevelRules.levelFromXp(xp)
		if LevelRules.canCollapse(level, gravity) then
			break
		end

		elapsed += step
		gravity += step

		if elapsed + 0.00001 >= nextCollection then
			local best = nil
			for _, definition in objectDefinitions do
				local zone = zoneById[definition.Zone]
				if
					zone
					and cores >= zone.MinCores
					and gravity >= zone.MinGravity
					and gravity >= definition.RequiredGravity
					and (not best or definition.RequiredGravity > best.RequiredGravity)
				then
					best = definition
				end
			end

			if best then
				gravity += best.GravityGain
				xp += math.floor(best.XP * xpMultiplier + 0.5)
				collections += 1
			end
			nextCollection += math.max(0.1, collectIntervalSeconds)
		end
	end

	return {
		Seconds = elapsed,
		Collections = collections,
		Gravity = gravity,
		XP = xp,
		Level = LevelRules.levelFromXp(xp),
		CanCollapse = LevelRules.canCollapse(LevelRules.levelFromXp(xp), gravity),
	}
end

return BalanceSimulator
