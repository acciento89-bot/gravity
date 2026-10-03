--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)
local CosmeticConfig = require(shared.config.CosmeticConfig)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local OrbitController = {}

type OrbitEntry = {
	Part: BasePart,
	Angle: number,
	Ring: number,
	Phase: number,
	PullFrom: Vector3?,
	PullElapsed: number,
	PullDuration: number,
}

local entries: { OrbitEntry } = {}
local folder: Folder
local equippedSkin = "Default"
local collapseIntensity = 0
local rotationClock = 0

local function colorFrom(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function vectorFrom(values: any): Vector3?
	if type(values) ~= "table" then
		return nil
	end
	local x = tonumber(values[1])
	local y = tonumber(values[2])
	local z = tonumber(values[3])
	if not x or not y or not z then
		return nil
	end
	return Vector3.new(x, y, z)
end

local function clear()
	for _, entry in entries do
		entry.Part:Destroy()
	end
	table.clear(entries)
end

local function skinColor(): Color3
	local definition = CosmeticConfig.OrbitSkins[equippedSkin] or CosmeticConfig.OrbitSkins.Default
	return colorFrom(definition.Color)
end

local function makeVisual(payload: any)
	if type(payload) ~= "table" or type(payload.Size) ~= "table" or type(payload.Color) ~= "table" then
		return
	end

	local rawSize = Vector3.new(payload.Size[1] or 1, payload.Size[2] or 1, payload.Size[3] or 1)
	local maxDimension = math.max(rawSize.X, rawSize.Y, rawSize.Z)
	local scale = if maxDimension > GameConfig.Orbit.MaxVisualSize
		then GameConfig.Orbit.MaxVisualSize / maxDimension
		else 1
	local size = rawSize * scale

	if #entries >= GameConfig.Orbit.VisibleSlots then
		local oldest = table.remove(entries, 1)
		oldest.Part:Destroy()
	end

	local item = Instance.new("Part")
	item.Name = "Orbit_" .. tostring(payload.ObjectId or "Object")
	item.Size = size
	item.Color = colorFrom(payload.Color):Lerp(skinColor(), 0.34)
	item.Material = Enum.Material.SmoothPlastic
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.CastShadow = false
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = folder

	if tostring(payload.ObjectId) == "can" or tostring(payload.ObjectId) == "barrel" then
		item.Shape = Enum.PartType.Cylinder
	end

	local pullFrom = vectorFrom(payload.WorldPosition)
	if pullFrom then
		item.CFrame = CFrame.new(pullFrom)
		item.Transparency = 0.28
	end

	local slot = #entries + 1
	table.insert(entries, {
		Part = item,
		Angle = (slot / GameConfig.Orbit.VisibleSlots) * math.pi * 2,
		Ring = ((slot - 1) % 3) + 1,
		Phase = slot * 0.73,
		PullFrom = pullFrom,
		PullElapsed = 0,
		PullDuration = 0.24,
	})
end

local function update(dt: number)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end

	rotationClock += dt * (GameConfig.Orbit.BaseRotationSpeed + collapseIntensity * 5.5)
	for index, entry in entries do
		local ringT = if entry.Ring == 1 then 0 else if entry.Ring == 2 then 0.52 else 1
		local radius = GameConfig.Orbit.InnerRadius
			+ (GameConfig.Orbit.OuterRadius - GameConfig.Orbit.InnerRadius) * ringT
		if collapseIntensity > 0 then
			radius *= math.max(0.08, 1 - collapseIntensity)
		end

		local angle = entry.Angle + rotationClock * (if entry.Ring == 2 then -1 else 1)
		local height = 1.6 + (entry.Ring - 1) * 1.15 + math.sin(rotationClock * 1.8 + entry.Phase) * 0.55
		local localOffset = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
		local targetPosition = root.Position + localOffset
		local displayPosition = targetPosition

		if entry.PullFrom then
			entry.PullElapsed += dt
			local alpha = math.clamp(entry.PullElapsed / entry.PullDuration, 0, 1)
			local eased = 1 - ((1 - alpha) ^ 3)
			displayPosition = entry.PullFrom:Lerp(targetPosition, eased)
			if alpha >= 1 then
				entry.PullFrom = nil
			end
		end

		local spin = CFrame.Angles(rotationClock * 0.7 + index, angle * 0.5, rotationClock + entry.Phase)
		entry.Part.CFrame = CFrame.new(displayPosition) * spin

		local pullTransparency = if entry.PullFrom
			then 0.28 * (1 - math.clamp(entry.PullElapsed / entry.PullDuration, 0, 1))
			else 0
		entry.Part.Transparency = math.clamp(pullTransparency + collapseIntensity * 0.72, 0, 1)
	end
end

function OrbitController.start()
	local existing = Workspace:FindFirstChild("Plus1GravityOrbitLocal")
	if existing then
		existing:Destroy()
	end

	folder = Instance.new("Folder")
	folder.Name = "Plus1GravityOrbitLocal"
	folder.Parent = Workspace

	local orbitRemote = remotes:WaitForChild("OrbitCollect") :: RemoteEvent
	local stateRemote = remotes:WaitForChild("State") :: RemoteEvent
	local collapseRemote = remotes:WaitForChild("CollapseFx") :: RemoteEvent

	orbitRemote.OnClientEvent:Connect(makeVisual)
	stateRemote.OnClientEvent:Connect(function(state)
		if type(state) == "table" and type(state.EquippedOrbitSkin) == "string" then
			equippedSkin = state.EquippedOrbitSkin
		end
	end)
	collapseRemote.OnClientEvent:Connect(function()
		task.spawn(function()
			collapseIntensity = 0
			for step = 1, 18 do
				collapseIntensity = step / 18
				task.wait(0.035)
			end
			clear()
			collapseIntensity = 0
		end)
	end)

	player.CharacterAdded:Connect(function()
		clear()
	end)
	RunService.RenderStepped:Connect(update)
end

return OrbitController
