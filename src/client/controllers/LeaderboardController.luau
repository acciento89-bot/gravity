--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local ViewportRules = require(shared.rules.ViewportRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local LeaderboardController = {}

local COLORS = {
	Foundation = Color3.fromRGB(18, 25, 35),
	Surface = Color3.fromRGB(31, 42, 55),
	Text = Color3.fromRGB(246, 249, 252),
	Muted = Color3.fromRGB(161, 177, 194),
	Cyan = Color3.fromRGB(91, 220, 239),
	Violet = Color3.fromRGB(164, 134, 255),
	Gold = Color3.fromRGB(255, 211, 96),
}

local screen: ScreenGui
local openButton: TextButton
local panel: Frame
local title: TextLabel
local statusLabel: TextLabel
local rows: Frame
local gravityTab: TextButton
local coresTab: TextButton
local fastestTab: TextButton
local currentKey = "HighestGravity"
local cached: any = nil
local lastQueryAt = -math.huge

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

local function compact(value: number): string
	if currentKey == "FastestCollapse" then
		local seconds = math.max(0, math.floor(value))
		return ("%d:%02d"):format(math.floor(seconds / 60), seconds % 60)
	end
	if value >= 1e9 then
		return ("%.1fB"):format(value / 1e9)
	elseif value >= 1e6 then
		return ("%.1fM"):format(value / 1e6)
	elseif value >= 1e3 then
		return ("%.1fK"):format(value / 1e3)
	end
	return tostring(math.floor(value + 0.5))
end

local function clearRows()
	for _, child in rows:GetChildren() do
		child:Destroy()
	end
end

local function renderWorldBoard(entries: { any })
	local world = Workspace:FindFirstChild("Plus1GravityWorld")
	local board = world and world:FindFirstChild("GravityLeaderboardBoard", true)
	if not board or not board:IsA("BasePart") then
		return
	end
	local gui = board:FindFirstChild("LeaderboardSurface")
	local list = gui and gui:FindFirstChild("Rows")
	if not list then
		return
	end
	for index = 1, 5 do
		local row = list:FindFirstChild("Row" .. index)
		if row and row:IsA("TextLabel") then
			local entry = entries[index]
			row.Text = if entry
				then ("#%d  %s   %s G"):format(index, tostring(entry.Name), compact(tonumber(entry.Value) or 0))
				else ("#%d  ---"):format(index)
		end
	end
end

local function render()
	clearRows()
	local entries = if cached and type(cached[currentKey]) == "table" then cached[currentKey] else {}
	if #entries == 0 then
		statusLabel.Text = if cached then "No ranked players yet." else "Loading leaderboard…"
		statusLabel.Visible = true
	else
		statusLabel.Visible = false
		for index, entry in entries do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 38)
			row.Position = UDim2.fromOffset(0, (index - 1) * 40)
			row.BackgroundColor3 = if index <= 3 then COLORS.Surface else COLORS.Foundation
			row.BackgroundTransparency = if index <= 3 then 0.15 else 0.45
			row.BorderSizePixel = 0
			row.Parent = rows
			corner(row, 10)

			local rank = label(row, ("#%d"):format(index), 14, if index <= 3 then COLORS.Gold else COLORS.Muted)
			rank.Size = UDim2.fromOffset(48, 38)
			rank.Position = UDim2.fromOffset(12, 0)
			rank.Font = Enum.Font.GothamBold

			local name = label(row, tostring(entry.Name or "Unknown"), 14, COLORS.Text)
			name.Size = UDim2.new(1, -180, 1, 0)
			name.Position = UDim2.fromOffset(64, 0)
			name.Font = Enum.Font.GothamBold

			local value = label(row, compact(tonumber(entry.Value) or 0), 14, COLORS.Cyan)
			value.AnchorPoint = Vector2.new(1, 0)
			value.Size = UDim2.fromOffset(110, 38)
			value.Position = UDim2.new(1, -12, 0, 0)
			value.TextXAlignment = Enum.TextXAlignment.Right
			value.Font = Enum.Font.GothamBlack
		end
	end
	if cached and type(cached.HighestGravity) == "table" then
		renderWorldBoard(cached.HighestGravity)
	end
end

local function selectTab(key: string)
	currentKey = key
	gravityTab.BackgroundColor3 = if key == "HighestGravity" then COLORS.Cyan else COLORS.Surface
	coresTab.BackgroundColor3 = if key == "TotalCores" then COLORS.Violet else COLORS.Surface
	fastestTab.BackgroundColor3 = if key == "FastestCollapse" then COLORS.Gold else COLORS.Surface
	title.Text = if key == "HighestGravity"
		then "TOP GRAVITY"
		else if key == "TotalCores" then "TOTAL CORES" else "FASTEST COLLAPSE · UNBOOSTED"
	render()
end

