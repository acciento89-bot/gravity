--!strict

local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local LocalizationRules = require(shared.rules.LocalizationRules)
local LocaleText = {}
local locale = LocalizationService.RobloxLocaleId

function LocaleText.t(key: string, ...: any): string
	return LocalizationRules.format(locale, key, ...)
end

function LocaleText.resolve(key: string, fallback: string): string
	return if LocalizationRules.has(locale, key) then LocalizationRules.text(locale, key) else fallback
end

function LocaleText.coreWord(count: number): string
	return LocaleText.t(if math.floor(count) == 1 then "core_singular" else "core_plural")
end

function LocaleText.zoneName(id: string, fallback: string): string
	return LocaleText.resolve("zone_" .. id, fallback)
end

function LocaleText.cosmeticName(category: string, name: string, fallback: string): string
	return LocaleText.resolve("cosmetic_" .. string.lower(category) .. "_" .. name, fallback)
end

function LocaleText.productName(key: string, fallback: string): string
	return LocaleText.resolve("product_" .. key, fallback)
end

function LocaleText.dailyMission(daily: any): string
	local target = tonumber(daily.Target) or 0
	if daily.Type == "Collect" then
		return LocaleText.t("mission_collect", target)
	end
	if daily.Type == "Gravity" then
		local formatted = if target >= 1000
			then ("%.1fK"):format(target / 1000):gsub("%.0K", "K")
			else tostring(math.floor(target))
		return LocaleText.t("mission_gravity", formatted)
	end
	if daily.Type == "Collapse" then
		return LocaleText.t("mission_collapse")
	end
	return tostring(daily.Label or "")
end

return LocaleText
