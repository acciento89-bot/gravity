--!strict

local PerformanceRules = {}

function PerformanceRules.collectibleCount(objectClasses: number, copiesPerClass: number): number
	return math.max(0, math.floor(objectClasses)) * math.max(0, math.floor(copiesPerClass))
end

function PerformanceRules.scanChecksPerSecond(players: number, collectibles: number, scanInterval: number): number
	local interval = math.max(0.05, scanInterval)
	return math.max(0, math.floor(players)) * math.max(0, math.floor(collectibles)) / interval
end

function PerformanceRules.streamingDecision(
	worldSpanStuds: number,
	collectibleCount: number,
	runtimeProfiled: boolean
): string
	if not runtimeProfiled then
		return "DeferUntilDeviceProfile"
	end
	if worldSpanStuds >= 1400 or collectibleCount >= 240 then
		return "Enable"
	end
	return "Optional"
end

return table.freeze(PerformanceRules)
