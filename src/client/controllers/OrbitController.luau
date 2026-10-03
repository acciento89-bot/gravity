--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)
local CosmeticConfig = require(shared.config.CosmeticConfig)
local ObjectConfig = require(shared.config.ObjectConfig)
local OrbitRules = require(shared.rules.OrbitRules)
local remotes = ReplicatedStorage:WaitForChild("Plus1GravityRemotes")

local OrbitController = {}

type OrbitEntry = {
	Model: Model,
	Root: BasePart,
	CountLabel: TextLabel,
	ObjectId: string,
	TierBand: number,
	Count: number,
	Angle: number,
	Ring: number,
	Phase: number,
	PullFrom: Vector3?,
	PullElapsed: number,
	PullDuration: number,
	PulseUntil: number,
}

local entries: { OrbitEntry } = {}
local folder: Folder
local equippedSkin = "Default"
local collapseIntensity = 0
local rotationClock = 0
local tierByObjectId: { [string]: number } = {}

for index, definition in ObjectConfig do
	tierByObjectId[definition.Id] = index
end

local VEHICLES = {
	bicycle = true,
	compact_car = true,
	forklift = true,
	luggage_cart = true,
	service_cart = true,
	airport_bus = true,
	jet_stair = true,
	city_bus = true,
}

local CYLINDERS = {
	can = true,
	barrel = true,
	jet_engine = true,
}

local INDUSTRIAL = {
	pallet = true,
	tool_chest = true,
	container = true,
	crane_section = true,
	building_chunk = true,
}

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

local function skinColor(): Color3
	local definition = CosmeticConfig.OrbitSkins[equippedSkin] or CosmeticConfig.OrbitSkins.Default
	return colorFrom(definition.Color)
end

local function preparePart(part: BasePart, baseColor: Color3)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("OrbitBaseTransparency", part.Transparency)
	part:SetAttribute("OrbitBaseColor", baseColor)
end

