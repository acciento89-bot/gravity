--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local AudioConfig = require(shared.config.AudioConfig)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local AmbientController = {}
local currentZone: string? = nil
local currentSound: Sound? = nil
local soundGroup: SoundGroup

local function makeSound(zoneId: string, definition: any): Sound
	local sound = Instance.new("Sound")
	sound.Name = "GravityAmbient_" .. zoneId
	sound.SoundId = "rbxassetid://" .. tostring(definition.AssetId)
	sound.Looped = true
	sound.Volume = 0
	sound.PlaybackSpeed = tonumber(definition.PlaybackSpeed) or 1
	sound.SoundGroup = soundGroup
	sound.Parent = SoundService
	return sound
end

local function fadeTo(zoneId: string)
	if zoneId == currentZone then
		return
	end
	local definition = AudioConfig.Ambient[zoneId]
	if not definition then
		return
	end

	currentZone = zoneId
	local previous = currentSound
	local nextSound = makeSound(zoneId, definition)
	currentSound = nextSound
	nextSound:Play()

	TweenService:Create(
		nextSound,
		TweenInfo.new(AudioConfig.AmbientFadeSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Volume = tonumber(definition.Volume) or 0.07 }
	):Play()

	if previous then
		local tween = TweenService:Create(
			previous,
			TweenInfo.new(AudioConfig.AmbientFadeSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Volume = 0 }
		)
		tween:Play()
		tween.Completed:Once(function()
			previous:Stop()
			previous:Destroy()
		end)
	end
end

local function applyState(state: any)
	if type(state) ~= "table" or state.Ready ~= true or type(state.Zone) ~= "table" then
		return
	end
	if type(state.Zone.Id) == "string" then
		fadeTo(state.Zone.Id)
	end
end

function AmbientController.start()
	local old = SoundService:FindFirstChild("Plus1GravityAmbience")
	if old then
		old:Destroy()
	end
	soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "Plus1GravityAmbience"
	soundGroup.Volume = AudioConfig.AmbientMasterVolume
	soundGroup.Parent = SoundService
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	stateRemote.OnClientEvent:Connect(applyState)
	task.spawn(function()
		local ok, state = pcall(function()
			return (remotes:WaitForChild("QueryState") :: RemoteFunction):InvokeServer()
		end)
		if ok then
			applyState(state)
		end
	end)
end

return AmbientController
