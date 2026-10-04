--!strict

local ViewportRules = {}

export type Layout = {
	Mode: string,
	BarWidth: number,
	BarHeight: number,
	BarTop: number,
	BarCentered: boolean,
	GravityTextSize: number,
	SecondaryTextSize: number,
	ZoneVisible: boolean,
	TutorialWidth: number,
	TutorialTop: number,
	TutorialTextSize: number,
	DailyWidth: number,
	DailyHeight: number,
	DailyTextSize: number,
	CollapseWidth: number,
	CollapseHeight: number,
	CollapseInset: number,
	CollapseTextSize: number,
}

function ViewportRules.classify(viewportX: number, viewportY: number, touchEnabled: boolean, tenFoot: boolean): string
	if tenFoot then
		return "console"
	end
	local shortEdge = math.min(viewportX, viewportY)
	if touchEnabled and shortEdge < 620 then
		return "phone"
	end
	if touchEnabled then
		return "tablet"
	end
	return "desktop"
end

function ViewportRules.layout(viewportX: number, viewportY: number, touchEnabled: boolean, tenFoot: boolean): Layout
	local mode = ViewportRules.classify(viewportX, viewportY, touchEnabled, tenFoot)
	if mode == "phone" then
		return {
			Mode = mode,
			BarWidth = math.max(360, viewportX - 178),
			BarHeight = 54,
			BarTop = 6,
			BarCentered = false,
			GravityTextSize = 18,
			SecondaryTextSize = 14,
			ZoneVisible = false,
			TutorialWidth = math.max(320, math.min(400, viewportX - 64)),
			TutorialTop = 66,
			TutorialTextSize = 9,
			DailyWidth = math.max(220, math.min(330, viewportX - 190)),
			DailyHeight = 32,
			DailyTextSize = 9,
			CollapseWidth = 154,
			CollapseHeight = 52,
			CollapseInset = 14,
			CollapseTextSize = 15,
		}
	elseif mode == "tablet" then
		return {
			Mode = mode,
			BarWidth = 600,
			BarHeight = 68,
			BarTop = 10,
			BarCentered = true,
			GravityTextSize = 24,
			SecondaryTextSize = 18,
			ZoneVisible = true,
			TutorialWidth = 600,
			TutorialTop = 86,
			TutorialTextSize = 12,
			DailyWidth = 420,
			DailyHeight = 40,
			DailyTextSize = 12,
			CollapseWidth = 200,
			CollapseHeight = 62,
			CollapseInset = 22,
			CollapseTextSize = 18,
		}
	elseif mode == "console" then
		return {
			Mode = mode,
			BarWidth = 760,
			BarHeight = 84,
			BarTop = 28,
			BarCentered = true,
			GravityTextSize = 30,
			SecondaryTextSize = 22,
			ZoneVisible = true,
			TutorialWidth = 760,
			TutorialTop = 124,
			TutorialTextSize = 17,
			DailyWidth = 520,
			DailyHeight = 54,
			DailyTextSize = 17,
			CollapseWidth = 250,
			CollapseHeight = 82,
			CollapseInset = 42,
			CollapseTextSize = 24,
		}
	end
	return {
		Mode = mode,
		BarWidth = 560,
		BarHeight = 64,
		BarTop = 8,
		BarCentered = true,
		GravityTextSize = 23,
		SecondaryTextSize = 17,
		ZoneVisible = true,
		TutorialWidth = 560,
		TutorialTop = 78,
		TutorialTextSize = 11,
		DailyWidth = 380,
		DailyHeight = 36,
		DailyTextSize = 11,
		CollapseWidth = 190,
		CollapseHeight = 62,
		CollapseInset = 18,
		CollapseTextSize = 18,
	}
end

return table.freeze(ViewportRules)
