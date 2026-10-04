--!strict

local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local MonetizationConfig = require(shared.config.MonetizationConfig)
local ViewportRules = require(shared.rules.ViewportRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local ShopController = {}

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
local screen: ScreenGui
local openButton: TextButton
local panel: Frame
local feedback: TextLabel
local gravityTimer: TextLabel
local xpTimer: TextLabel
local productButtons: { [number]: TextButton } = {}
local menuOpen = false

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

local function formatTimer(untilTimestamp: number): string
	local remaining = math.max(0, math.floor(untilTimestamp - os.time()))
	if remaining <= 0 then
		return "INACTIVE"
	end
	return ("%02d:%02d"):format(math.floor(remaining / 60), remaining % 60)
end

local function showFeedback(text: string, color: Color3?)
	feedback.Text = text
	feedback.TextColor3 = color or COLORS.Text
	feedback.Visible = true
	task.delay(3, function()
		if feedback.Text == text then
			feedback.Visible = false
		end
	end)
end

local function productLive(product: any): boolean
	return type(product.ProductId) == "number" and product.ProductId > 0
end

local function updateTimers()
	if not state then
		gravityTimer.Text = "2× GRAVITY · INACTIVE"
		xpTimer.Text = "2× XP · INACTIVE"
		return
	end
	gravityTimer.Text = "2× GRAVITY · " .. formatTimer(tonumber(state.GravityBoostUntil) or 0)
	xpTimer.Text = "2× XP · " .. formatTimer(tonumber(state.XpBoostUntil) or 0)
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
		if mode == "phone" then math.min(620, viewport.X - 28) else if mode == "console" then 900 else 760,
		if mode == "phone" then math.min(510, viewport.Y - 30) else if mode == "console" then 620 else 560
	)
	openButton.Size = UDim2.fromOffset(if mode == "console" then 190 else 136, if mode == "console" then 62 else 46)
	openButton.TextSize = if mode == "console" then 20 else 14
end

local function addProductCard(parent: Instance, product: any, index: number, accent: Color3): TextButton
	local card = Instance.new("TextButton")
	card.Name = "Product_" .. tostring(product.Key)
	card.Size = UDim2.new(1, -48, 0, 108)
	card.Position = UDim2.fromOffset(24, 118 + (index - 1) * 118)
	card.BackgroundColor3 = COLORS.Surface
	card.BorderSizePixel = 0
	card.Text = ""
	card.Selectable = true
	card.Parent = parent
	corner(card, 16)
	stroke(card, accent, 0.55)

	local name = label(card, product.DisplayName, 17, COLORS.Text)
	name.Position = UDim2.fromOffset(18, 12)
	name.Size = UDim2.new(1, -180, 0, 34)
	name.Font = Enum.Font.GothamBlack

	local price = label(card, ("EXPECTED · R$ %d"):format(tonumber(product.ExpectedRobux) or 0), 12, COLORS.Gold)
	price.Position = UDim2.fromOffset(18, 48)
	price.Size = UDim2.new(1, -180, 0, 24)
	price.Font = Enum.Font.GothamBold

	local live = productLive(product)
	local status = label(
		card,
		if live then "TAP TO PURCHASE" else "NOT LIVE · ID REQUIRED",
		11,
		if live then COLORS.Green else COLORS.Danger
	)
	status.Position = UDim2.fromOffset(18, 74)
	status.Size = UDim2.new(1, -180, 0, 22)
	status.Font = Enum.Font.GothamBold

	local action = Instance.new("TextLabel")
	action.AnchorPoint = Vector2.new(1, 0.5)
	action.Position = UDim2.new(1, -18, 0.5, 0)
	action.Size = UDim2.fromOffset(140, 56)
	action.BackgroundColor3 = if live then accent else COLORS.Surface2
	action.BorderSizePixel = 0
	action.Font = Enum.Font.GothamBlack
	action.Text = if live then "BUY" else "DISABLED"
	action.TextSize = 15
	action.TextColor3 = COLORS.Text
	action.Parent = card
	corner(action, 14)

	card.Activated:Connect(function()
		if not productLive(product) then
			showFeedback("This product is not live yet.", COLORS.Danger)
			return
		end
		showFeedback("Opening secure Roblox purchase…", COLORS.Cyan)
		MarketplaceService:PromptProductPurchase(player, product.ProductId)
	end)
	if live then
		productButtons[product.ProductId] = card
	end
	return card
end

