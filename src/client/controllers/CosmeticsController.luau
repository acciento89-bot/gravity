--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local ViewportRules = require(shared.rules.ViewportRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local CosmeticsController = {}

local COLORS = {
	Foundation = Color3.fromRGB(18, 25, 35),
	Surface = Color3.fromRGB(31, 42, 55),
	Surface2 = Color3.fromRGB(40, 53, 68),
	Text = Color3.fromRGB(246, 249, 252),
	Muted = Color3.fromRGB(161, 177, 194),
	Cyan = Color3.fromRGB(91, 220, 239),
	Violet = Color3.fromRGB(164, 134, 255),
	Gold = Color3.fromRGB(255, 211, 96),
	Green = Color3.fromRGB(105, 224, 154),
	Danger = Color3.fromRGB(255, 111, 111),
}

local state: any = nil
local selectedCategory = "Orbit"
local selectedName = "Default"
local menuOpen = false

local screen: ScreenGui
local openButton: TextButton
local panel: Frame
local shardsLabel: TextLabel
local titleLabel: TextLabel
local orbitTab: TextButton
local coreTab: TextButton
local listFrame: ScrollingFrame
local previewRing: Frame
local previewCore: Frame
local previewName: TextLabel
local previewStatus: TextLabel
local actionButton: TextButton
local feedbackLabel: TextLabel

local function colorFor(definition: any): Color3
	local rgb = definition.Color
	return Color3.fromRGB(rgb[1], rgb[2], rgb[3])
end

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

local function textLabel(parent: Instance, text: string, textSize: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamMedium
	label.Text = text
	label.TextSize = textSize
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local function categoryConfig(): any
	return if selectedCategory == "Orbit" then CosmeticConfig.OrbitSkins else CosmeticConfig.SingularitySkins
end

local function ownedMap(): any
	if not state then
		return {}
	end
	return if selectedCategory == "Orbit" then state.OrbitSkins or {} else state.SingularitySkins or {}
end

local function equippedName(): string
	if not state then
		return "Default"
	end
	return if selectedCategory == "Orbit"
		then state.EquippedOrbitSkin or "Default"
		else state.EquippedSingularitySkin or "Default"
end

local function showFeedback(text: string, color: Color3?)
	feedbackLabel.Text = text
	feedbackLabel.TextColor3 = color or COLORS.Text
	feedbackLabel.Visible = true
	task.delay(2.2, function()
		if feedbackLabel.Text == text then
			feedbackLabel.Visible = false
		end
	end)
end

local function updatePreview()
	local definition = categoryConfig()[selectedName]
	if not definition then
		return
	end
	local color = colorFor(definition)
	previewRing.Visible = selectedCategory == "Orbit"
	previewCore.Visible = selectedCategory == "Singularity"
	local ringStroke = previewRing:FindFirstChildOfClass("UIStroke")
	if ringStroke then
		ringStroke.Color = color
	end
	previewCore.BackgroundColor3 = color
	previewName.Text = definition.DisplayName

	local owned = ownedMap()[selectedName] == true
	local equipped = equippedName() == selectedName
	local price = tonumber(definition.Price) or 0
	local shards = if state then tonumber(state.Shards) or 0 else 0
	if equipped then
		previewStatus.Text = "EQUIPPED"
		previewStatus.TextColor3 = COLORS.Green
		actionButton.Text = "EQUIPPED"
		actionButton.BackgroundColor3 = COLORS.Surface2
		actionButton.Active = false
	elseif owned then
		previewStatus.Text = "OWNED"
		previewStatus.TextColor3 = COLORS.Cyan
		actionButton.Text = "EQUIP"
		actionButton.BackgroundColor3 = COLORS.Violet
		actionButton.Active = true
	elseif shards >= price then
		previewStatus.Text = ("%d SHARDS"):format(price)
		previewStatus.TextColor3 = COLORS.Gold
		actionButton.Text = ("BUY · %d ◆"):format(price)
		actionButton.BackgroundColor3 = COLORS.Cyan
		actionButton.Active = true
	else
		local missing = math.max(0, price - shards)
		previewStatus.Text = ("%d SHARDS · NEED %d"):format(price, missing)
		previewStatus.TextColor3 = COLORS.Danger
		actionButton.Text = ("NEED %d MORE ◆"):format(missing)
		actionButton.BackgroundColor3 = COLORS.Surface2
		actionButton.Active = true
	end
	shardsLabel.Text = ("◆ %d SHARDS"):format(shards)
end

local function clearCards()
	for _, child in listFrame:GetChildren() do
		if child:IsA("GuiButton") then
			child:Destroy()
		end
	end
end

local function rebuildCards()
	clearCards()
	local definitions = categoryConfig()
	local ordered = {}
	for name, definition in definitions do
		table.insert(ordered, { Name = name, Definition = definition })
	end
	table.sort(ordered, function(a, b)
		local ap = tonumber(a.Definition.Price) or 0
		local bp = tonumber(b.Definition.Price) or 0
		if ap == bp then
			return a.Name < b.Name
		end
		return ap < bp
	end)

	local previous: TextButton? = nil
	local first: TextButton? = nil
	for index, item in ordered do
		local definition = item.Definition
		local card = Instance.new("TextButton")
		card.Name = "Skin_" .. item.Name
		card.Size = UDim2.new(1, -8, 0, 64)
		card.Position = UDim2.fromOffset(4, (index - 1) * 70)
		card.BackgroundColor3 = if item.Name == selectedName then COLORS.Surface2 else COLORS.Surface
		card.BorderSizePixel = 0
		card.Text = ""
		card.AutoButtonColor = true
		card.Selectable = true
		card.Parent = listFrame
		corner(card, 12)
		if item.Name == selectedName then
			stroke(card, COLORS.Cyan, 0.12, 2)
		end

		local swatch = Instance.new("Frame")
		swatch.Size = UDim2.fromOffset(36, 36)
		swatch.Position = UDim2.fromOffset(14, 14)
		swatch.BackgroundColor3 = colorFor(definition)
		swatch.BorderSizePixel = 0
		swatch.Parent = card
		corner(swatch, 18)
		stroke(swatch, COLORS.Text, 0.6)

		local nameLabel = textLabel(card, definition.DisplayName, 14, COLORS.Text)
		nameLabel.Size = UDim2.new(1, -150, 0, 24)
		nameLabel.Position = UDim2.fromOffset(62, 9)
		nameLabel.Font = Enum.Font.GothamBold

		local owned = ownedMap()[item.Name] == true
		local equipped = equippedName() == item.Name
		local status = if equipped then "EQUIPPED" elseif owned then "OWNED" else (("◆ %d"):format(definition.Price))
		local statusLabel =
			textLabel(card, status, 11, if equipped then COLORS.Green else if owned then COLORS.Cyan else COLORS.Gold)
		statusLabel.Size = UDim2.new(1, -150, 0, 20)
		statusLabel.Position = UDim2.fromOffset(62, 33)

		card.Activated:Connect(function()
			selectedName = item.Name
			rebuildCards()
			updatePreview()
		end)
		if previous then
			previous.NextSelectionDown = card
			card.NextSelectionUp = previous
		end
		previous = card
		first = first or card
	end
	listFrame.CanvasSize = UDim2.fromOffset(0, #ordered * 70)
	if first then
		first.NextSelectionUp = orbitTab
		if menuOpen and GuiService.SelectedObject == nil and UserInputService.GamepadEnabled then
			GuiService.SelectedObject = first
		end
	end
end

local function setCategory(category: string)
	selectedCategory = category
	selectedName = "Default"
	orbitTab.BackgroundColor3 = if category == "Orbit" then COLORS.Cyan else COLORS.Surface2
	coreTab.BackgroundColor3 = if category == "Singularity" then COLORS.Violet else COLORS.Surface2
	rebuildCards()
	updatePreview()
end

local function setOpen(value: boolean)
	menuOpen = value
	panel.Visible = value
	openButton.Text = if value then "CLOSE STYLE" else "STYLE"
	if value then
		setCategory(selectedCategory)
		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = orbitTab
		end
	else
		GuiService.SelectedObject = openButton
	end
end

local function responsive()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local mode =
		ViewportRules.classify(viewport.X, viewport.Y, UserInputService.TouchEnabled, GuiService:IsTenFootInterface())
	local width = if mode == "phone"
		then math.min(620, viewport.X - 28)
		else if mode == "tablet" then 680 else if mode == "console" then 860 else 760
	local height = if mode == "phone" then math.min(500, viewport.Y - 34) else if mode == "console" then 620 else 560
	panel.Size = UDim2.fromOffset(width, height)
	openButton.Size = UDim2.fromOffset(if mode == "console" then 190 else 136, if mode == "console" then 62 else 46)
	openButton.TextSize = if mode == "console" then 20 else 14
end

local function build()
	screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityCosmetics"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 20
	screen.Parent = playerGui

	openButton = Instance.new("TextButton")
	openButton.Name = "StyleButton"
	openButton.AnchorPoint = Vector2.new(1, 0)
	openButton.Position = UDim2.new(1, -18, 0, 86)
	openButton.Size = UDim2.fromOffset(136, 46)
	openButton.BackgroundColor3 = COLORS.Foundation
	openButton.BorderSizePixel = 0
	openButton.Font = Enum.Font.GothamBlack
	openButton.Text = "STYLE"
	openButton.TextSize = 14
	openButton.TextColor3 = COLORS.Text
	openButton.Selectable = true
	openButton.Parent = screen
	corner(openButton, 14)
	stroke(openButton, COLORS.Cyan, 0.35)

	panel = Instance.new("Frame")
	panel.Name = "CosmeticsPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromOffset(760, 560)
	panel.BackgroundColor3 = COLORS.Foundation
	panel.BackgroundTransparency = 0.02
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screen
	corner(panel, 22)
	stroke(panel, COLORS.Cyan, 0.5, 2)

	titleLabel = textLabel(panel, "GRAVITY STYLE", 24, COLORS.Text)
	titleLabel.Size = UDim2.new(0.55, 0, 0, 46)
	titleLabel.Position = UDim2.fromOffset(24, 16)
	titleLabel.Font = Enum.Font.GothamBlack

	shardsLabel = textLabel(panel, "◆ 0 SHARDS", 15, COLORS.Gold)
	shardsLabel.AnchorPoint = Vector2.new(1, 0)
	shardsLabel.Size = UDim2.fromOffset(180, 38)
	shardsLabel.Position = UDim2.new(1, -24, 0, 20)
	shardsLabel.TextXAlignment = Enum.TextXAlignment.Right
	shardsLabel.Font = Enum.Font.GothamBold

	orbitTab = Instance.new("TextButton")
	orbitTab.Name = "OrbitTab"
	orbitTab.Size = UDim2.fromOffset(150, 42)
	orbitTab.Position = UDim2.fromOffset(24, 72)
	orbitTab.BackgroundColor3 = COLORS.Cyan
	orbitTab.BorderSizePixel = 0
	orbitTab.Font = Enum.Font.GothamBold
	orbitTab.Text = "ORBIT"
	orbitTab.TextSize = 14
	orbitTab.TextColor3 = COLORS.Foundation
	orbitTab.Selectable = true
	orbitTab.Parent = panel
	corner(orbitTab, 12)

	coreTab = orbitTab:Clone()
	coreTab.Name = "CoreTab"
	coreTab.Position = UDim2.fromOffset(184, 72)
	coreTab.BackgroundColor3 = COLORS.Surface2
	coreTab.Text = "CORE"
	coreTab.TextColor3 = COLORS.Text
	coreTab.Parent = panel

	listFrame = Instance.new("ScrollingFrame")
	listFrame.Name = "SkinList"
	listFrame.Position = UDim2.fromOffset(24, 128)
	listFrame.Size = UDim2.new(0.52, -30, 1, -152)
	listFrame.BackgroundColor3 = COLORS.Surface
	listFrame.BackgroundTransparency = 0.35
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 6
	listFrame.ScrollBarImageColor3 = COLORS.Cyan
	listFrame.CanvasSize = UDim2.fromOffset(0, 0)
	listFrame.Parent = panel
	corner(listFrame, 14)

	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.AnchorPoint = Vector2.new(1, 0)
	preview.Position = UDim2.new(1, -24, 0, 128)
	preview.Size = UDim2.new(0.45, -10, 1, -152)
	preview.BackgroundColor3 = COLORS.Surface
	preview.BorderSizePixel = 0
	preview.Parent = panel
	corner(preview, 16)
	stroke(preview, COLORS.Violet, 0.65)

	previewRing = Instance.new("Frame")
	previewRing.Name = "OrbitPreview"
	previewRing.AnchorPoint = Vector2.new(0.5, 0)
	previewRing.Position = UDim2.new(0.5, 0, 0, 32)
	previewRing.Size = UDim2.fromOffset(132, 132)
	previewRing.BackgroundTransparency = 1
	previewRing.Parent = preview
	corner(previewRing, 66)
	stroke(previewRing, COLORS.Cyan, 0.05, 10)

	local orbitCenter = Instance.new("Frame")
	orbitCenter.AnchorPoint = Vector2.new(0.5, 0.5)
	orbitCenter.Position = UDim2.fromScale(0.5, 0.5)
	orbitCenter.Size = UDim2.fromOffset(40, 40)
	orbitCenter.BackgroundColor3 = COLORS.Foundation
	orbitCenter.BorderSizePixel = 0
	orbitCenter.Parent = previewRing
	corner(orbitCenter, 20)
	stroke(orbitCenter, COLORS.Text, 0.55)

	previewCore = Instance.new("Frame")
	previewCore.Name = "CorePreview"
	previewCore.AnchorPoint = Vector2.new(0.5, 0)
	previewCore.Position = UDim2.new(0.5, 0, 0, 44)
	previewCore.Size = UDim2.fromOffset(108, 108)
	previewCore.BackgroundColor3 = COLORS.Cyan
	previewCore.BorderSizePixel = 0
	previewCore.Visible = false
	previewCore.Parent = preview
	corner(previewCore, 54)
	stroke(previewCore, COLORS.Text, 0.45, 3)

	previewName = textLabel(preview, "Gravity Blue", 19, COLORS.Text)
	previewName.AnchorPoint = Vector2.new(0.5, 0)
	previewName.Position = UDim2.new(0.5, 0, 0, 182)
	previewName.Size = UDim2.new(1, -32, 0, 34)
	previewName.TextXAlignment = Enum.TextXAlignment.Center
	previewName.Font = Enum.Font.GothamBlack

	previewStatus = textLabel(preview, "EQUIPPED", 13, COLORS.Green)
	previewStatus.AnchorPoint = Vector2.new(0.5, 0)
	previewStatus.Position = UDim2.new(0.5, 0, 0, 216)
	previewStatus.Size = UDim2.new(1, -32, 0, 28)
	previewStatus.TextXAlignment = Enum.TextXAlignment.Center
	previewStatus.Font = Enum.Font.GothamBold

	actionButton = Instance.new("TextButton")
	actionButton.Name = "CosmeticAction"
	actionButton.AnchorPoint = Vector2.new(0.5, 1)
	actionButton.Position = UDim2.new(0.5, 0, 1, -24)
	actionButton.Size = UDim2.new(1, -42, 0, 58)
	actionButton.BackgroundColor3 = COLORS.Surface2
	actionButton.BorderSizePixel = 0
	actionButton.Font = Enum.Font.GothamBlack
	actionButton.Text = "EQUIPPED"
	actionButton.TextSize = 16
	actionButton.TextColor3 = COLORS.Text
	actionButton.Selectable = true
	actionButton.Parent = preview
	corner(actionButton, 14)

	feedbackLabel = textLabel(preview, "", 12, COLORS.Text)
	feedbackLabel.AnchorPoint = Vector2.new(0.5, 1)
	feedbackLabel.Position = UDim2.new(0.5, 0, 1, -88)
	feedbackLabel.Size = UDim2.new(1, -30, 0, 42)
	feedbackLabel.TextXAlignment = Enum.TextXAlignment.Center
	feedbackLabel.TextWrapped = true
	feedbackLabel.Visible = false

	openButton.Activated:Connect(function()
		setOpen(not menuOpen)
	end)
	orbitTab.Activated:Connect(function()
		setCategory("Orbit")
	end)
	coreTab.Activated:Connect(function()
		setCategory("Singularity")
	end)
	actionButton.Activated:Connect(function()
		local definition = categoryConfig()[selectedName]
		if not state or not definition then
			return
		end
		local owned = ownedMap()[selectedName] == true
		local equipped = equippedName() == selectedName
		if equipped then
			return
		end
		if owned then
			(remotes:WaitForChild("CosmeticAction") :: RemoteEvent):FireServer("Equip", selectedCategory, selectedName)
			showFeedback("Equipping " .. definition.DisplayName .. "…", COLORS.Cyan)
			return
		end
		local price = tonumber(definition.Price) or 0
		local shards = tonumber(state.Shards) or 0
		if shards < price then
			showFeedback(("Need %d more Shards"):format(price - shards), COLORS.Danger)
			return
		end
		(remotes:WaitForChild("CosmeticAction") :: RemoteEvent):FireServer("Buy", selectedCategory, selectedName)
		showFeedback("Purchased · equipping…", COLORS.Green)
	end)

	orbitTab.NextSelectionRight = coreTab
	coreTab.NextSelectionLeft = orbitTab
	orbitTab.NextSelectionDown = actionButton
	coreTab.NextSelectionDown = actionButton
	actionButton.NextSelectionUp = orbitTab

	responsive()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive)
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		task.defer(responsive)
	end)
end

function CosmeticsController.start()
	build()
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	stateRemote.OnClientEvent:Connect(function(newState)
		if type(newState) == "table" and newState.Ready == true then
			state = newState
			if menuOpen then
				rebuildCards()
				updatePreview()
			end
		end
	end)
	task.spawn(function()
		local ok, initial = pcall(function()
			return (remotes:WaitForChild("QueryState") :: RemoteFunction):InvokeServer()
		end)
		if ok and type(initial) == "table" then
			state = initial
		end
	end)
end

return CosmeticsController
