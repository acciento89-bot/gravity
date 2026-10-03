local ObjectConfig = require("../src/shared/config/ObjectConfig")
local ZoneConfig = require("../src/shared/config/ZoneConfig")

return function()
	assert(#ObjectConfig == 25, "exactly 25 object classes")
	assert(#ZoneConfig == 5, "exactly five zones")

	local zoneIds = {}
	for _, zone in ZoneConfig do
		zoneIds[zone.Id] = true
	end

	local ids = {}
	local perZone = {}
	local previousRequirement = -1
	local previousGravityGain = -1
	local previousXp = -1

	for index, definition in ObjectConfig do
		assert(type(definition.Id) == "string" and definition.Id ~= "", ("object %d id"):format(index))
		assert(not ids[definition.Id], ("duplicate object id %s"):format(definition.Id))
		ids[definition.Id] = true

		assert(zoneIds[definition.Zone], ("unknown zone for %s"):format(definition.Id))
		perZone[definition.Zone] = (perZone[definition.Zone] or 0) + 1

		assert(
			definition.RequiredGravity >= previousRequirement,
			("gravity tier regression at %s"):format(definition.Id)
		)
		assert(definition.GravityGain >= previousGravityGain, ("gravity reward regression at %s"):format(definition.Id))
		assert(definition.XP >= previousXp, ("xp reward regression at %s"):format(definition.Id))
		assert(definition.Respawn >= 1 and definition.Respawn <= 30, ("respawn bounds at %s"):format(definition.Id))

		assert(type(definition.Size) == "table" and #definition.Size == 3, ("size shape at %s"):format(definition.Id))
		for _, axis in definition.Size do
			assert(type(axis) == "number" and axis > 0, ("positive size at %s"):format(definition.Id))
		end

		assert(
			type(definition.Color) == "table" and #definition.Color == 3,
			("color shape at %s"):format(definition.Id)
		)
		for _, channel in definition.Color do
			assert(
				type(channel) == "number" and channel >= 0 and channel <= 255,
				("color bounds at %s"):format(definition.Id)
			)
		end

		previousRequirement = definition.RequiredGravity
		previousGravityGain = definition.GravityGain
		previousXp = definition.XP
	end

	for zoneId in zoneIds do
		assert(perZone[zoneId] == 5, ("%s must have five object classes"):format(zoneId))
	end

	assert(ObjectConfig[1].RequiredGravity == 0, "starter object must be immediately collectible")
	assert(ObjectConfig[#ObjectConfig].RequiredGravity >= 20000, "late-game object tier")
end
