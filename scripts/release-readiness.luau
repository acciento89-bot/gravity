local ReadinessRules = require("../src/shared/rules/ReadinessRules")
local PlatformConfig = require("../src/shared/config/PlatformConfig")
local MonetizationConfig = require("../src/shared/config/MonetizationConfig")

local result = ReadinessRules.evaluate(PlatformConfig, MonetizationConfig)

print("+1 Gravity release-readiness report")
print(("Ready: %s"):format(if result.Ready then "yes" else "no"))
if #result.Blockers == 0 then
	print("No configuration blockers detected.")
else
	print(("External configuration blockers: %d"):format(#result.Blockers))
	for index, blocker in result.Blockers do
		print(("%02d. %s - %s"):format(index, blocker.Code, blocker.Detail))
	end
end
