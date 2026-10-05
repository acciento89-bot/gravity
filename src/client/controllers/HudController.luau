--!strict

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local ViewportRules = require(shared.rules.ViewportRules)
local LocaleText = require(script.Parent.LocaleText)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local HudController = {}

local function tr(key: string, ...: any): string
	return LocaleText.t(key, ...)
end

local COLORS = {
	Foundation = Color3.fromRGB(18, 25, 35),
	Surface = Color3.fromRGB(31, 42, 55),
	Text = Color3.fromRGB(246, 249, 252),
	Muted = Color3.fromRGB(161, 177, 194),
	Cyan = Color3.fromRGB(91, 220, 239),
	Violet = Color3.fromRGB(164, 134, 255),
	Gold = Color3.fromRGB(255, 211, 96),
	Green = Color3.fromRGB(105, 224, 154),
}

local state: any = nil
local gravityValue: TextLabel
local levelValue: TextLabel
local coresValue: TextLabel
local zoneLabel: TextLabel
local progressFill: Frame
local tutorialLabel: TextLabel
local dailyLabel: TextLabel
local collapseButton: TextButton
local toast: TextLabel
local logo: Frame
local orbitBadge: Frame
local orbitBadgeText: TextLabel
local conceptShowcase: Frame
local conceptProgressText: TextLabel
local conceptProgressFill: Frame
local conceptShards: TextLabel
local conceptDailyCaption: TextLabel
local conceptDailyTiles: { Frame } = {}

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
end

local function stroke(parent: Instance, color: Color3, transparency: number)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Thickness = 1
	item.Transparency = transparency
	item.Parent = parent
end

local function label(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	textSize: number,
	color: Color3
): TextLabel
	local item = Instance.new("TextLabel")
	item.Size = size
	item.Position = position
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.Font = Enum.Font.GothamMedium
	item.Text = text
	item.TextSize = textSize
	item.TextColor3 = color
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function compactNumber(value: number): string
	local abs = math.abs(value)
	if abs >= 1e9 then
		return ("%.1fB"):format(value / 1e9)
	elseif abs >= 1e6 then
		return ("%.1fM"):format(value / 1e6)
	elseif abs >= 1e3 then
		return ("%.1fK"):format(value / 1e3)
	end
	return tostring(math.floor(value + 0.5))
end

local function showToast(text: string, color: Color3?)
	toast.Text = text
	toast.TextColor3 = color or COLORS.Text
	toast.Visible = true
	task.delay(2.5, function()
		if toast.Text == text then
			toast.Visible = false
		end
	end)
end

