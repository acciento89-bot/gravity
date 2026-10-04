--!strict

local OnboardingRules = {}

local CAN_PATH = {
	{ 6, 0 },
	{ 13, 2 },
	{ 20, -2 },
	{ 27, 2 },
	{ 34, 0 },
}

local ESCALATION = {
	toy_block = { 42, -2 },
	shoe = { 51, 2 },
	garden_chair = { 61, -2 },
	barbecue = { 72, 2 },
}

function OnboardingRules.collectibleOffset(objectId: string, copyIndex: number): (number?, number?)
	if objectId == "can" and copyIndex >= 1 and copyIndex <= #CAN_PATH then
		local point = CAN_PATH[copyIndex]
		return point[1], point[2]
	end
	local point = ESCALATION[objectId]
	if point and copyIndex == 1 then
		return point[1], point[2]
	end
	return nil, nil
end

function OnboardingRules.firstCollectibleDistance(): number
	local x, z = OnboardingRules.collectibleOffset("can", 1)
	return math.sqrt((x or 0) ^ 2 + (z or 0) ^ 2)
end

function OnboardingRules.spawnOffset(slot: number): (number, number)
	local safeSlot = math.clamp(math.floor(slot), 1, 8)
	local angle = ((safeSlot - 1) / 8) * math.pi * 2
	return math.cos(angle) * 3, math.sin(angle) * 3
end

return table.freeze(OnboardingRules)
