--!strict

local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local FeedbackRules = require(shared.rules.FeedbackRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")
local AccessibilityState = require(script.Parent.AccessibilityState)
local HapticsController = {}
local INPUT = Enum.UserInputType.Gamepad1

local function pulse(motor: Enum.VibrationMotor, amplitude: number, duration: number)
	if not UserInputService.GamepadEnabled then
		return
	end
	local supported = false
	pcall(function()
		supported = HapticService:IsMotorSupported(INPUT, motor)
	end)
	if not supported then
		return
	end
	local scale = if AccessibilityState.isReducedMotion() then 0.55 else 1
	pcall(function()
		HapticService:SetMotor(INPUT, motor, math.clamp(amplitude * scale, 0, 1))
	end)
	task.delay(duration, function()
		pcall(function()
			HapticService:SetMotor(INPUT, motor, 0)
		end)
	end)
end

function HapticsController.start()
	local orbitRemote = remotes:WaitForChild("OrbitCollect") :: RemoteEvent
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	local collapseRemote = remotes:WaitForChild("CollapseFx") :: RemoteEvent

	orbitRemote.OnClientEvent:Connect(function(payload)
		local band =
			FeedbackRules.collectBand(if type(payload) == "table" then tonumber(payload.GravityGain) or 0 else 0)
		pulse(
			Enum.VibrationMotor.Small,
			if band == "Massive" then 0.55 else if band == "Medium" then 0.30 else 0.16,
			0.07
		)
	end)
	stateRemote.OnClientEvent:Connect(function(state)
		if type(state) == "table" and state.Event == "ZoneUnlocked" then
			pulse(Enum.VibrationMotor.Small, 0.48, 0.12)
		end
	end)
	collapseRemote.OnClientEvent:Connect(function()
		pulse(Enum.VibrationMotor.Large, 0.65, 0.20)
		task.delay(0.32, function()
			pulse(Enum.VibrationMotor.Small, 0.85, 0.10)
		end)
	end)
end
return HapticsController
