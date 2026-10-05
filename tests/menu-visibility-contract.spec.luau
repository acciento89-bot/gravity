local fs = require("@lune/fs")

return function()
	local hud = fs.readFile("src/client/controllers/HudController.luau")
	local daily = fs.readFile("src/client/controllers/DailyController.luau")
	local shop = fs.readFile("src/client/controllers/ShopController.luau")
	local cosmetics = fs.readFile("src/client/controllers/CosmeticsController.luau")
	local art = fs.readFile("docs/ART-DIRECTION.md")

	assert(string.find(hud, "dailyLabel.Visible = false", 1, true), "detailed Daily status must not stay permanently visible")
	assert(string.find(daily, "panel.Visible = false", 1, true), "Daily panel must be hidden by default")
	assert(string.find(shop, "panel.Visible = false", 1, true), "Shop panel must be hidden by default")
	assert(string.find(cosmetics, "panel.Visible = false", 1, true), "Style panel must be hidden by default")
	assert(string.find(daily, 'closeButton.Name = "CloseButton"', 1, true), "Daily panel needs an explicit close control")
	assert(string.find(shop, 'closeButton.Name = "CloseButton"', 1, true), "Shop panel needs an explicit close control")
	assert(string.find(cosmetics, 'closeButton.Name = "CloseButton"', 1, true), "Style panel needs an explicit close control")
	assert(string.find(hud, "collapseButton.Visible = false", 1, true), "Collapse must remain state-driven")
	assert(string.find(art, "feature montage", 1, true), "art direction must define concept references as feature montages")
end
