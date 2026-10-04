local SecurityRules = require("../src/shared/rules/SecurityRules")

return function()
	assert(SecurityRules.validToken("Collapse", 12), "normal action token")
	assert(not SecurityRules.validToken("", 12), "empty token rejected")
	assert(not SecurityRules.validToken(string.rep("x", 40), 12), "oversized token rejected")
	assert(SecurityRules.allow(10, nil, 0.25), "first action allowed")
	assert(not SecurityRules.allow(10.10, 10, 0.25), "spam interval rejected")
	assert(SecurityRules.allow(10.25, 10, 0.25), "action allowed at interval boundary")
	assert(SecurityRules.validCosmeticPayload("Buy", "Orbit", "Galaxy"), "valid buy payload")
	assert(SecurityRules.validCosmeticPayload("Equip", "Singularity", "Solar"), "valid equip payload")
	assert(not SecurityRules.validCosmeticPayload("Grant", "Orbit", "Galaxy"), "grant action rejected")
	assert(not SecurityRules.validCosmeticPayload("Buy", "Unknown", "Galaxy"), "unknown category rejected")
end
