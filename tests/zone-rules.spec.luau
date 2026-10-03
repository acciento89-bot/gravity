local ZoneRules = require("../src/shared/rules/ZoneRules")
local ZoneConfig = require("../src/shared/config/ZoneConfig")

return function()
	local zones = {
		{ Order = 1, MinGravity = 0, MinCores = 0, Id = "a", Center = { 0, 0, 0 }, Size = { 100, 1, 100 } },
		{ Order = 2, MinGravity = 100, MinCores = 0, Id = "b", Center = { 130, 0, 0 }, Size = { 120, 1, 100 } },
		{ Order = 3, MinGravity = 500, MinCores = 1, Id = "c", Center = { 280, 0, 0 }, Size = { 140, 1, 100 } },
	}
	assert(ZoneRules.highestUnlocked(zones, 0, 0).Id == "a", "first zone")
	assert(ZoneRules.highestUnlocked(zones, 200, 0).Id == "b", "gravity zone")
	assert(ZoneRules.highestUnlocked(zones, 999, 0).Id == "b", "core gate")
	assert(ZoneRules.highestUnlocked(zones, 999, 1).Id == "c", "core zone")

	assert(ZoneRules.zoneContainingPosition(zones, 0, 0).Id == "a", "position in first zone")
	assert(ZoneRules.zoneContainingPosition(zones, 130, 20).Id == "b", "position in second zone")
	assert(ZoneRules.zoneContainingPosition(zones, 999, 0) == nil, "position outside zones")
	assert(ZoneRules.previousZone(zones, zones[3]).Id == "b", "previous zone")

	local safeX, safeZ = ZoneRules.safeReturnXZ(zones, zones[3])
	assert(safeX == 178 and safeZ == 0, "safe return point inside previous zone")
	assert(ZoneRules.isUnlocked(zones[3], 500, 1), "full gate requirement")
	assert(not ZoneRules.isUnlocked(zones[3], 500, 0), "core gate enforced")

	assert(#ZoneConfig == 5, "production world has five zones")
	local previousOrder = 0
	local previousMinGravity = -1
	local previousMinCores = -1
	local previousRightEdge = nil
	for _, zone in ZoneConfig do
		assert(zone.Order == previousOrder + 1, "zone orders contiguous")
		assert(type(zone.DisplayName) == "string" and zone.DisplayName ~= "", "zone display name")
		assert(zone.MinGravity >= previousMinGravity, "zone gravity requirements monotonic")
		assert(zone.MinCores >= previousMinCores, "zone core requirements monotonic")
		assert(ZoneRules.zoneContainingPosition(ZoneConfig, zone.Center[1], zone.Center[3]).Id == zone.Id, "zone center resolves")

		local leftEdge = zone.Center[1] - zone.Size[1] / 2
		if previousRightEdge then
			assert(leftEdge > previousRightEdge, "production zones must not overlap")
		end
		previousRightEdge = zone.Center[1] + zone.Size[1] / 2
		previousOrder = zone.Order
		previousMinGravity = zone.MinGravity
		previousMinCores = zone.MinCores
	end
end