local function build()
	screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityShop"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 19
	screen.Parent = playerGui

	openButton = Instance.new("TextButton")
	openButton.Name = "ShopButton"
	openButton.AnchorPoint = Vector2.new(1, 0)
	openButton.Position = UDim2.new(1, -18, 0, 248)
	openButton.Size = UDim2.fromOffset(136, 46)
	openButton.BackgroundColor3 = COLORS.Foundation
	openButton.BorderSizePixel = 0
	openButton.Font = Enum.Font.GothamBlack
	openButton.Text = "SHOP"
	openButton.TextSize = 14
	openButton.TextColor3 = COLORS.Text
	openButton.Selectable = true
	openButton.Parent = screen
	corner(openButton, 14)
	stroke(openButton, COLORS.Gold, 0.35)

	panel = Instance.new("Frame")
	panel.Name = "ShopPanel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromOffset(760, 560)
	panel.BackgroundColor3 = COLORS.Foundation
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screen
	corner(panel, 22)
	stroke(panel, COLORS.Gold, 0.48, 2)

	local heading = label(panel, "GRAVITY SHOP", 24, COLORS.Text)
	heading.Size = UDim2.new(0.5, 0, 0, 42)
	heading.Position = UDim2.fromOffset(24, 16)
	heading.Font = Enum.Font.GothamBlack

	gravityTimer = label(panel, "2× GRAVITY · INACTIVE", 12, COLORS.Cyan)
	gravityTimer.AnchorPoint = Vector2.new(1, 0)
	gravityTimer.Size = UDim2.fromOffset(230, 24)
	gravityTimer.Position = UDim2.new(1, -24, 0, 15)
	gravityTimer.TextXAlignment = Enum.TextXAlignment.Right
	gravityTimer.Font = Enum.Font.GothamBold

	xpTimer = label(panel, "2× XP · INACTIVE", 12, COLORS.Violet)
	xpTimer.AnchorPoint = Vector2.new(1, 0)
	xpTimer.Size = UDim2.fromOffset(230, 24)
	xpTimer.Position = UDim2.new(1, -24, 0, 42)
	xpTimer.TextXAlignment = Enum.TextXAlignment.Right
	xpTimer.Font = Enum.Font.GothamBold

	feedback = label(panel, "", 12, COLORS.Text)
	feedback.Position = UDim2.fromOffset(24, 78)
	feedback.Size = UDim2.new(1, -48, 0, 28)
	feedback.TextXAlignment = Enum.TextXAlignment.Center
	feedback.Font = Enum.Font.GothamBold
	feedback.Visible = false

	local products = {
		{ Product = MonetizationConfig.Products.GravityBoost, Accent = COLORS.Cyan },
		{ Product = MonetizationConfig.Products.XpBoost, Accent = COLORS.Violet },
		{ Product = MonetizationConfig.Products.ShardPack, Accent = COLORS.Gold },
	}
	local previous: TextButton? = nil
	local first: TextButton? = nil
	for index, item in products do
		local card = addProductCard(panel, item.Product, index, item.Accent)
		if previous then
			previous.NextSelectionDown = card
			card.NextSelectionUp = previous
		end
		previous = card
		first = first or card
	end

	local foot = label(panel, "Purchases are optional. Competitive height is never sold directly.", 11, COLORS.Muted)
	foot.AnchorPoint = Vector2.new(0.5, 1)
	foot.Position = UDim2.new(0.5, 0, 1, -16)
	foot.Size = UDim2.new(1, -48, 0, 30)
	foot.TextXAlignment = Enum.TextXAlignment.Center
	foot.TextWrapped = true

	openButton.Activated:Connect(function()
		menuOpen = not menuOpen
		panel.Visible = menuOpen
		openButton.Text = if menuOpen then "CLOSE SHOP" else "SHOP"
		if menuOpen and UserInputService.GamepadEnabled and first then
			GuiService.SelectedObject = first
		elseif not menuOpen then
			GuiService.SelectedObject = openButton
		end
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

function ShopController.start()
	build()
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	stateRemote.OnClientEvent:Connect(function(newState)
		if type(newState) == "table" and newState.Ready == true then
			state = newState
			updateTimers()
			if newState.Event == "PurchaseGranted" then
				showFeedback("Purchase granted and saved.", COLORS.Green)
			end
		end
	end)
	task.spawn(function()
		local ok, initial = pcall(function()
			return (remotes:WaitForChild("QueryState") :: RemoteFunction):InvokeServer()
		end)
		if ok and type(initial) == "table" then
			state = initial
			updateTimers()
		end
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(
		function(userId: number, productId: number, purchased: boolean)
			if userId ~= player.UserId or not productButtons[productId] then
				return
			end
			if purchased then
				showFeedback("Purchase submitted · waiting for receipt…", COLORS.Cyan)
			else
				showFeedback("Purchase cancelled · nothing charged.", COLORS.Muted)
			end
		end
	)

	task.spawn(function()
		while screen.Parent do
			task.wait(1)
			updateTimers()
		end
	end)
end

return ShopController
