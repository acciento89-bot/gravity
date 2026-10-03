local AttractionRules = require("../src/shared/rules/AttractionRules")

return function()
	assert(AttractionRules.radiusForGravity(0) == 10, "base radius")
	assert(AttractionRules.radiusForGravity(1000) > 10, "radius should grow")
	assert(AttractionRules.radiusForGravity(1e20) <= 30, "radius cap")
	assert(AttractionRules.canAttract(100, 100), "threshold inclusive")
	assert(not AttractionRules.canAttract(99, 100), "threshold enforced")
end
