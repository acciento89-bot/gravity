local fs = require("@lune/fs")

return function()
	local world = fs.readFile("src/server/services/WorldService.luau")
	local zones = fs.readFile("src/server/services/ZoneVisualFactory.luau")
	local art = fs.readFile("docs/ART-DIRECTION.md")

	assert(string.find(world, 'vista.Name = "GravityVista"', 1, true), "gravity vista layer missing")
	assert(string.find(world, '"GravityHorizonMonolith"', 1, true), "horizon monoliths missing")
	assert(string.find(world, '"BoulevardGuide"', 1, true), "boulevard energy guide missing")
	assert(string.find(world, '"GravitySunHalo"', 1, true), "sky focal halo missing")
	assert(string.find(zones, '"ZoneBeaconHalo"', 1, true), "zone beacon halo missing")
	assert(string.find(zones, '"FloatingZoneShard"', 1, true), "zone floating shard detail missing")
	assert(string.find(art, "gravity-corridor identity", 1, true), "gravity-corridor identity missing")
end
