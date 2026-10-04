local fs = require("@lune/fs")

return function()
	local hud = fs.readFile("src/client/controllers/HudController.luau")
	local zones = fs.readFile("src/server/services/ZoneVisualFactory.luau")

	assert(string.find(hud, 'logo.Name = "Plus1GravityLogo"', 1, true), "HUD needs +1 Gravity branding")
	assert(string.find(hud, 'orbitBadge.Name = "OrbitBadge"', 1, true), "HUD needs an orbit-escalation concept badge")
	assert(string.find(hud, "orbitBadgeText.Text", 1, true), "orbit badge must update from authoritative state")
	assert(string.find(zones, 'rift.Name = "GravityRift"', 1, true), "Backyard needs a gravity-rift hero landmark")
	assert(string.find(zones, '"GravityRiftCore"', 1, true), "gravity rift needs an energy core")
	assert(string.find(zones, '"RiftNode"', 1, true), "gravity rift needs a visible energy ring")
end
