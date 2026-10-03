--!strict

local ReceiptRules = {}

function ReceiptRules.apply(profile: any, purchaseId: string, product: any, now: number): (boolean, string)
	if purchaseId == "" then
		return false, "MissingPurchaseId"
	end
	if profile.ProcessedReceipts[purchaseId] == true then
		return false, "AlreadyProcessed"
	end

	if product.Key == "gravity_2x_15m" then
		local base = math.max(now, profile.GravityBoostUntil or 0)
		profile.GravityBoostUntil = base + product.DurationSeconds
	elseif product.Key == "xp_2x_15m" then
		local base = math.max(now, profile.XpBoostUntil or 0)
		profile.XpBoostUntil = base + product.DurationSeconds
	elseif product.Key == "shards_100" then
		profile.Shards += product.Amount
	else
		return false, "UnknownProduct"
	end

	profile.ProcessedReceipts[purchaseId] = true
	return true, "Granted"
end

return table.freeze(ReceiptRules)
