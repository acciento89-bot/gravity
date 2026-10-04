local LocalizationRules = require("../src/shared/rules/LocalizationRules")

return function()
	assert(LocalizationRules.language("de-de") == "de", "German locale")
	assert(LocalizationRules.language("en-us") == "en", "English locale")
	assert(LocalizationRules.language("pl-pl") == "en", "unsupported locale falls back to English")
	assert(LocalizationRules.text("de-de", "access") == "ZUGANG", "German accessibility label")
	assert(LocalizationRules.text("en-us", "access") == "ACCESS", "English accessibility label")
	assert(LocalizationRules.format("de-de", "need_gravity", 120):find("120") ~= nil, "formatted German requirement")
	local required = {
		"gravity",
		"collapse",
		"daily",
		"style",
		"gravity_style",
		"equipped",
		"daily_title",
		"mission_collect",
		"rankings",
		"top_gravity",
		"shop",
		"shop_title",
		"purchase_cancelled",
		"downtown_ahead",
		"zone_backyard",
		"access_title",
		"reduced_motion",
		"core_reward",
	}
	for _, key in required do
		assert(LocalizationRules.has("en-us", key), "missing English localization: " .. key)
		assert(LocalizationRules.has("de-de", key), "missing German localization: " .. key)
	end
end
