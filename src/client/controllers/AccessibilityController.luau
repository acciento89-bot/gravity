--!strict

local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local LocalizationRules = require(shared.rules.LocalizationRules)
local AccessibilityState = require(script.Parent.AccessibilityState)

local AccessibilityController = {}
local locale = LocalizationService.RobloxLocaleId

local function tr(key: string): string
	return LocalizationRules.text(locale, key)
end

local function build()
	local screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityAccessibility"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.DisplayOrder = 21
	screen.Parent = playerGui

	local button = Instance.new("TextButton")
	button.Name = "AccessibilityButton"
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -18, 0, 302)
	button.Size = UDim2.fromOffset(136, 46)
	button.BackgroundColor3 = Color3.fromRGB(18, 25, 35)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBlack
	button.Text = tr("access")
	button.TextSize = 13
	button.TextColor3 = Color3.fromRGB(246, 249, 252)
	button.Selectable = true
	button.Parent = screen
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 14)
	bc.Parent = button

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.52)
	panel.Size = UDim2.fromOffset(520, 250)
	panel.BackgroundColor3 = Color3.fromRGB(18, 25, 35)
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screen
	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(0, 22)
	pc.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 44)
	title.Position = UDim2.fromOffset(20, 16)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.Text = tr("access_title")
	title.TextSize = 22
	title.TextColor3 = Color3.fromRGB(246, 249, 252)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = panel

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, -40, 0, 72)
	toggle.Position = UDim2.fromOffset(20, 76)
	toggle.BackgroundColor3 = Color3.fromRGB(31, 42, 55)
	toggle.BorderSizePixel = 0
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 15
	toggle.TextColor3 = Color3.fromRGB(246, 249, 252)
	toggle.Selectable = true
	toggle.Parent = panel
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 14)
	tc.Parent = toggle

	local note = Instance.new("TextLabel")
	note.Size = UDim2.new(1, -40, 0, 66)
	note.Position = UDim2.fromOffset(20, 164)
	note.BackgroundTransparency = 1
	note.Font = Enum.Font.GothamMedium
	note.Text = tr("access_note")
	note.TextSize = 12
	note.TextColor3 = Color3.fromRGB(161, 177, 194)
	note.TextWrapped = true
	note.TextXAlignment = Enum.TextXAlignment.Center
	note.Parent = panel

	local function renderToggle()
		local enabled = AccessibilityState.isReducedMotion()
		toggle.Text = tr("reduced_motion") .. "\n" .. tr(if enabled then "reduced_on" else "reduced_off")
		toggle.BackgroundColor3 = if enabled then Color3.fromRGB(54, 82, 76) else Color3.fromRGB(31, 42, 55)
	end
	renderToggle()
	toggle.Activated:Connect(function()
		AccessibilityState.toggleReducedMotion()
		renderToggle()
	end)
	button.Activated:Connect(function()
		panel.Visible = not panel.Visible
	end)
end

function AccessibilityController.start()
	build()
end

return AccessibilityController