local function refresh(force: boolean?)
	if not force and os.clock() - lastQueryAt < 4 then
		render()
		return
	end
	lastQueryAt = os.clock()
	statusLabel.Text = "Loading leaderboard…"
	statusLabel.Visible = true
	task.spawn(function()
		local ok, result = pcall(function()
			return (remotes:WaitForChild("LeaderboardQuery") :: RemoteFunction):InvokeServer()
		end)
		if ok and type(result) == "table" then
			cached = result
		else
			if not cached then
				statusLabel.Text = if ok
					then "Leaderboard refresh is cooling down."
					else "Leaderboard unavailable. Try again shortly."
				statusLabel.Visible = true
				return
			end
		end
		render()
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
	panel.Size = UDim2.fromOffset(
		if mode == "phone" then math.min(610, viewport.X - 28) else if mode == "console" then 850 else 720,
		if mode == "phone" then math.min(520, viewport.Y - 30) else if mode == "console" then 620 else 560
	)
	openButton.Size = UDim2.fromOffset(if mode == "console" then 190 else 136, if mode == "console" then 62 else 46)
	openButton.TextSize = if mode == "console" then 18 else 13
end

local function build()
	screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityLeaderboards"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 17
	screen.Parent = playerGui

	openButton = Instance.new("TextButton")
	openButton.Name = "LeaderboardButton"
	openButton.AnchorPoint = Vector2.new(1, 0)
	openButton.Position = UDim2.new(1, -18, 0, 194)
	openButton.Size = UDim2.fromOffset(136, 46)
	openButton.BackgroundColor3 = COLORS.Foundation
	openButton.BorderSizePixel = 0
	openButton.Font = Enum.Font.GothamBlack
	openButton.Text = "RANKINGS"
	openButton.TextSize = 13
	openButton.TextColor3 = COLORS.Text
	openButton.Selectable = true
	openButton.Parent = screen
	corner(openButton, 14)
	stroke(openButton, COLORS.Violet, 0.35)

	panel = Instance.new("Frame")
	panel.Name = "LeaderboardPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromOffset(720, 560)
	panel.BackgroundColor3 = COLORS.Foundation
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screen
	corner(panel, 22)
	stroke(panel, COLORS.Violet, 0.48, 2)

	title = label(panel, "TOP GRAVITY", 24, COLORS.Text)
	title.Size = UDim2.new(1, -48, 0, 44)
	title.Position = UDim2.fromOffset(24, 16)
	title.Font = Enum.Font.GothamBlack

	gravityTab = Instance.new("TextButton")
	gravityTab.Name = "GravityTab"
	gravityTab.Size = UDim2.fromOffset(180, 42)
	gravityTab.Position = UDim2.fromOffset(24, 70)
	gravityTab.BackgroundColor3 = COLORS.Cyan
	gravityTab.BorderSizePixel = 0
	gravityTab.Font = Enum.Font.GothamBold
	gravityTab.Text = "GRAVITY"
	gravityTab.TextSize = 14
	gravityTab.TextColor3 = COLORS.Foundation
	gravityTab.Selectable = true
	gravityTab.Parent = panel
	corner(gravityTab, 12)

	coresTab = gravityTab:Clone()
	coresTab.Name = "CoresTab"
	coresTab.Position = UDim2.fromOffset(214, 70)
	coresTab.BackgroundColor3 = COLORS.Surface
	coresTab.Text = "CORES"
	coresTab.TextColor3 = COLORS.Text
	coresTab.Parent = panel

	fastestTab = gravityTab:Clone()
	fastestTab.Name = "FastestTab"
	fastestTab.Position = UDim2.fromOffset(404, 70)
	fastestTab.BackgroundColor3 = COLORS.Surface
	fastestTab.Text = "FASTEST"
	fastestTab.TextColor3 = COLORS.Text
	fastestTab.Parent = panel

	rows = Instance.new("Frame")
	rows.Name = "Rows"
	rows.Position = UDim2.fromOffset(24, 128)
	rows.Size = UDim2.new(1, -48, 1, -152)
	rows.BackgroundTransparency = 1
	rows.Parent = panel

	statusLabel = label(rows, "Loading leaderboard…", 15, COLORS.Muted)
	statusLabel.Size = UDim2.fromScale(1, 1)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Center
	statusLabel.TextWrapped = true

	openButton.Activated:Connect(function()
		panel.Visible = not panel.Visible
		if panel.Visible then
			refresh(false)
			if UserInputService.GamepadEnabled then
				GuiService.SelectedObject = gravityTab
			end
		else
			GuiService.SelectedObject = openButton
		end
	end)
	gravityTab.Activated:Connect(function()
		selectTab("HighestGravity")
	end)
	coresTab.Activated:Connect(function()
		selectTab("TotalCores")
	end)
	fastestTab.Activated:Connect(function()
		selectTab("FastestCollapse")
	end)
	gravityTab.NextSelectionRight = coresTab
	coresTab.NextSelectionLeft = gravityTab
	coresTab.NextSelectionRight = fastestTab
	fastestTab.NextSelectionLeft = coresTab

	responsive()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(responsive)
	end)

	task.delay(3, function()
		refresh(true)
	end)
end

function LeaderboardController.start()
	build()
end

return LeaderboardController
