--!strict

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local FeedbackRules = require(shared.rules.FeedbackRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local GameFeelController = {}

local TRANSIENT_SOURCE = "rbxasset://sounds/electronicpingshort.wav"
local MAX_TRANSIENT_SOUNDS = 4
local MAX_PULSES = 8
local activeSounds = 0
local activePulses = 0
local lastCueAt: { [string]: number } = {}
local lastLevel: number? = nil

local function playCue(name: string, pitch: number, volume: number, cooldown: number)
	local now = os.clock()
	if activeSounds >= MAX_TRANSIENT_SOUNDS or now - (lastCueAt[name] or -math.huge) < cooldown then
		return
	end
	lastCueAt[name] = now
	local sound = Instance.new("Sound")
	sound.Name = "GravityCue_" .. name
	sound.SoundId = TRANSIENT_SOURCE
	sound.Volume = math.clamp(volume, 0, 0.28)
	sound.PlaybackSpeed = math.clamp(pitch, 0.45, 1.7)
	sound.Parent = SoundService
	activeSounds += 1
	local cleaned = false
	local function cleanup()
		if cleaned then
			return
		end
		cleaned = true
		activeSounds = math.max(0, activeSounds - 1)
	end
	sound.Ended:Once(cleanup)
	sound.Destroying:Once(cleanup)
	Debris:AddItem(sound, 3)
	sound:Play()
end

local function pulse(color: Color3, size: number)
	if activePulses >= MAX_PULSES then
		return
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end
	activePulses += 1
	local part = Instance.new("Part")
	part.Name = "GravityFeedbackPulse"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(0.35, 0.35, 0.35)
	part.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.4, 0))
	part.Color = color
	part.Material = Enum.Material.ForceField
	part.Transparency = 0.35
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = Workspace
	local tween = TweenService:Create(part, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = Vector3.new(size, size, size),
		Transparency = 1,
	})
	tween:Play()
	tween.Completed:Once(function()
		activePulses = math.max(0, activePulses - 1)
		part:Destroy()
	end)
	Debris:AddItem(part, 0.6)
end

local function cameraMicroKick(amount: number)
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	local original = camera.FieldOfView
	TweenService:Create(camera, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		FieldOfView = original + amount,
	}):Play()
	task.delay(0.09, function()
		if camera.Parent then
			TweenService:Create(camera, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = original,
			}):Play()
		end
	end)
end

local function onCollect(payload: any)
	if type(payload) ~= "table" then
		return
	end
	local band = FeedbackRules.collectBand(tonumber(payload.GravityGain) or 0)
	playCue(
		"Collect" .. band,
		FeedbackRules.collectPitch(band),
		FeedbackRules.collectVolume(band),
		if band == "Small" then 0.06 else 0.10
	)
	if band == "Medium" then
		pulse(Color3.fromRGB(91, 220, 239), 2.0)
	elseif band == "Massive" then
		pulse(Color3.fromRGB(255, 211, 96), 3.3)
		cameraMicroKick(1.4)
	end
end

local function onState(newState: any)
	if type(newState) ~= "table" or newState.Ready ~= true then
		return
	end
	local level = tonumber(newState.Level) or 0
	if lastLevel ~= nil and level > lastLevel then
		playCue("LevelUp", 1.34, 0.20, 0.3)
		pulse(Color3.fromRGB(164, 134, 255), 2.8)
	end
	lastLevel = level
	if newState.Event == "ZoneUnlocked" then
		playCue("ZoneUnlock", 1.05, 0.24, 0.8)
		pulse(Color3.fromRGB(105, 224, 154), 3.8)
	elseif newState.Event == "DailyComplete" or newState.Event == "PurchaseGranted" then
		playCue("Reward", 1.42, 0.18, 0.25)
	end
end

local function onCollapse(payload: any)
	local cores = if type(payload) == "table" then tonumber(payload.Cores) or 0 else 0
	local milestone = FeedbackRules.coreMilestoneBand(cores)
	local lowPitch = if milestone == "Major" then 0.52 else if milestone == "Medium" then 0.60 else 0.68
	playCue("CollapseCharge", lowPitch, 0.24, 0.8)
	task.delay(0.34, function()
		playCue("CollapseImpact", if milestone == "Major" then 1.30 else 1.12, 0.26, 0.5)
	end)
end

function GameFeelController.start()
	(remotes:WaitForChild("OrbitCollect") :: RemoteEvent).OnClientEvent
		:Connect(onCollect)(remotes:WaitForChild("State") :: RemoteEvent).OnClientEvent
		:Connect(onState)(remotes:WaitForChild("CollapseFx") :: RemoteEvent).OnClientEvent
		:Connect(onCollapse)
end

return GameFeelController
