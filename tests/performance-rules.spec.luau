local PerformanceRules = require("../src/shared/rules/PerformanceRules")

return function()
	local collectibles = PerformanceRules.collectibleCount(25, 6)
	assert(collectibles == 150, "V1 collectible budget")
	local checks = PerformanceRules.scanChecksPerSecond(8, collectibles, 0.2)
	assert(checks == 6000, "8-player worst-case scan budget")
	assert(checks <= 6000, "server scan regression ceiling")
	assert(
		PerformanceRules.streamingDecision(975, collectibles, false) == "DeferUntilDeviceProfile",
		"streaming waits for real device evidence"
	)
	assert(
		PerformanceRules.streamingDecision(975, collectibles, true) == "Optional",
		"current V1 world does not force streaming"
	)
	assert(PerformanceRules.streamingDecision(1600, collectibles, true) == "Enable", "large future world should stream")
end