local function render()
	if not state or state.Ready ~= true then
		return
	end
	gravityValue.Text = compactNumber(state.Gravity)
	levelValue.Text = ("LV %d"):format(state.Level)
	coresValue.Text = ("◉ %d"):format(state.Cores)
	zoneLabel.Text = string.upper(LocaleText.zoneName(state.Zone.Id, state.Zone.DisplayName))
	local orbitCount = tonumber(state.TotalObjects) or 0
	local orbitStage = if orbitCount < 5
		then "I"
		elseif orbitCount < 20 then "II"
		elseif orbitCount < 60 then "III"
		elseif orbitCount < 150 then "IV"
		else "V"
	orbitBadgeText.Text = ("ORBIT %s  •  %s"):format(orbitStage, compactNumber(orbitCount))
	local levelProgress = math.clamp(state.LevelProgress or 0, 0, 1)
	progressFill.Size = UDim2.fromScale(levelProgress, 1)
	conceptProgressText.Text = ("LV %d • %s • %s OBJECTS"):format(
		state.Level,
		string.upper(LocaleText.zoneName(state.Zone.Id, state.Zone.DisplayName)),
		compactNumber(orbitCount)
	)
	conceptProgressFill.Size = UDim2.fromScale(levelProgress, 1)
	conceptShards.Text = ("◆ %s"):format(compactNumber(tonumber(state.Shards) or 0))
	collapseButton.Visible = state.CanCollapse == true
	collapseButton.Selectable = state.CanCollapse == true

	if state.TotalObjects == 0 then
		tutorialLabel.Text = tr("walk_forward")
		tutorialLabel.Visible = true
	elseif state.TotalObjects < 5 then
		tutorialLabel.Text = tr("follow_road")
		tutorialLabel.Visible = true
	elseif state.Cores == 0 and state.Level < 10 then
		tutorialLabel.Text = tr("grow_downtown")
		tutorialLabel.Visible = true
	elseif state.Cores == 0 and state.Level >= 35 and state.Level < 50 then
		tutorialLabel.Text = tr("collapse_hint")
		tutorialLabel.Visible = true
	else
		tutorialLabel.Visible = false
	end

	local daily = state.Daily
	if daily then
		local streak = math.max(0, tonumber(daily.Streak) or 0)
		if daily.Claimed then
			dailyLabel.Text = tr("daily_hud_complete", daily.Streak)
			dailyLabel.TextColor3 = COLORS.Green
			conceptDailyCaption.Text = ("COMPLETE • STREAK %d"):format(streak)
		else
			dailyLabel.Text = tr("daily_hud_progress", LocaleText.dailyMission(daily), daily.Progress, daily.Target)
			dailyLabel.TextColor3 = COLORS.Muted
			conceptDailyCaption.Text =
				("MISSION %d / %d"):format(tonumber(daily.Progress) or 0, tonumber(daily.Target) or 1)
		end
		for index, tile in conceptDailyTiles do
			if index <= math.clamp(streak, 0, 5) then
				tile.BackgroundColor3 = Color3.fromRGB(46, 92, 74)
			elseif not daily.Claimed and index == math.clamp(streak + 1, 1, 5) then
				tile.BackgroundColor3 = Color3.fromRGB(74, 62, 116)
			else
				tile.BackgroundColor3 = COLORS.Surface
			end
		end
	end

	if state.Event == "Collapsed" then
		showToast(tr("collapsed", 1 + state.Cores * 0.25), COLORS.Gold)
	elseif state.Event == "PurchaseGranted" then
		showToast(tr("purchase_applied"), COLORS.Green)
	elseif state.Event == "CosmeticUpdated" then
		showToast(tr("style_updated"), COLORS.Violet)
	elseif state.Event == "ZoneLocked" and type(state.EventData) == "table" then
		local gate = state.EventData
		local coreText = if (gate.MinCores or 0) > 0
			then tr("core_requirement", gate.MinCores, LocaleText.coreWord(gate.MinCores))
			else ""
		showToast(tr("locked", compactNumber(gate.MinGravity or 0), coreText), COLORS.Gold)
	elseif state.Event == "ZoneUnlocked" and type(state.EventData) == "table" then
		showToast(
			tr(
				"unlocked",
				string.upper(LocaleText.zoneName(state.EventData.Id or "", state.EventData.DisplayName or "ZONE"))
			),
			COLORS.Green
		)
	elseif state.Event == "ZoneEntered" and type(state.EventData) == "table" then
		showToast(
			tr(
				"welcome",
				string.upper(LocaleText.zoneName(state.EventData.Id or "", state.EventData.DisplayName or "ZONE"))
			),
			COLORS.Cyan
		)
	end
end

