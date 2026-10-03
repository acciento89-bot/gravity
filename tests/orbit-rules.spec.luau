local OrbitRules = require("../src/shared/rules/OrbitRules")

return function()
	assert(OrbitRules.tierBand(1) == 1, "tier 1")
	assert(OrbitRules.tierBand(5) == 1, "tier 5")
	assert(OrbitRules.tierBand(6) == 2, "tier 6")
	assert(OrbitRules.tierBand(25) == 5, "tier 25")

	local phoneScale = OrbitRules.radiusScale(896, 414, 5.5)
	local desktopScale = OrbitRules.radiusScale(1920, 1080, 5.5)
	assert(phoneScale < desktopScale, "phone orbit must contract relative to desktop")
	assert(phoneScale >= 0.72, "phone scale lower bound")

	local centerFade = OrbitRules.occlusionFade(448, 207, 10, 896, 414)
	local edgeFade = OrbitRules.occlusionFade(50, 50, 10, 896, 414)
	assert(centerFade > 0.5, "screen center should fade orbit visuals")
	assert(edgeFade == 0, "screen edge should not fade orbit visuals")
	assert(OrbitRules.occlusionFade(448, 207, -1, 896, 414) == 0, "behind-camera visual")

	local entries = {
		{ ObjectId = "can", TierBand = 1 },
		{ ObjectId = "car", TierBand = 2 },
		{ ObjectId = "forklift", TierBand = 3 },
	}
	assert(OrbitRules.replacementIndex(entries, "car", 2, 14) == 2, "same object aggregates")
	assert(OrbitRules.replacementIndex(entries, "new", 4, 14) == nil, "free slot keeps new representative")

	local full = {
		{ ObjectId = "a", TierBand = 1 },
		{ ObjectId = "b", TierBand = 2 },
		{ ObjectId = "c", TierBand = 3 },
	}
	assert(OrbitRules.replacementIndex(full, "z", 2, 3) == 2, "full orbit replaces within tier first")
	assert(OrbitRules.replacementIndex(full, "z", 5, 3) == 1, "full orbit falls back to oldest")
end
