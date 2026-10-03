--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local CollapseFxController = {}

function CollapseFxController.start()
	local effect = Instance.new("ColorCorrectionEffect")
	effect.Name = "Plus1GravityCollapseFx"
	effect.Enabled = false
	effect.Brightness = 0
	effect.Contrast = 0
	effect.Saturation = 0
	effect.TintColor = Color3.fromRGB(180, 235, 255)
	effect.Parent = Lighting(remotes:WaitForChild("CollapseFx") :: RemoteEvent).OnClientEvent:Connect(function()
		effect.Enabled = true
		effect.Brightness = 0
		effect.Contrast = 0
		effect.Saturation = 0
		local inTween = TweenService:Create(
			effect,
			TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
			{ Brightness = 0.65, Contrast = 0.35, Saturation = -0.35 }
		)
		inTween:Play()
		inTween.Completed:Wait()
		local outTween = TweenService:Create(
			effect,
			TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Brightness = 0, Contrast = 0, Saturation = 0 }
		)
		outTween:Play()
		outTween.Completed:Wait()
		effect.Enabled = false
	end)
end

return CollapseFxController