local function build()
	local old = playerGui:FindFirstChild("Plus1GravityHud")
	if old then
		old:Destroy()
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityHud"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = false
	screen.DisplayOrder = 20
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = playerGui

	logo = Instance.new("Frame")
	logo.Name = "Plus1GravityLogo"
	logo.Position = UDim2.fromOffset(18, 10)
	logo.Size = UDim2.fromOffset(204, 72)
	logo.BackgroundTransparency = 1
	logo.Parent = screen

	local plusOne = label(logo, "+1", UDim2.fromOffset(74, 38), UDim2.fromOffset(0, 0), 34, COLORS.Gold)
	plusOne.Font = Enum.Font.GothamBlack
	plusOne.TextStrokeColor3 = Color3.fromRGB(43, 38, 61)
	plusOne.TextStrokeTransparency = 0.32

	local gravityWord = label(logo, "GRAVITY", UDim2.fromOffset(142, 36), UDim2.fromOffset(52, 3), 27, COLORS.Cyan)
	gravityWord.Font = Enum.Font.GothamBlack
	gravityWord.TextStrokeColor3 = Color3.fromRGB(24, 43, 59)
	gravityWord.TextStrokeTransparency = 0.30

	local logoTag = label(
		logo,
		"ATTRACT • ORBIT • COLLAPSE",
		UDim2.fromOffset(200, 16),
		UDim2.fromOffset(2, 47),
		8,
		COLORS.Muted
	)
	logoTag.Font = Enum.Font.GothamBold

	orbitBadge = Instance.new("Frame")
	orbitBadge.Name = "OrbitBadge"
	orbitBadge.Position = UDim2.fromOffset(18, 84)
	orbitBadge.Size = UDim2.fromOffset(204, 38)
	orbitBadge.BackgroundColor3 = COLORS.Foundation
	orbitBadge.BackgroundTransparency = 0.06
	orbitBadge.BorderSizePixel = 0
	orbitBadge.Parent = screen
	corner(orbitBadge, 12)
	stroke(orbitBadge, COLORS.Violet, 0.48)

	orbitBadgeText =
		label(orbitBadge, "ORBIT I  •  0", UDim2.new(1, -16, 1, 0), UDim2.fromOffset(8, 0), 11, COLORS.Violet)
	orbitBadgeText.TextXAlignment = Enum.TextXAlignment.Center
	orbitBadgeText.Font = Enum.Font.GothamBold

	local bar = Instance.new("Frame")
	bar.Name = "Status"
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 8)
	bar.Size = UDim2.fromOffset(520, 64)
	bar.BackgroundColor3 = COLORS.Foundation
	bar.BackgroundTransparency = 0.06
	bar.BorderSizePixel = 0
	bar.Parent = screen
	corner(bar, 18)
	stroke(bar, COLORS.Cyan, 0.48)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.fromOffset(4, 38)
	accent.Position = UDim2.fromOffset(8, 10)
	accent.BackgroundColor3 = COLORS.Cyan
	accent.BorderSizePixel = 0
	accent.Parent = bar
	corner(accent, 4)

	local gravityCard = Instance.new("Frame")
	gravityCard.Size = UDim2.new(0.43, -10, 0, 42)
	gravityCard.Position = UDim2.fromOffset(20, 8)
	gravityCard.BackgroundTransparency = 1
	gravityCard.Parent = bar
	local title = label(gravityCard, tr("gravity"), UDim2.new(1, 0, 0, 14), UDim2.fromOffset(0, 0), 10, COLORS.Muted)
	title.Font = Enum.Font.GothamBold
	gravityValue = label(gravityCard, "0", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 13), 23, COLORS.Text)
	gravityValue.Font = Enum.Font.GothamBlack

	levelValue = label(bar, "LV 0", UDim2.fromOffset(92, 38), UDim2.new(0.47, 0, 0, 10), 17, COLORS.Cyan)
	levelValue.Font = Enum.Font.GothamBlack
	coresValue = label(bar, "◉ 0", UDim2.fromOffset(90, 38), UDim2.new(0.68, 0, 0, 10), 17, COLORS.Gold)
	coresValue.Font = Enum.Font.GothamBlack
	zoneLabel = label(bar, "BACKYARD", UDim2.fromOffset(118, 38), UDim2.new(0.82, 0, 0, 10), 11, COLORS.Muted)
	zoneLabel.TextXAlignment = Enum.TextXAlignment.Right

	local track = Instance.new("Frame")
	track.Name = "LevelTrack"
	track.Position = UDim2.new(0, 20, 1, -8)
	track.Size = UDim2.new(1, -40, 0, 3)
	track.BackgroundColor3 = COLORS.Surface
	track.BorderSizePixel = 0
	track.Parent = bar
	corner(track, 3)
	progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = COLORS.Cyan
	progressFill.BorderSizePixel = 0
	progressFill.Parent = track
	corner(progressFill, 3)

	tutorialLabel = label(screen, "", UDim2.fromOffset(520, 30), UDim2.new(0.5, -260, 0, 78), 11, COLORS.Cyan)
	tutorialLabel.BackgroundColor3 = COLORS.Foundation
	tutorialLabel.BackgroundTransparency = 0.15
	tutorialLabel.TextXAlignment = Enum.TextXAlignment.Center
	tutorialLabel.Font = Enum.Font.GothamBold
	tutorialLabel.Visible = false
	corner(tutorialLabel, 10)

	dailyLabel = label(screen, tr("daily"), UDim2.fromOffset(360, 36), UDim2.new(0, 14, 1, -50), 11, COLORS.Muted)
	dailyLabel.BackgroundColor3 = COLORS.Foundation
	dailyLabel.BackgroundTransparency = 0.1
	dailyLabel.TextXAlignment = Enum.TextXAlignment.Center
	dailyLabel.Font = Enum.Font.GothamBold
	corner(dailyLabel, 12)
	stroke(dailyLabel, COLORS.Violet, 0.65)

	collapseButton = Instance.new("TextButton")
	collapseButton.Name = "Collapse"
	collapseButton.AnchorPoint = Vector2.new(1, 1)
	collapseButton.Position = UDim2.new(1, -18, 1, -18)
	collapseButton.Size = UDim2.fromOffset(190, 62)
	collapseButton.BackgroundColor3 = COLORS.Violet
	collapseButton.BorderSizePixel = 0
	collapseButton.Font = Enum.Font.GothamBlack
	collapseButton.Text = tr("collapse") .. "  ◉"
	collapseButton.TextSize = 18
	collapseButton.TextColor3 = COLORS.Text
	collapseButton.Visible = false
	collapseButton.Selectable = true
	collapseButton.Parent = screen
	corner(collapseButton, 18)
	stroke(collapseButton, COLORS.Text, 0.72)

	toast = label(screen, "", UDim2.fromOffset(330, 46), UDim2.new(0.5, -165, 0.5, 120), 16, COLORS.Text)
	toast.BackgroundColor3 = COLORS.Foundation
	toast.BackgroundTransparency = 0.06
	toast.TextXAlignment = Enum.TextXAlignment.Center
	toast.Font = Enum.Font.GothamBlack
	toast.Visible = false
	corner(toast, 14)

	collapseButton.Activated:Connect(function()
		(remotes:WaitForChild("Action") :: RemoteEvent):FireServer("Collapse")
	end)

	conceptShowcase = Instance.new("Frame")
	conceptShowcase.Name = "ConceptShowcase"
	conceptShowcase.Size = UDim2.fromScale(1, 1)
	conceptShowcase.BackgroundTransparency = 1
	conceptShowcase.Visible = false
	conceptShowcase.Parent = screen

	local function gradient(panel: GuiObject, first: Color3, second: Color3, rotation: number?)
		local item = Instance.new("UIGradient")
		item.Rotation = rotation or 110
		item.Color = ColorSequence.new(first, second)
		item.Parent = panel
	end

	local function conceptButton(
		parent: Instance,
		name: string,
		text: string,
		size: UDim2,
		position: UDim2,
		background: Color3
	): TextButton
		local item = Instance.new("TextButton")
		item.Name = name
		item.Size = size
		item.Position = position
		item.BackgroundColor3 = background
		item.BorderSizePixel = 0
		item.Font = Enum.Font.GothamBold
		item.Text = text
		item.TextSize = 9
		item.TextColor3 = COLORS.Foundation
		item.Selectable = true
		item.AutoButtonColor = true
		item.Parent = parent
		corner(item, 9)
		return item
	end

	local function openConcept(screenName: string)
		local target = playerGui:FindFirstChild(screenName)
		local request = target and target:FindFirstChild("ConceptOpen")
		if request and request:IsA("BindableEvent") then
			request:Fire()
		end
	end

	local styleShowcase = Instance.new("Frame")
	styleShowcase.Name = "GravityShopShowcase"
	styleShowcase.AnchorPoint = Vector2.new(0, 1)
	styleShowcase.Position = UDim2.new(0, 18, 1, -18)
	styleShowcase.Size = UDim2.fromOffset(310, 210)
	styleShowcase.BackgroundColor3 = COLORS.Foundation
	styleShowcase.BackgroundTransparency = 0.02
	styleShowcase.BorderSizePixel = 0
	styleShowcase.Parent = conceptShowcase
	corner(styleShowcase, 20)
	stroke(styleShowcase, COLORS.Violet, 0.32)
	gradient(styleShowcase, Color3.fromRGB(50, 44, 80), COLORS.Foundation)

	local styleTitle =
		label(styleShowcase, "GRAVITY SHOP", UDim2.fromOffset(176, 28), UDim2.fromOffset(15, 8), 17, COLORS.Text)
	styleTitle.Font = Enum.Font.GothamBlack
	local featuredHint =
		label(styleShowcase, "FEATURED", UDim2.fromOffset(86, 20), UDim2.fromOffset(205, 11), 9, COLORS.Violet)
	featuredHint.Font = Enum.Font.GothamBold
	featuredHint.TextXAlignment = Enum.TextXAlignment.Right
	local boostOpen =
		conceptButton(styleShowcase, "BoostShop", "BOOSTS", UDim2.fromOffset(70, 22), UDim2.fromOffset(221, 34), COLORS.Gold)
	boostOpen.Activated:Connect(function()
		openConcept("Plus1GravityShop")
	end)

	local styleItems = {
		{ Name = "Plasma", Definition = CosmeticConfig.OrbitSkins.Plasma },
		{ Name = "Ember", Definition = CosmeticConfig.OrbitSkins.Ember },
		{ Name = "Galaxy", Definition = CosmeticConfig.OrbitSkins.Galaxy },
	}
	for index, entry in styleItems do
		local definition = entry.Definition
		local itemAccent = Color3.fromRGB(definition.Color[1], definition.Color[2], definition.Color[3])
		local card = Instance.new("Frame")
		card.Name = ("Featured%02d"):format(index)
		card.Position = UDim2.fromOffset(14 + (index - 1) * 98, 48)
		card.Size = UDim2.fromOffset(88, 148)
		card.BackgroundColor3 = COLORS.Surface
		card.BorderSizePixel = 0
		card.Parent = styleShowcase
		corner(card, 14)
		stroke(card, itemAccent, 0.38)
		gradient(card, itemAccent:Lerp(COLORS.Surface, 0.72), COLORS.Foundation)

		local preview = Instance.new("Frame")
		preview.Position = UDim2.fromOffset(8, 8)
		preview.Size = UDim2.fromOffset(72, 57)
		preview.BackgroundColor3 = Color3.fromRGB(13, 19, 29)
		preview.BorderSizePixel = 0
		preview.Parent = card
		corner(preview, 11)
		stroke(preview, itemAccent, 0.16)
		local ring = Instance.new("Frame")
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.Size = UDim2.fromOffset(44, 30)
		ring.BackgroundTransparency = 1
		ring.Parent = preview
		corner(ring, 99)
		local ringStroke = Instance.new("UIStroke")
		ringStroke.Color = itemAccent
		ringStroke.Thickness = 5
		ringStroke.Transparency = 0.05
		ringStroke.Parent = ring
		local core = Instance.new("Frame")
		core.AnchorPoint = Vector2.new(0.5, 0.5)
		core.Position = UDim2.fromScale(0.5, 0.5)
		core.Size = UDim2.fromOffset(12, 12)
		core.BackgroundColor3 = COLORS.Text
		core.BorderSizePixel = 0
		core.Parent = preview
		corner(core, 99)

		local itemName =
			label(card, definition.DisplayName, UDim2.fromOffset(78, 32), UDim2.fromOffset(5, 68), 9, COLORS.Text)
		itemName.Font = Enum.Font.GothamBold
		itemName.TextWrapped = true
		itemName.TextXAlignment = Enum.TextXAlignment.Center
		local price =
			label(card, ("◆ %d"):format(definition.Price), UDim2.fromOffset(78, 16), UDim2.fromOffset(5, 101), 9, COLORS.Gold)
		price.Font = Enum.Font.GothamBold
		price.TextXAlignment = Enum.TextXAlignment.Center
		local open =
			conceptButton(card, "OpenStyle", "OPEN", UDim2.fromOffset(70, 24), UDim2.fromOffset(9, 120), itemAccent)
		open.Activated:Connect(function()
			openConcept("Plus1GravityCosmetics")
		end)
	end

	local rightColumn = Instance.new("Frame")
	rightColumn.Name = "ConceptRightColumn"
	rightColumn.AnchorPoint = Vector2.new(1, 0)
	rightColumn.Position = UDim2.new(1, -170, 0, 88)
	rightColumn.Size = UDim2.fromOffset(232, 368)
	rightColumn.BackgroundTransparency = 1
	rightColumn.Parent = conceptShowcase

	local conceptProgressCard = Instance.new("Frame")
	conceptProgressCard.Name = "ConceptProgressCard"
	conceptProgressCard.Size = UDim2.fromOffset(232, 88)
	conceptProgressCard.BackgroundColor3 = COLORS.Foundation
	conceptProgressCard.BorderSizePixel = 0
	conceptProgressCard.Parent = rightColumn
	corner(conceptProgressCard, 17)
	stroke(conceptProgressCard, COLORS.Cyan, 0.34)
	gradient(conceptProgressCard, Color3.fromRGB(38, 55, 76), COLORS.Foundation)
	local progressTitle =
		label(conceptProgressCard, "GRAVITY PROGRESS", UDim2.fromOffset(204, 20), UDim2.fromOffset(14, 7), 13, COLORS.Text)
	progressTitle.Font = Enum.Font.GothamBlack
	conceptProgressText =
		label(conceptProgressCard, "LV 0 • BACKYARD • 0 OBJECTS", UDim2.fromOffset(204, 18), UDim2.fromOffset(14, 29), 8, COLORS.Muted)
	conceptProgressText.Font = Enum.Font.GothamBold
	conceptProgressText.TextXAlignment = Enum.TextXAlignment.Center
	local conceptTrack = Instance.new("Frame")
	conceptTrack.Position = UDim2.fromOffset(14, 56)
	conceptTrack.Size = UDim2.fromOffset(204, 14)
	conceptTrack.BackgroundColor3 = COLORS.Surface
	conceptTrack.BorderSizePixel = 0
	conceptTrack.ClipsDescendants = true
	conceptTrack.Parent = conceptProgressCard
	corner(conceptTrack, 99)
	conceptProgressFill = Instance.new("Frame")
	conceptProgressFill.Size = UDim2.fromScale(0, 1)
	conceptProgressFill.BackgroundColor3 = COLORS.Cyan
	conceptProgressFill.BorderSizePixel = 0
	conceptProgressFill.Parent = conceptTrack
	corner(conceptProgressFill, 99)

	local conceptDailyRewards = Instance.new("Frame")
	conceptDailyRewards.Name = "ConceptDailyRewards"
	conceptDailyRewards.Position = UDim2.fromOffset(0, 98)
	conceptDailyRewards.Size = UDim2.fromOffset(232, 130)
	conceptDailyRewards.BackgroundColor3 = COLORS.Foundation
	conceptDailyRewards.BorderSizePixel = 0
	conceptDailyRewards.Parent = rightColumn
	corner(conceptDailyRewards, 17)
	stroke(conceptDailyRewards, COLORS.Violet, 0.36)
	gradient(conceptDailyRewards, Color3.fromRGB(52, 44, 82), COLORS.Foundation)
	local dailyTitle =
		label(conceptDailyRewards, "DAILY REWARDS", UDim2.fromOffset(204, 20), UDim2.fromOffset(14, 6), 13, COLORS.Text)
	dailyTitle.Font = Enum.Font.GothamBlack
	conceptDailyCaption =
		label(conceptDailyRewards, "MISSION 0 / 1", UDim2.fromOffset(204, 16), UDim2.fromOffset(14, 27), 8, COLORS.Muted)
	conceptDailyCaption.Font = Enum.Font.GothamBold
	conceptDailyCaption.TextXAlignment = Enum.TextXAlignment.Center
	conceptDailyTiles = {}
	for index = 1, 5 do
		local tile = Instance.new("Frame")
		tile.Position = UDim2.fromOffset(9 + (index - 1) * 44, 48)
		tile.Size = UDim2.fromOffset(39, 67)
		tile.BackgroundColor3 = COLORS.Surface
		tile.BorderSizePixel = 0
		tile.Parent = conceptDailyRewards
		corner(tile, 9)
		stroke(tile, COLORS.Violet, 0.62)
		local day =
			label(tile, ("D%d"):format(index), UDim2.fromOffset(35, 14), UDim2.fromOffset(2, 4), 8, COLORS.Muted)
		day.Font = Enum.Font.GothamBold
		day.TextXAlignment = Enum.TextXAlignment.Center
		local reward = label(
			tile,
			if index == 1 then "✓" elseif index == 2 then "◆" elseif index == 3 then "✦" elseif index == 4 then "◉" else "★",
			UDim2.fromOffset(35, 31),
			UDim2.fromOffset(2, 22),
			15,
			if index == 1 then COLORS.Green else COLORS.Gold
		)
		reward.Font = Enum.Font.GothamBlack
		reward.TextXAlignment = Enum.TextXAlignment.Center
		table.insert(conceptDailyTiles, tile)
	end
	local dailyOpen =
		conceptButton(conceptDailyRewards, "OpenDaily", "DAILY", UDim2.fromOffset(66, 20), UDim2.new(1, -74, 0, 7), COLORS.Gold)
	dailyOpen.TextSize = 8
	dailyOpen.Activated:Connect(function()
		openConcept("Plus1GravityDaily")
	end)

	local conceptVistaCard = Instance.new("Frame")
	conceptVistaCard.Name = "ConceptVistaCard"
	conceptVistaCard.Position = UDim2.fromOffset(0, 238)
	conceptVistaCard.Size = UDim2.fromOffset(232, 130)
	conceptVistaCard.BackgroundColor3 = COLORS.Foundation
	conceptVistaCard.BorderSizePixel = 0
	conceptVistaCard.Parent = rightColumn
	corner(conceptVistaCard, 17)
	stroke(conceptVistaCard, COLORS.Gold, 0.38)
	gradient(conceptVistaCard, Color3.fromRGB(51, 47, 72), COLORS.Foundation)
	local vistaTitle =
		label(conceptVistaCard, "ORBIT PREVIEW", UDim2.fromOffset(204, 20), UDim2.fromOffset(14, 6), 13, COLORS.Text)
	vistaTitle.Font = Enum.Font.GothamBlack
	local conceptViewport = Instance.new("ViewportFrame")
	conceptViewport.Name = "OrbitPreview"
	conceptViewport.Position = UDim2.fromOffset(12, 31)
	conceptViewport.Size = UDim2.fromOffset(208, 87)
	conceptViewport.BackgroundColor3 = Color3.fromRGB(41, 52, 89)
	conceptViewport.BorderSizePixel = 0
	conceptViewport.Ambient = Color3.fromRGB(125, 135, 170)
	conceptViewport.LightColor = Color3.fromRGB(220, 235, 255)
	conceptViewport.LightDirection = Vector3.new(-1, -1, -0.5)
	conceptViewport.Parent = conceptVistaCard
	corner(conceptViewport, 12)
	local previewWorld = Instance.new("WorldModel")
	previewWorld.Parent = conceptViewport
	local previewCamera = Instance.new("Camera")
	previewCamera.CFrame = CFrame.lookAt(Vector3.new(11, 7, 14), Vector3.new(0, 1.5, 0))
	previewCamera.FieldOfView = 42
	previewCamera.Parent = conceptViewport
	conceptViewport.CurrentCamera = previewCamera
	local function previewPart(
		name: string,
		size: Vector3,
		position: Vector3,
		partColor: Color3,
		material: Enum.Material,
		shape: Enum.PartType?
	): Part
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Position = position
		part.Anchored = true
		part.CanCollide = false
		part.Color = partColor
		part.Material = material
		part.Shape = shape or Enum.PartType.Block
		part.Parent = previewWorld
		return part
	end
	previewPart(
		"AvatarCore",
		Vector3.new(1.5, 2.6, 1.2),
		Vector3.new(0, 1.5, 0),
		Color3.fromRGB(61, 76, 92),
		Enum.Material.SmoothPlastic
	)
	previewPart("OrbitA", Vector3.new(1.3, 1.0, 0.8), Vector3.new(-3.2, 2.2, 0), COLORS.Cyan, Enum.Material.Neon)
	previewPart("OrbitB", Vector3.new(1.0, 1.4, 0.8), Vector3.new(2.8, 3.0, 0.4), COLORS.Violet, Enum.Material.Neon)
	previewPart("OrbitC", Vector3.new(1.2, 0.8, 1.2), Vector3.new(0.8, 0.9, -3.0), COLORS.Gold, Enum.Material.Neon)
	previewPart(
		"Core",
		Vector3.new(1.2, 1.2, 1.2),
		Vector3.new(0, 4.5, -1.0),
		Color3.fromRGB(120, 235, 255),
		Enum.Material.Neon,
		Enum.PartType.Ball
	)

	conceptShards = Instance.new("TextLabel")
	conceptShards.Name = "ConceptShards"
	conceptShards.AnchorPoint = Vector2.new(1, 0)
	conceptShards.Position = UDim2.new(1, -326, 0, 18)
	conceptShards.Size = UDim2.fromOffset(94, 40)
	conceptShards.BackgroundColor3 = COLORS.Foundation
	conceptShards.BackgroundTransparency = 0.03
	conceptShards.BorderSizePixel = 0
	conceptShards.Font = Enum.Font.GothamBold
	conceptShards.Text = "◆ 0"
	conceptShards.TextSize = 13
	conceptShards.TextColor3 = COLORS.Gold
	conceptShards.Parent = conceptShowcase
	corner(conceptShards, 12)
	stroke(conceptShards, COLORS.Gold, 0.42)

	local function responsive()
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		local viewport = camera.ViewportSize
		local layout =
			ViewportRules.layout(viewport.X, viewport.Y, UserInputService.TouchEnabled, GuiService:IsTenFootInterface())
		local compact = layout.Mode == "phone"
		conceptShowcase.Visible = not compact
		logo.Visible = not compact
		orbitBadge.Visible = not compact
		dailyLabel.Visible = compact
		bar.Size = UDim2.fromOffset(layout.BarWidth, layout.BarHeight)
		if layout.BarCentered then
			bar.AnchorPoint = Vector2.new(0.5, 0)
			bar.Position = UDim2.new(0.5, 0, 0, layout.BarTop)
		else
			bar.AnchorPoint = Vector2.zero
			bar.Position = UDim2.fromOffset(164, layout.BarTop)
		end
		gravityValue.TextSize = layout.GravityTextSize
		levelValue.TextSize = layout.SecondaryTextSize
		coresValue.TextSize = layout.SecondaryTextSize
		zoneLabel.Visible = layout.ZoneVisible
		if compact then
			tutorialLabel.Size = UDim2.fromOffset(layout.TutorialWidth, if layout.Mode == "console" then 44 else 30)
			tutorialLabel.Position = UDim2.new(0.5, -layout.TutorialWidth / 2, 0, layout.TutorialTop)
		else
			local tutorialWidth = math.min(430, layout.TutorialWidth)
			tutorialLabel.Size = UDim2.fromOffset(tutorialWidth, 32)
			tutorialLabel.Position = UDim2.new(0.55, -tutorialWidth / 2, 1, -112)
		end
		tutorialLabel.TextSize = layout.TutorialTextSize
		dailyLabel.Size = UDim2.fromOffset(layout.DailyWidth, layout.DailyHeight)
		dailyLabel.Position = UDim2.new(0, if layout.Mode == "console" then 32 else 14, 1, -(layout.DailyHeight + 14))
		dailyLabel.TextSize = layout.DailyTextSize
		collapseButton.Size = UDim2.fromOffset(layout.CollapseWidth, layout.CollapseHeight)
		if compact then
			collapseButton.AnchorPoint = Vector2.new(1, 1)
			collapseButton.Position = UDim2.new(1, -layout.CollapseInset, 1, -layout.CollapseInset)
		else
			collapseButton.AnchorPoint = Vector2.new(0.5, 1)
			collapseButton.Position = UDim2.new(0.55, 0, 1, -18)
		end
		collapseButton.TextSize = layout.CollapseTextSize
	end
	responsive()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(responsive)
	end)
end

function HudController.start()
	build()
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	stateRemote.OnClientEvent:Connect(function(newState)
		if type(newState) == "table" and newState.Ready == true then
			state = newState
			render()
		end
	end)
	task.spawn(function()
		local ok, initial = pcall(function()
			return (remotes:WaitForChild("QueryState") :: RemoteFunction):InvokeServer()
		end)
		if ok and type(initial) == "table" then
			state = initial
			render()
		end
	end)
end

return HudController
