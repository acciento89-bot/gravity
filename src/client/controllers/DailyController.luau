--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local ViewportRules = require(shared.rules.ViewportRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local DailyController = {}
local LocaleText = require(script.Parent.LocaleText)
local function t(key: string, ...: any): string
	return LocaleText.t(key, ...)
end

local COLORS = {
	Foundation = Color3.fromRGB(18, 25, 35),
	Surface = Color3.fromRGB(31, 42, 55),
	Text = Color3.fromRGB(246, 249, 252),
	Muted = Color3.fromRGB(161, 177, 194),
	Cyan = Color3.fromRGB(91, 220, 239),
	Gold = Color3.fromRGB(255, 211, 96),
	Green = Color3.fromRGB(105, 224, 154),
}

local state: any = nil
local screen: ScreenGui
local openButton: TextButton
local panel: Frame
local closeButton: TextButton
local missionLabel: TextLabel
local progressLabel: TextLabel
local progressFill: Frame
local streakLabel: TextLabel
local rewardLabel: TextLabel
local celebration: Frame
local celebrationTitle: TextLabel
local celebrationReward: TextLabel

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function stroke(parent: Instance, color: Color3, transparency: number, thickness: number?)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Transparency = transparency
	s.Thickness = thickness or 1
	s.Parent = parent
end

local function label(parent: Instance, text: string, size: number, color: Color3): TextLabel
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.Font = Enum.Font.GothamMedium
	item.Text = text
	item.TextSize = size
	item.TextColor3 = color
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function render()
	if not state or not state.Daily then
		return
	end
	local daily = state.Daily
	local progress = tonumber(daily.Progress) or 0
	local target = math.max(1, tonumber(daily.Target) or 1)
	local ratio = math.clamp(progress / target, 0, 1)
	missionLabel.Text = LocaleText.dailyMission(daily)
	progressLabel.Text = if daily.Claimed then t("daily_complete") else ("%d / %d"):format(progress, target)
	progressLabel.TextColor3 = if daily.Claimed then COLORS.Green else COLORS.Text
	progressFill.Size = UDim2.fromScale(ratio, 1)
	streakLabel.Text = t("day_streak", tonumber(daily.Streak) or 1)
	rewardLabel.Text = t("today_shards", tonumber(daily.RewardShards) or 0)
	openButton.Text = if daily.Claimed then t("daily") .. " ✓" else t("daily")
end

local function celebrate(reward: number)
	celebration.Visible = true
	celebration.BackgroundTransparency = 0.12
	celebrationTitle.TextTransparency = 0
	celebrationReward.TextTransparency = 0
	celebrationReward.Text = t("shards_reward", reward)
	celebration.Position = UDim2.fromScale(0.5, 0.42)
	celebration.Size = UDim2.fromOffset(380, 148)
	TweenService:Create(celebration, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(430, 168),
	}):Play()
	task.delay(2.6, function()
		local tween = TweenService:Create(celebration, TweenInfo.new(0.35), {
			BackgroundTransparency = 1,
		})
		tween:Play()
		TweenService:Create(celebrationTitle, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
		TweenService:Create(celebrationReward, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
		tween.Completed:Once(function()
			celebration.Visible = false
		end)
	end)
end

local function responsive()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local mode =
		ViewportRules.classify(viewport.X, viewport.Y, UserInputService.TouchEnabled, GuiService:IsTenFootInterface())
	local width = if mode == "phone" then math.min(520, viewport.X - 30) else if mode == "console" then 650 else 560
	local height = if mode == "phone" then 248 else if mode == "console" then 330 else 286
	panel.Size = UDim2.fromOffset(width, height)
	openButton.Size = UDim2.fromOffset(if mode == "console" then 190 else 136, if mode == "console" then 62 else 46)
	openButton.TextSize = if mode == "console" then 20 else 14
end

local function build()
	screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityDaily"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 18
	screen.Parent = playerGui

	openButton = Instance.new("TextButton")
	openButton.Name = "DailyButton"
	openButton.AnchorPoint = Vector2.new(1, 0)
	openButton.Position = UDim2.new(1, -18, 0, 140)
	openButton.Size = UDim2.fromOffset(136, 46)
	openButton.BackgroundColor3 = COLORS.Foundation
	openButton.BorderSizePixel = 0
	openButton.Font = Enum.Font.GothamBlack
	openButton.Text = t("daily")
	openButton.TextSize = 14
	openButton.TextColor3 = COLORS.Text
	openButton.Selectable = true
	openButton.Parent = screen
	corner(openButton, 14)
	stroke(openButton, COLORS.Gold, 0.32)

	panel = Instance.new("Frame")
	panel.Name = "DailyPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromOffset(560, 286)
	panel.BackgroundColor3 = COLORS.Foundation
	panel.BackgroundTransparency = 0.02
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screen
	corner(panel, 22)
	stroke(panel, COLORS.Gold, 0.45, 2)

	local heading = label(panel, t("daily_title"), 23, COLORS.Text)
	heading.Position = UDim2.fromOffset(24, 18)
	heading.Size = UDim2.new(1, -96, 0, 38)
	heading.Font = Enum.Font.GothamBlack

	closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -16, 0, 14)
	closeButton.Size = UDim2.fromOffset(42, 38)
	closeButton.BackgroundColor3 = COLORS.Surface
	closeButton.BorderSizePixel = 0
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "×"
	closeButton.TextSize = 22
	closeButton.TextColor3 = COLORS.Text
	closeButton.Selectable = true
	closeButton.Parent = panel
	corner(closeButton, 11)
	stroke(closeButton, COLORS.Gold, 0.56)

	missionLabel = label(panel, "Daily mission", 16, COLORS.Text)
	missionLabel.Position = UDim2.fromOffset(24, 70)
	missionLabel.Size = UDim2.new(1, -48, 0, 34)
	missionLabel.Font = Enum.Font.GothamBold

	local progressTrack = Instance.new("Frame")
	progressTrack.Position = UDim2.fromOffset(24, 116)
	progressTrack.Size = UDim2.new(1, -48, 0, 22)
	progressTrack.BackgroundColor3 = COLORS.Surface
	progressTrack.BorderSizePixel = 0
	progressTrack.Parent = panel
	corner(progressTrack, 11)

	progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.fromScale(0, 1)
	progressFill.BackgroundColor3 = COLORS.Cyan
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressTrack
	corner(progressFill, 11)

	progressLabel = label(panel, "0 / 1", 13, COLORS.Text)
	progressLabel.Position = UDim2.fromOffset(24, 146)
	progressLabel.Size = UDim2.new(0.5, -24, 0, 28)
	progressLabel.Font = Enum.Font.GothamBold

	streakLabel = label(panel, "🔥 1 DAY STREAK", 14, COLORS.Gold)
	streakLabel.AnchorPoint = Vector2.new(1, 0)
	streakLabel.Position = UDim2.new(1, -24, 0, 146)
	streakLabel.Size = UDim2.new(0.5, -12, 0, 28)
	streakLabel.TextXAlignment = Enum.TextXAlignment.Right
	streakLabel.Font = Enum.Font.GothamBold

	rewardLabel = label(panel, t("today_shards", 15), 17, COLORS.Gold)
	rewardLabel.Position = UDim2.fromOffset(24, 194)
	rewardLabel.Size = UDim2.new(1, -48, 0, 42)
	rewardLabel.TextXAlignment = Enum.TextXAlignment.Center
	rewardLabel.Font = Enum.Font.GothamBlack

	local hint =
		label(panel, "Complete one mission per UTC day. Consecutive days increase the Shard reward.", 11, COLORS.Muted)
	hint.Position = UDim2.fromOffset(24, 238)
	hint.Size = UDim2.new(1, -48, 0, 32)
	hint.TextWrapped = true
	hint.TextXAlignment = Enum.TextXAlignment.Center

	celebration = Instance.new("Frame")
	celebration.Name = "DailyCompleteCelebration"
	celebration.AnchorPoint = Vector2.new(0.5, 0.5)
	celebration.Position = UDim2.fromScale(0.5, 0.5)
	celebration.Size = UDim2.fromOffset(430, 168)
	celebration.BackgroundColor3 = COLORS.Foundation
	celebration.BackgroundTransparency = 0.12
	celebration.BorderSizePixel = 0
	celebration.Visible = false
	celebration.Parent = screen
	corner(celebration, 24)
	stroke(celebration, COLORS.Gold, 0.18, 3)

	celebrationTitle = label(celebration, t("daily_complete_title"), 26, COLORS.Text)
	celebrationTitle.Position = UDim2.fromOffset(18, 30)
	celebrationTitle.Size = UDim2.new(1, -36, 0, 44)
	celebrationTitle.TextXAlignment = Enum.TextXAlignment.Center
	celebrationTitle.Font = Enum.Font.GothamBlack

	celebrationReward = label(celebration, t("shards_reward", 15), 20, COLORS.Gold)
	celebrationReward.Position = UDim2.fromOffset(18, 84)
	celebrationReward.Size = UDim2.new(1, -36, 0, 42)
	celebrationReward.TextXAlignment = Enum.TextXAlignment.Center
	celebrationReward.Font = Enum.Font.GothamBlack

	openButton.Activated:Connect(function()
		panel.Visible = not panel.Visible
		if panel.Visible and UserInputService.GamepadEnabled then
			GuiService.SelectedObject = closeButton
		elseif not panel.Visible then
			GuiService.SelectedObject = openButton
		end
	end)
	closeButton.Activated:Connect(function()
		panel.Visible = false
		GuiService.SelectedObject = openButton
	end)

	responsive()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(responsive)
	end)
end

function DailyController.start()
	build()
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	stateRemote.OnClientEvent:Connect(function(newState)
		if type(newState) == "table" and newState.Ready == true then
			state = newState
			render()
			if newState.Event == "DailyComplete" then
				local eventData = newState.EventData
				local reward = if type(eventData) == "table"
					then tonumber(eventData.RewardShards) or tonumber(newState.Daily.RewardShards) or 0
					else tonumber(newState.Daily.RewardShards) or 0
				celebrate(reward)
			end
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

return DailyController
