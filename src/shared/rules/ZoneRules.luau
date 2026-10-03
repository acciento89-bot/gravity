--!strict

local ZoneRules = {}

function ZoneRules.isUnlocked(zone: any, gravity: number, cores: number): boolean
	return gravity >= (zone.MinGravity or 0) and cores >= (zone.MinCores or 0)
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

return table.freeze(ZoneRules)
