local ReceiptRules = require("../src/shared/profile/ReceiptRules")
local ProfileRules = require("../src/shared/profile/ProfileRules")

return function()
	local profile = ProfileRules.default(0)
	local boost = { Key = "gravity_2x_15m", DurationSeconds = 900 }
	assert(ReceiptRules.apply(profile, "a", boost, 100), "boost grant")
	assert(profile.GravityBoostUntil == 1000, "boost expiry")
	local duplicate, reason = ReceiptRules.apply(profile, "a", boost, 100)
	assert(not duplicate and reason == "AlreadyProcessed", "duplicate blocked")
	local shards = { Key = "shards_100", Amount = 100 }
	assert(ReceiptRules.apply(profile, "b", shards, 100), "shards grant")
	assert(profile.Shards == 100, "shards amount")
end
