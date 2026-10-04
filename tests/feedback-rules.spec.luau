local FeedbackRules = require("../src/shared/rules/FeedbackRules")

return function()
	assert(FeedbackRules.collectBand(1) == "Small", "small collect")
	assert(FeedbackRules.collectBand(95) == "Medium", "medium collect")
	assert(FeedbackRules.collectBand(700) == "Massive", "massive collect")
	assert(FeedbackRules.collectPitch("Small") > FeedbackRules.collectPitch("Massive"), "small cue pitches higher")
	assert(FeedbackRules.collectVolume("Massive") > FeedbackRules.collectVolume("Small"), "massive cue is stronger")
	assert(FeedbackRules.coreMilestoneBand(10) == "Major", "10-core major milestone")
	assert(FeedbackRules.coreMilestoneBand(5) == "Medium", "5-core milestone")
	assert(FeedbackRules.coreMilestoneBand(3) == "Normal", "normal core")
end
