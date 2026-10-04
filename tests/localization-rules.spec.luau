local LocalizationRules = require("../src/shared/rules/LocalizationRules")

return function()
	assert(LocalizationRules.language("de-de") == "de", "German locale")
	assert(LocalizationRules.language("en-us") == "en", "English locale")
	assert(LocalizationRules.language("pl-pl") == "en", "unsupported locale falls back to English")
	assert(LocalizationRules.text("de-de", "access") == "ZUGANG", "German accessibility label")
	assert(LocalizationRules.text("en-us", "access") == "ACCESS", "English accessibility label")
	assert(LocalizationRules.format("de-de", "need_gravity", 120):find("120") ~= nil, "formatted German requirement")
end
