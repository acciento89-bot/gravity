local ZoneRules = require("../src/shared/rules/ZoneRules")

return function()
	local zones = {
		{ Order = 1, MinGravity = 0, MinCores = 0, Id = "a" },
		{ Order = 2, MinGravity = 100, MinCores = 0, Id = "b" },
		{ Order = 3, MinGravity = 500, MinCores = 1, Id = "c" },
	}
	assert(ZoneRules.highestUnlocked(zones, 0, 0).Id == "a", "first zone")
	assert(ZoneRules.highestUnlocked(zones, 200, 0).Id == "b", "gravity zone")
	assert(ZoneRules.highestUnlocked(zones, 999, 0).Id == "b", "core gate")
	assert(ZoneRules.highestUnlocked(zones, 999, 1).Id == "c", "core zone")
end
