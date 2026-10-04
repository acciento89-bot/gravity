--!strict

local LocalizationRules = {}

local TEXT = {
	en = {
		walk_forward = "WALK FORWARD · NEARBY OBJECTS SNAP INTO YOUR GRAVITY ORBIT",
		follow_road = "FOLLOW THE ROAD · COLLECT THE NEXT OBJECTS TO GROW",
		grow_downtown = "BIGGER GRAVITY PULLS BIGGER OBJECTS · DOWNTOWN OPENS AT 120",
		collapse_hint = "LV 50 + 5K GRAVITY = COLLAPSE · RESET THE RUN FOR +1 CORE",
		need_gravity = "NEED %d GRAVITY",
		collapsed = "+1 CORE · NEXT RUN XP ×%.2f",
		purchase_applied = "PURCHASE APPLIED",
		style_updated = "STYLE UPDATED",
		locked = "LOCKED · %s GRAVITY%s",
		unlocked = "UNLOCKED · %s",
		welcome = "WELCOME · %s",
		access = "ACCESS",
		access_title = "ACCESSIBILITY",
		reduced_motion = "REDUCED MOTION",
		reduced_on = "ON · CALMER ORBIT / COLLAPSE",
		reduced_off = "OFF · FULL EFFECTS",
		access_note = "Objectives and requirements remain readable without audio or color cues.",
	},
	de = {
		walk_forward = "GEH NACH VORN · NAHE OBJEKTE WERDEN AUTOMATISCH ANGEZOGEN",
		follow_road = "FOLGE DER STRASSE · SAMMLE DIE NÄCHSTEN OBJEKTE UND WACHSE",
		grow_downtown = "MEHR GRAVITÄT ZIEHT GRÖSSERE OBJEKTE AN · DOWNTOWN AB 120",
		collapse_hint = "LV 50 + 5K GRAVITÄT = KOLLAPS · RESET FÜR +1 KERN",
		need_gravity = "BRAUCHT %d GRAVITÄT",
		collapsed = "+1 KERN · NÄCHSTER RUN XP ×%.2f",
		purchase_applied = "KAUF ANGEWENDET",
		style_updated = "STIL AKTUALISIERT",
		locked = "GESPERRT · %s GRAVITÄT%s",
		unlocked = "FREIGESCHALTET · %s",
		welcome = "WILLKOMMEN · %s",
		access = "ZUGANG",
		access_title = "BARRIEREFREIHEIT",
		reduced_motion = "REDUZIERTE BEWEGUNG",
		reduced_on = "AN · RUHIGERER ORBIT / KOLLAPS",
		reduced_off = "AUS · VOLLE EFFEKTE",
		access_note = "Ziele und Anforderungen bleiben auch ohne Ton oder Farbsignale verständlich.",
	},
}

function LocalizationRules.language(localeId: string): string
	local locale = string.lower(localeId)
	return if string.sub(locale, 1, 2) == "de" then "de" else "en"
end

function LocalizationRules.text(localeId: string, key: string): string
	local lang = LocalizationRules.language(localeId)
	return TEXT[lang][key] or TEXT.en[key] or key
end

function LocalizationRules.format(localeId: string, key: string, ...: any): string
	return string.format(LocalizationRules.text(localeId, key), ...)
end

return table.freeze(LocalizationRules)