local function detailPart(
	model: Model,
	root: BasePart,
	name: string,
	size: Vector3,
	offset: Vector3,
	color: Color3,
	material: Enum.Material?,
	shape: Enum.PartType?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = root.CFrame * CFrame.new(offset)
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	if shape then
		item.Shape = shape
	end
	preparePart(item, color)
	item.Parent = model
	return item
end

local function addVehicleDetails(model: Model, root: BasePart, size: Vector3, base: Color3)
	local wheelColor = Color3.fromRGB(38, 42, 48)
	local wheelSize = math.clamp(math.min(size.Y, size.Z) * 0.28, 0.16, 0.55)
	for x = -1, 1, 2 do
		for z = -1, 1, 2 do
			detailPart(
				model,
				root,
				"Wheel",
				Vector3.new(wheelSize * 0.45, wheelSize, wheelSize),
				Vector3.new(x * size.X * 0.46, -size.Y * 0.37, z * size.Z * 0.28),
				wheelColor,
				Enum.Material.SmoothPlastic,
				Enum.PartType.Cylinder
			)
		end
	end
	local glass = base:Lerp(Color3.fromRGB(91, 176, 220), 0.55)
	detailPart(
		model,
		root,
		"Cabin",
		Vector3.new(size.X * 0.70, size.Y * 0.32, size.Z * 0.38),
		Vector3.new(0, size.Y * 0.28, -size.Z * 0.05),
		glass,
		Enum.Material.Glass
	)
end

local function addIndustrialDetails(model: Model, root: BasePart, size: Vector3, base: Color3)
	local accent = base:Lerp(Color3.new(1, 1, 1), 0.30)
	for x = -1, 1, 2 do
		detailPart(
			model,
			root,
			"Brace",
			Vector3.new(math.max(0.08, size.X * 0.08), size.Y * 0.88, math.max(0.08, size.Z * 0.08)),
			Vector3.new(x * size.X * 0.34, 0, 0),
			accent,
			Enum.Material.Metal
		)
	end
end

local function createMiniature(payload: any): (Model, BasePart, TextLabel)
	local objectId = tostring(payload.ObjectId or "Object")
	local rawSize = Vector3.new(payload.Size[1] or 1, payload.Size[2] or 1, payload.Size[3] or 1)
	local maxDimension = math.max(rawSize.X, rawSize.Y, rawSize.Z)
	local scale = if maxDimension > GameConfig.Orbit.MaxVisualSize
		then GameConfig.Orbit.MaxVisualSize / maxDimension
		else 1
	local size = rawSize * scale
	local base = colorFrom(payload.Color):Lerp(skinColor(), 0.30)

	local model = Instance.new("Model")
	model.Name = "Orbit_" .. objectId
	model.Parent = folder

	local root = Instance.new("Part")
	root.Name = "Body"
	root.Size = size
	root.Color = base
	root.Material = if INDUSTRIAL[objectId] then Enum.Material.Metal else Enum.Material.SmoothPlastic
	if CYLINDERS[objectId] then
		root.Shape = Enum.PartType.Cylinder
	end
	preparePart(root, base)
	root.Parent = model
	model.PrimaryPart = root

	if VEHICLES[objectId] then
		addVehicleDetails(model, root, size, base)
	elseif INDUSTRIAL[objectId] then
		addIndustrialDetails(model, root, size, base)
	elseif objectId == "garden_chair" then
		for x = -1, 1, 2 do
			for z = -1, 1, 2 do
				detailPart(
					model,
					root,
					"Leg",
					Vector3.new(0.10, size.Y * 0.55, 0.10),
					Vector3.new(x * size.X * 0.34, -size.Y * 0.55, z * size.Z * 0.30),
					base:Lerp(Color3.new(0, 0, 0), 0.12),
					Enum.Material.Metal
				)
			end
		end
	elseif objectId == "street_tree" then
		detailPart(
			model,
			root,
			"Trunk",
			Vector3.new(size.X * 0.18, size.Y * 0.75, size.Z * 0.18),
			Vector3.new(0, -size.Y * 0.38, 0),
			Color3.fromRGB(105, 76, 49),
			Enum.Material.Wood
		)
	end

	local badge = Instance.new("BillboardGui")
	badge.Name = "CountBadge"
	badge.Adornee = root
	badge.Size = UDim2.fromOffset(54, 24)
	badge.StudsOffset = Vector3.new(0, size.Y * 0.62 + 0.5, 0)
	badge.AlwaysOnTop = false
	badge.MaxDistance = 80
	badge.Enabled = false
	badge.Parent = root

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(18, 25, 35)
	label.BackgroundTransparency = 0.18
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.Text = "×1"
	label.TextColor3 = Color3.fromRGB(246, 249, 252)
	label.TextSize = 13
	label.Parent = badge
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	return model, root, label
end

local function destroyEntry(index: number)
	local entry = table.remove(entries, index)
	if entry then
		entry.Model:Destroy()
	end
end

local function clear()
	for _, entry in entries do
		entry.Model:Destroy()
	end
	table.clear(entries)
end

local function retint()
	local tint = skinColor()
	for _, entry in entries do
		for _, descendant in entry.Model:GetDescendants() do
			if descendant:IsA("BasePart") then
				local base = descendant:GetAttribute("OrbitBaseColor")
				if typeof(base) == "Color3" then
					descendant.Color = base:Lerp(tint, 0.30)
				end
			end
		end
	end
end

local function makeVisual(payload: any)
	if type(payload) ~= "table" or type(payload.Size) ~= "table" or type(payload.Color) ~= "table" then
		return
	end

	local objectId = tostring(payload.ObjectId or "Object")
	local tier = tierByObjectId[objectId] or 1
	local tierBand = OrbitRules.tierBand(tier)
	for _, entry in entries do
		if entry.ObjectId == objectId then
			entry.Count += 1
			entry.CountLabel.Text = ("×%d"):format(entry.Count)
			local badge = entry.CountLabel.Parent
			if badge and badge:IsA("BillboardGui") then
				badge.Enabled = true
			end
			entry.PulseUntil = os.clock() + 0.34
			return
		end
	end

	local replaceIndex = OrbitRules.replacementIndex(entries, objectId, tierBand, GameConfig.Orbit.VisibleSlots)
	if replaceIndex then
		destroyEntry(replaceIndex)
	end

	local model, root, countLabel = createMiniature(payload)
	local pullFrom = vectorFrom(payload.WorldPosition)
	if pullFrom then
		model:PivotTo(CFrame.new(pullFrom))
	end

	local slot = #entries + 1
	local ring = ((tierBand - 1) % 3) + 1
	table.insert(entries, {
		Model = model,
		Root = root,
		CountLabel = countLabel,
		ObjectId = objectId,
		TierBand = tierBand,
		Count = 1,
		Angle = (slot / GameConfig.Orbit.VisibleSlots) * math.pi * 2 + tierBand * 0.41,
		Ring = ring,
		Phase = slot * 0.73 + tierBand * 0.24,
		PullFrom = pullFrom,
		PullElapsed = 0,
		PullDuration = 0.24,
		PulseUntil = 0,
	})
end

local function setVisualTransparency(entry: OrbitEntry, transparency: number)
	for _, descendant in entry.Model:GetDescendants() do
		if descendant:IsA("BasePart") then
			local base = tonumber(descendant:GetAttribute("OrbitBaseTransparency")) or 0
			descendant.Transparency = math.clamp(base + transparency, 0, 1)
		end
	end
end

local function update(dt: number)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local camera = Workspace.CurrentCamera
	if not root or not root:IsA("BasePart") or not camera then
		return
	end

	local viewport = camera.ViewportSize
	local avatarHeight = math.max(4, character:GetExtentsSize().Y)
	local radiusScale = OrbitRules.radiusScale(viewport.X, viewport.Y, avatarHeight)
	rotationClock += dt * (GameConfig.Orbit.BaseRotationSpeed + collapseIntensity * 5.5)

	for index, entry in entries do
		local ringT = if entry.Ring == 1 then 0 else if entry.Ring == 2 then 0.52 else 1
		local radius = (
			GameConfig.Orbit.InnerRadius + (GameConfig.Orbit.OuterRadius - GameConfig.Orbit.InnerRadius) * ringT
		) * radiusScale
		if collapseIntensity > 0 then
			radius *= math.max(0.08, 1 - collapseIntensity)
		end

		local direction = if entry.Ring == 2 then -1 else 1
		local speedBias = 1 + (entry.TierBand - 1) * 0.035
		local angle = entry.Angle + rotationClock * direction * speedBias
		local height = 1.55 + (entry.Ring - 1) * 1.05 * radiusScale + math.sin(rotationClock * 1.8 + entry.Phase) * 0.48
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

		local pulse = if os.clock() < entry.PulseUntil then 1 + math.sin(os.clock() * 42) * 0.08 else 1
		local spin = CFrame.Angles(rotationClock * 0.7 + index, angle * 0.5, rotationClock + entry.Phase)
		entry.Model:PivotTo(CFrame.new(displayPosition) * spin * CFrame.new(0, (pulse - 1) * 0.5, 0))

		local viewportPoint = camera:WorldToViewportPoint(displayPosition)
		local centerFade =
			OrbitRules.occlusionFade(viewportPoint.X, viewportPoint.Y, viewportPoint.Z, viewport.X, viewport.Y)
		local pullTransparency = if entry.PullFrom
			then 0.28 * (1 - math.clamp(entry.PullElapsed / entry.PullDuration, 0, 1))
			else 0
		setVisualTransparency(entry, math.clamp(pullTransparency + collapseIntensity * 0.72 + centerFade, 0, 1))
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
		if
			type(state) == "table"
			and type(state.EquippedOrbitSkin) == "string"
			and state.EquippedOrbitSkin ~= equippedSkin
		then
			equippedSkin = state.EquippedOrbitSkin
			retint()
		end
	end)
	collapseRemote.OnClientEvent:Connect(function()
		task.spawn(function()
			collapseIntensity = 0
			for step = 1, 24 do
				collapseIntensity = step / 24
				task.wait(0.03)
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
