--!strict

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
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
	progressFill.Size = UDim2.fromScale(math.clamp(state.LevelProgress or 0, 0, 1), 1)
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
		if daily.Claimed then
			dailyLabel.Text = tr("daily_hud_complete", daily.Streak)
			dailyLabel.TextColor3 = COLORS.Green
		else
			dailyLabel.Text = tr("daily_hud_progress", LocaleText.dailyMission(daily), daily.Progress, daily.Target)
			dailyLabel.TextColor3 = COLORS.Muted
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

	local function responsive()
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		local viewport = camera.ViewportSize
		local layout =
			ViewportRules.layout(viewport.X, viewport.Y, UserInputService.TouchEnabled, GuiService:IsTenFootInterface())
		local compact = layout.Mode == "phone"
		logo.Visible = not compact
		orbitBadge.Visible = not compact
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
		tutorialLabel.Size = UDim2.fromOffset(layout.TutorialWidth, if layout.Mode == "console" then 44 else 30)
		tutorialLabel.Position = UDim2.new(0.5, -layout.TutorialWidth / 2, 0, layout.TutorialTop)
		tutorialLabel.TextSize = layout.TutorialTextSize
		dailyLabel.Size = UDim2.fromOffset(layout.DailyWidth, layout.DailyHeight)
		dailyLabel.Position = UDim2.new(0, if layout.Mode == "console" then 32 else 14, 1, -(layout.DailyHeight + 14))
		dailyLabel.TextSize = layout.DailyTextSize
		collapseButton.Size = UDim2.fromOffset(layout.CollapseWidth, layout.CollapseHeight)
		collapseButton.Position = UDim2.new(1, -layout.CollapseInset, 1, -layout.CollapseInset)
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
