local ObjectConfig = require("../src/shared/config/ObjectConfig")
local ZoneConfig = require("../src/shared/config/ZoneConfig")
local BalanceSimulator = require("./support/BalanceSimulator")

return function()
	local times = {}
	for cores = 0, 9 do
		local result = BalanceSimulator.simulateRun(cores, 1.0, ObjectConfig, ZoneConfig, 3600)
		assert(result.CanCollapse, ("collapse %d must be reachable"):format(cores + 1))
		times[cores + 1] = result.Seconds
	end

	assert(times[1] >= 8 * 60 and times[1] <= 15 * 60, "first collapse target must be 8-15 minutes")
	assert(times[2] < times[1], "second collapse must be faster than first")
	for index = 2, #times do
		assert(times[index] < times[index - 1], ("collapse %d must accelerate"):format(index))
	end

	local formatted = {}
	for index, seconds in times do
		formatted[index] = ("%.2f"):format(seconds / 60)
	end
	print("+1 Gravity balance minutes C1-C10: " .. table.concat(formatted, ", "))
end
