--!strict

local SecurityRules = {}

function SecurityRules.validToken(value: any, maxLength: number): boolean
	return type(value) == "string" and #value > 0 and #value <= math.max(1, math.floor(maxLength))
end

function SecurityRules.inAllowlist(value: string, allowed: { [string]: boolean }): boolean
	return allowed[value] == true
end

function SecurityRules.allow(now: number, previous: number?, minimumInterval: number): boolean
	if previous == nil then
		return true
	end
	return now - previous >= math.max(0, minimumInterval)
end

function SecurityRules.validCosmeticPayload(action: any, category: any, name: any): boolean
	if
		not SecurityRules.validToken(action, 12)
		or not SecurityRules.validToken(category, 16)
		or not SecurityRules.validToken(name, 32)
	then
		return false
	end
	local actionAllowed = action == "Buy" or action == "Equip"
	local categoryAllowed = category == "Orbit" or category == "Singularity"
	return actionAllowed and categoryAllowed
end

return table.freeze(SecurityRules)
