local ViewportRules = require("../src/shared/rules/ViewportRules")

return function()
	assert(ViewportRules.classify(896, 414, true, false) == "phone", "phone classification")
	assert(ViewportRules.classify(1180, 820, true, false) == "tablet", "tablet classification")
	assert(ViewportRules.classify(1920, 1080, false, false) == "desktop", "desktop classification")
	assert(ViewportRules.classify(1920, 1080, false, true) == "console", "ten-foot classification")

	local phone = ViewportRules.layout(896, 414, true, false)
	local tablet = ViewportRules.layout(1180, 820, true, false)
	local desktop = ViewportRules.layout(1920, 1080, false, false)
	local console = ViewportRules.layout(1920, 1080, false, true)

	assert(phone.BarWidth < 896, "phone HUD must preserve side controls")
	assert(tablet.BarWidth <= 600 and tablet.TutorialWidth <= 600, "tablet HUD width budget")
	assert(desktop.BarWidth < 700, "desktop HUD must not dominate gameplay")
	assert(console.GravityTextSize > desktop.GravityTextSize, "console needs ten-foot text scaling")
	assert(console.CollapseWidth > desktop.CollapseWidth, "console action target must be larger")
	assert(console.DailyTextSize > tablet.DailyTextSize, "console supporting text must be larger")
end
