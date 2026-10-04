local OnboardingRules = require("../src/shared/rules/OnboardingRules")

return function()
	assert(OnboardingRules.firstCollectibleDistance() <= 10, "first collectible must be inside base attraction radius")
	local lastX = 0
	for index = 1, 5 do
		local x, z = OnboardingRules.collectibleOffset("can", index)
		assert(x ~= nil and z ~= nil, "first five path point missing")
		assert(x > lastX, "first five collectibles must advance along the road")
		assert(math.abs(z) <= 2, "first five path must stay readable near boulevard center")
		lastX = x
	end
	local toyX = select(1, OnboardingRules.collectibleOffset("toy_block", 1))
	local chairX = select(1, OnboardingRules.collectibleOffset("garden_chair", 1))
	local bbqX = select(1, OnboardingRules.collectibleOffset("barbecue", 1))
	assert(
		toyX and chairX and bbqX and toyX > lastX and chairX > toyX and bbqX > chairX,
		"size escalation must continue forward"
	)
end
