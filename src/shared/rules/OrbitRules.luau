--!strict

local OrbitRules = {}

function OrbitRules.tierBand(tier: number): number
	return math.clamp(math.ceil(math.max(1, tier) / 5), 1, 5)
end

function OrbitRules.radiusScale(viewportX: number, viewportY: number, avatarHeight: number): number
	local shortEdge = math.max(1, math.min(viewportX, viewportY))
	local viewportScale = math.clamp(shortEdge / 760, 0.72, 1.08)
	local avatarScale = math.clamp(math.max(1, avatarHeight) / 5.5, 0.90, 1.16)
	return viewportScale * avatarScale
end

function OrbitRules.occlusionFade(
	screenX: number,
	screenY: number,
	depth: number,
	viewportX: number,
	viewportY: number
): number
	if depth <= 0 then
		return 0
	end

	local dx = screenX - viewportX * 0.5
	local dy = screenY - viewportY * 0.5
	local distance = math.sqrt(dx * dx + dy * dy)
	local radius = math.max(48, math.min(viewportX, viewportY) * 0.15)
	if distance >= radius then
		return 0
	end
	return 0.58 * (1 - distance / radius)
end

function OrbitRules.replacementIndex(
	entries: { any },
	objectId: string,
	tierBand: number,
	visibleSlots: number
): number?
	for index, entry in entries do
		if entry.ObjectId == objectId then
			return index
		end
	end

	if #entries < visibleSlots then
		return nil
	end

	for index, entry in entries do
		if entry.TierBand == tierBand then
			return index
		end
	end

	return if #entries > 0 then 1 else nil
end

return table.freeze(OrbitRules)
