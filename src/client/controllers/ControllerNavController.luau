--!strict

local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ControllerNavController = {}

local ROOT_BUTTONS = { "StyleButton", "DailyButton", "LeaderboardButton", "ShopButton", "AccessibilityButton" }

local function findButton(name: string): GuiButton?
	local item = playerGui:FindFirstChild(name, true)
	return if item and item:IsA("GuiButton") then item else nil
end

local function wire()
	local buttons: { GuiButton } = {}
	for _, name in ROOT_BUTTONS do
		local button = findButton(name)
		if button then
			table.insert(buttons, button)
		end
	end
	for index, button in buttons do
		button.Selectable = true
		button.NextSelectionUp = buttons[index - 1] or buttons[#buttons]
		button.NextSelectionDown = buttons[index + 1] or buttons[1]
	end
	if UserInputService.GamepadEnabled and #buttons > 0 and GuiService.SelectedObject == nil then
		GuiService.SelectedObject = buttons[1]
	end
end

function ControllerNavController.start()
	task.defer(wire)
	playerGui.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("GuiButton") then
			task.defer(wire)
		end
	end)
end

return ControllerNavController
