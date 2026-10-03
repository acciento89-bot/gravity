local ReadinessRules = require("../src/shared/rules/ReadinessRules")

return function()
	local bad = ReadinessRules.evaluate(
		{ UniverseId = 0, DevelopmentPlaceId = 0, ProductionPlaceId = 0 },
		{ Products = { A = { ProductId = 0 } } }
	)
	assert(not bad.Ready and #bad.Blockers == 4, "all external blockers surfaced")
	local good = ReadinessRules.evaluate(
		{ UniverseId = 1, DevelopmentPlaceId = 2, ProductionPlaceId = 2 },
		{ Products = { A = { ProductId = 3 } } }
	)
	assert(good.Ready and #good.Blockers == 0, "configured build should be ready")
end
