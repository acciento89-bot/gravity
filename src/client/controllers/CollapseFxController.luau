--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local CollapseFxController = {}
local AccessibilityState = require(script.Parent.AccessibilityState)

local sequence = 0

local function colorFrom(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function milestoneColor(cores: number, base: Color3): Color3
	if cores > 0 and cores % 10 == 0 then
		return Color3.fromRGB(255, 219, 112)
	elseif cores > 0 and cores % 5 == 0 then
		return Color3.fromRGB(189, 140, 255)
	elseif cores > 0 and cores % 3 == 0 then
		return base:Lerp(Color3.fromRGB(255, 154, 104), 0.35)
	end
	return base
end

local function effectColor(payload: any): Color3
	local skinId = if type(payload) == "table" and type(payload.Skin) == "string" then payload.Skin else "Default"
	local definition = CosmeticConfig.SingularitySkins[skinId] or CosmeticConfig.SingularitySkins.Default
	local cores = if type(payload) == "table" then tonumber(payload.Cores) or 0 else 0
	return milestoneColor(math.max(0, math.floor(cores)), colorFrom(definition.Color))
end

local function makeScreenFx(color: Color3): (ScreenGui, Frame, TextLabel)
	local old = playerGui:FindFirstChild("Plus1GravityCollapseOverlay")
	if old then
		old:Destroy()
	end

	local screen = Instance.new("ScreenGui")
	screen.Name = "Plus1GravityCollapseOverlay"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 80
	screen.Parent = playerGui

	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 1
	flash.BorderSizePixel = 0
	flash.Parent = screen

	local reward = Instance.new("TextLabel")
	reward.Name = "CoreReward"
	reward.AnchorPoint = Vector2.new(0.5, 0.5)
	reward.Position = UDim2.fromScale(0.5, 0.50)
	reward.Size = UDim2.fromOffset(220, 58)
	reward.BackgroundColor3 = Color3.fromRGB(18, 25, 35)
	reward.BackgroundTransparency = 0.08
	reward.BorderSizePixel = 0
	reward.Font = Enum.Font.GothamBlack
	reward.Text = "◉  +1 CORE"
	reward.TextColor3 = color
	reward.TextSize = 22
	reward.TextTransparency = 1
	reward.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = reward
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Transparency = 0.25
	stroke.Parent = reward

	return screen, flash, reward
end

local function makeSingularity(color: Color3): (Model?, BasePart?, PointLight?)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return nil, nil, nil
	end

	local model = Instance.new("Model")
	model.Name = "Plus1GravitySingularityLocal"
	model.Parent = Workspace

	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Size = Vector3.new(0.35, 0.35, 0.35)
	core.CFrame = CFrame.new(root.Position + Vector3.new(0, 2.2, 0))
	core.Color = color
	core.Material = Enum.Material.Neon
	core.Transparency = 0.04
	core.Anchored = true
	core.CanCollide = false
	core.CanTouch = false
	core.CanQuery = false
	core.CastShadow = false
	core.Parent = model
	model.PrimaryPart = core

	local shell = Instance.new("Part")
	shell.Name = "Shell"
	shell.Shape = Enum.PartType.Ball
	shell.Size = Vector3.new(0.70, 0.70, 0.70)
	shell.CFrame = core.CFrame
	shell.Color = color:Lerp(Color3.new(1, 1, 1), 0.28)
	shell.Material = Enum.Material.ForceField
	shell.Transparency = 0.45
	shell.Anchored = true
	shell.CanCollide = false
	shell.CanTouch = false
	shell.CanQuery = false
	shell.CastShadow = false
	shell.Parent = model

	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 0
	light.Range = 20
	light.Shadows = false
	light.Parent = core

	return model, core, light
end

local function runSequence(payload: any, sequenceId: number, effect: ColorCorrectionEffect, blur: BlurEffect)
	local color = effectColor(payload)
	local screen, flash, reward = makeScreenFx(color)
	local singularity, core, light = makeSingularity(color)
	local camera = Workspace.CurrentCamera
	local originalFov = if camera then camera.FieldOfView else 70
	local reducedMotion = AccessibilityState.isReducedMotion()

	effect.TintColor = color:Lerp(Color3.new(1, 1, 1), 0.36)
	effect.Enabled = true
	effect.Brightness = 0
	effect.Contrast = 0
	effect.Saturation = 0
	blur.Enabled = true
	blur.Size = 0

	if core and light then
		TweenService:Create(core, TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = if reducedMotion then Vector3.new(1.8, 1.8, 1.8) else Vector3.new(3.4, 3.4, 3.4),
			Transparency = 0.12,
		}):Play()
		TweenService:Create(light, TweenInfo.new(0.34), { Brightness = 6, Range = 32 }):Play()
	end
	TweenService:Create(
		effect,
		TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{ Brightness = 0.18, Contrast = 0.30, Saturation = -0.24 }
	):Play()
	TweenService:Create(blur, TweenInfo.new(0.34), { Size = if reducedMotion then 2 else 10 }):Play()
	if camera and not reducedMotion then
		TweenService:Create(camera, TweenInfo.new(0.34, Enum.EasingStyle.Quart), { FieldOfView = originalFov + 7 })
			:Play()
	end

	task.wait(0.34)
	if sequenceId ~= sequence then
		screen:Destroy()
		if singularity then
			singularity:Destroy()
		end
		return
	end

	TweenService:Create(flash, TweenInfo.new(0.10), { BackgroundTransparency = if reducedMotion then 0.72 else 0.30 })
		:Play()
	TweenService:Create(reward, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.44),
	}):Play()
	if core then
		TweenService:Create(
			core,
			TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Size = Vector3.new(0.18, 0.18, 0.18), Transparency = 1 }
		):Play()
	end
	if light then
		TweenService:Create(light, TweenInfo.new(0.20), { Brightness = 0, Range = 4 }):Play()
	end

	task.wait(0.18)
	TweenService:Create(flash, TweenInfo.new(0.34), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(reward, TweenInfo.new(0.52, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		Position = UDim2.fromScale(0.72, 0.065),
		Size = UDim2.fromOffset(126, 34),
		TextSize = 14,
		BackgroundTransparency = 0.45,
	}):Play()
	TweenService:Create(
		effect,
		TweenInfo.new(0.48, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{ Brightness = 0, Contrast = 0, Saturation = 0 }
	):Play()
	TweenService:Create(blur, TweenInfo.new(0.48), { Size = 0 }):Play()
	if camera then
		TweenService:Create(camera, TweenInfo.new(0.48, Enum.EasingStyle.Quart), { FieldOfView = originalFov }):Play()
	end

	task.wait(0.52)
	TweenService:Create(reward, TweenInfo.new(0.14), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
	task.wait(0.14)

	if sequenceId == sequence then
		effect.Enabled = false
		blur.Enabled = false
	end
	if singularity then
		singularity:Destroy()
	end
	screen:Destroy()
end

function CollapseFxController.start()
	local oldColor = Lighting:FindFirstChild("Plus1GravityCollapseFx")
	if oldColor then
		oldColor:Destroy()
	end
	local oldBlur = Lighting:FindFirstChild("Plus1GravityCollapseBlur")
	if oldBlur then
		oldBlur:Destroy()
	end

	local effect = Instance.new("ColorCorrectionEffect")
	effect.Name = "Plus1GravityCollapseFx"
	effect.Enabled = false
	effect.Parent = Lighting

	local blur = Instance.new("BlurEffect")
	blur.Name = "Plus1GravityCollapseBlur"
	blur.Enabled = false
	blur.Size = 0
	blur.Parent = Lighting

	local collapseRemote = remotes:WaitForChild("CollapseFx") :: RemoteEvent
	collapseRemote.OnClientEvent:Connect(function(payload)
		sequence += 1
		local sequenceId = sequence
		task.spawn(runSequence, payload, sequenceId, effect, blur)
	end)
end

return CollapseFxController
