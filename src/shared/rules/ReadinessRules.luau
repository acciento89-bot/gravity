--!strict

local ReadinessRules = {}

function ReadinessRules.evaluate(platform: any, monetization: any): any
	local blockers = {}
	if (platform.UniverseId or 0) <= 0 then
		table.insert(blockers, { Code = "UNIVERSE_ID", Detail = "Roblox Universe ID is not configured." })
	end
	if (platform.DevelopmentPlaceId or 0) <= 0 then
		table.insert(blockers, { Code = "DEV_PLACE_ID", Detail = "Development Place ID is not configured." })
	end
	if (platform.ProductionPlaceId or 0) <= 0 then
		table.insert(blockers, { Code = "PROD_PLACE_ID", Detail = "Production Place ID is not configured." })
	end
	for name, product in monetization.Products do
		if (product.ProductId or 0) <= 0 then
			table.insert(blockers, {
				Code = "PRODUCT_" .. string.upper(name),
				Detail = ("%s developer product ID is not configured."):format(name),
			})
		end
	end
	return { Ready = #blockers == 0, Blockers = blockers }
end

return table.freeze(ReadinessRules)
