local fs = require("@lune/fs")

return function()
	local source = fs.readFile("src/client/controllers/AmbientController.luau")
	assert(
		not string.find(source, "soundGroup.Parent = SoundService(", 1, true),
		"ambient parent assignment must not become an Instance call"
	)
	assert(string.find(source, "local stateRemote", 1, true), "ambient remote connection must use an explicit local")
end
