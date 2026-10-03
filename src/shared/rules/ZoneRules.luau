--!strict

local ZoneRules = {}

function ZoneRules.isUnlocked(zone: any, gravity: number, cores: number): boolean
	return gravity >= math.max(0, zone.MinGravity or 0) and cores >= math.max(0, zone.MinCores or 0)
end

function ZoneRules.highestUnlocked(zones: { any }, gravity: number, cores: number): any?
	local best = nil
	for _, zone in zones do
		if ZoneRules.isUnlocked(zone, gravity, cores) then
			if not best or (zone.Order or 0) > (best.Order or 0) then
				best = zone
			end
		end
	end
	return best
end

function ZoneRules.zoneContainingPosition(zones: { any }, x: number, z: number): any?
	for _, zone in zones do
		local center = zone.Center
		local size = zone.Size
		if type(center) == "table" and type(size) == "table" then
			local halfX = math.max(0, tonumber(size[1]) or 0) / 2
			local halfZ = math.max(0, tonumber(size[3]) or 0) / 2
			local centerX = tonumber(center[1]) or 0
			local centerZ = tonumber(center[3]) or 0
			if math.abs(x - centerX) <= halfX and math.abs(z - centerZ) <= halfZ then
				return zone
			end
		end
	end
	return nil
end

function ZoneRules.previousZone(zones: { any }, zone: any): any?
	local targetOrder = zone.Order or 0
	local best = nil
	for _, candidate in zones do
		local order = candidate.Order or 0
		if order < targetOrder and (not best or order > (best.Order or 0)) then
			best = candidate
		end
	end
	return best
end

function ZoneRules.safeReturnXZ(zones: { any }, lockedZone: any): (number, number)
	local previous = ZoneRules.previousZone(zones, lockedZone)
	if not previous then
		return 0, 0
	end

	local center = previous.Center or { 0, 0, 0 }
	local size = previous.Size or { 0, 0, 0 }
	local centerX = tonumber(center[1]) or 0
	local centerZ = tonumber(center[3]) or 0
	local halfX = math.max(0, tonumber(size[1]) or 0) / 2
	return centerX + math.max(0, halfX - 12), centerZ
end

return table.freeze(ZoneRules)
