--!strict

local FeedbackRules = {}

function FeedbackRules.collectBand(gravityGain: number): string
	local gain = math.max(0, gravityGain)
	if gain < 60 then
		return "Small"
	elseif gain < 400 then
		return "Medium"
	end
	return "Massive"
end

function FeedbackRules.collectPitch(band: string): number
	if band == "Small" then
		return 1.18
	elseif band == "Medium" then
		return 0.92
	end
	return 0.68
end

function FeedbackRules.collectVolume(band: string): number
	if band == "Small" then
		return 0.12
	elseif band == "Medium" then
		return 0.17
	end
	return 0.22
end

function FeedbackRules.coreMilestoneBand(cores: number): string
	local safe = math.max(0, math.floor(cores))
	if safe > 0 and safe % 10 == 0 then
		return "Major"
	elseif safe > 0 and safe % 5 == 0 then
		return "Medium"
	end
	return "Normal"
end

return table.freeze(FeedbackRules)
