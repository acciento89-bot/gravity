local fs = require("@lune/fs")

return function()
	local hud = fs.readFile("src/client/controllers/HudController.luau")
	local cosmetics = fs.readFile("src/client/controllers/CosmeticsController.luau")
	local daily = fs.readFile("src/client/controllers/DailyController.luau")
	local shop = fs.readFile("src/client/controllers/ShopController.luau")
	assert(string.find(hud, 'conceptShowcase.Name = "ConceptShowcase"', 1, true), "concept showcase layer missing")
	assert(string.find(hud, 'styleShowcase.Name = "GravityShopShowcase"', 1, true), "gravity shop showcase missing")
	assert(string.find(hud, 'conceptProgressCard.Name = "ConceptProgressCard"', 1, true), "progress showcase missing")
	assert(string.find(hud, 'conceptDailyRewards.Name = "ConceptDailyRewards"', 1, true), "daily showcase missing")
	assert(string.find(hud, 'conceptVistaCard.Name = "ConceptVistaCard"', 1, true), "visual showcase missing")
	assert(
		string.find(hud, 'local conceptViewport = Instance.new("ViewportFrame")', 1, true),
		"visual preview must use native ViewportFrame"
	)
	assert(
		string.find(hud, "conceptShowcase.Visible = not compact", 1, true),
		"concept showcase must stay off phone layouts"
	)
	assert(string.find(cosmetics, 'conceptOpen.Name = "ConceptOpen"', 1, true), "cosmetics concept bridge missing")
	assert(string.find(daily, 'conceptOpen.Name = "ConceptOpen"', 1, true), "daily concept bridge missing")
	assert(string.find(shop, 'conceptOpen.Name = "ConceptOpen"', 1, true), "shop concept bridge missing")
	assert(
		not string.find(hud, "gradient(card, accent:Lerp", 1, true),
		"concept cards must not call Lerp on the status accent Frame"
	)
end
