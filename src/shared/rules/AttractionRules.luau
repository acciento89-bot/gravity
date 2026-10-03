--!strict

local AttractionRules = {}

local BASE_RADIUS = 10
local MAX_RADIUS = 30
local RADIUS_LOG_SCALE = 2.35

function AttractionRules.radiusForGravity(gravity: number): number
	local safeGravity = math.max(0, gravity)
	local radius = BASE_RADIUS
	if safeGravity > 0 then
		radius += math.log10(safeGravity + 1) * RADIUS_LOG_SCALE
	end
	return math.clamp(radius, BASE_RADIUS, MAX_RADIUS)
end

function AttractionRules.canAttract(gravity: number, requiredGravity: number): boolean
	return gravity >= math.max(0, requiredGravity)
end

return table.freeze(AttractionRules)
