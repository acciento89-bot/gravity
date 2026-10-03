--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local ZoneConfig = require(shared.config.ZoneConfig)
local ObjectConfig = require(shared.config.ObjectConfig)
local CollectionClaimRules = require(shared.rules.CollectionClaimRules)

local WorldService = {}

local world: Folder
local claimStates: { [BasePart]: any } = {}

local COLORS = {
	Foundation = Color3.fromRGB(21, 29, 40),
	Road = Color3.fromRGB(40, 47, 57),
	Text = Color3.fromRGB(244, 247, 251),
	Locked = Color3.fromRGB(170, 74, 74),
}

local function color3(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function vec3(values: { number }): Vector3
	return Vector3.new(values[1], values[2], values[3])
end

local function part(
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	parent: Instance
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.Anchored = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function billboard(adornee: BasePart, title: string, subtitle: string, accent: Color3)
	local gui = Instance.new("BillboardGui")
	gui.Name = "ZoneSign"
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(300, 90)
	gui.StudsOffset = Vector3.new(0, 6.5, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 180
	gui.Parent = adornee

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = COLORS.Foundation
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = accent
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Parent = frame

	local heading = Instance.new("TextLabel")
	heading.Size = UDim2.new(1, -20, 0, 42)
	heading.Position = UDim2.fromOffset(10, 6)
	heading.BackgroundTransparency = 1
	heading.Font = Enum.Font.GothamBlack
	heading.Text = title
	heading.TextSize = 24
	heading.TextColor3 = COLORS.Text
	heading.Parent = frame

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -20, 0, 28)
	sub.Position = UDim2.fromOffset(10, 48)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.GothamMedium
	sub.Text = subtitle
	sub.TextSize = 14
	sub.TextColor3 = accent
	sub.Parent = frame
end

local function setVisible(model: Instance, visible: boolean)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = if visible then descendant:GetAttribute("BaseTransparency") or 0 else 1
			descendant.CanQuery = visible
		end
	end
end

local function addVisualDetail(model: Model, root: Part, definition: any)
	local size = root.Size
	if
		string.find(definition.Id, "car")
		or string.find(definition.Id, "bus")
		or definition.Id == "forklift"
		or definition.Id == "service_cart"
	then
		local cabin = part(
			"Cabin",
			Vector3.new(size.X * 0.72, math.max(1.0, size.Y * 0.62), size.Z * 0.42),
			root.CFrame * CFrame.new(0, size.Y * 0.48, -size.Z * 0.12),
			root.Color:Lerp(Color3.new(1, 1, 1), 0.08),
			Enum.Material.SmoothPlastic,
			model
		)
		cabin.CanCollide = false
		for side = -1, 1, 2 do
			for z = -1, 1, 2 do
				local wheel = part(
					"Wheel",
					Vector3.new(
						math.max(0.6, size.X * 0.18),
						math.max(0.6, size.Y * 0.34),
						math.max(0.6, size.X * 0.18)
					),
					root.CFrame * CFrame.new(side * size.X * 0.46, -size.Y * 0.42, z * size.Z * 0.30),
					Color3.fromRGB(35, 38, 44),
					Enum.Material.SmoothPlastic,
					model
				)
				wheel.Shape = Enum.PartType.Cylinder
				wheel.Orientation = Vector3.new(0, 0, 90)
				wheel.CanCollide = false
			end
		end
	elseif definition.Id == "street_tree" then
		root.Color = Color3.fromRGB(103, 73, 46)
		local crown = part(
			"Crown",
			Vector3.new(size.X, size.X, size.X),
			root.CFrame * CFrame.new(0, size.Y * 0.58, 0),
			Color3.fromRGB(68, 151, 88),
			Enum.Material.Grass,
			model
		)
		crown.Shape = Enum.PartType.Ball
		crown.CanCollide = false
	elseif definition.Id == "barrel" or definition.Id == "can" then
		root.Shape = Enum.PartType.Cylinder
		root.Orientation = Vector3.new(0, 0, 90)
	end
end

local function spawnCollectible(definition: any, position: Vector3, index: number)
	local model = Instance.new("Model")
	model.Name = definition.Name:gsub("%s+", "") .. "_" .. index
	model.Parent = world

	local baseSize = vec3(definition.Size)
	local root = part(
		"Collectible",
		baseSize,
		CFrame.new(position + Vector3.new(0, baseSize.Y / 2 + 0.6, 0))
			* CFrame.Angles(0, math.rad((index * 47) % 360), 0),
		color3(definition.Color),
		Enum.Material.SmoothPlastic,
		model
	)
	root.CanCollide = false
	root:SetAttribute("ObjectId", definition.Id)
	root:SetAttribute("DisplayName", definition.Name)
	root:SetAttribute("RequiredGravity", definition.RequiredGravity)
	root:SetAttribute("GravityGain", definition.GravityGain)
	root:SetAttribute("XP", definition.XP)
	root:SetAttribute("Respawn", definition.Respawn)
	root:SetAttribute("BaseTransparency", 0)
	root:SetAttribute("Active", true)
	CollectionService:AddTag(root, "GravityCollectible")
	claimStates[root] = CollectionClaimRules.newState()
	model.PrimaryPart = root

	addVisualDetail(model, root, definition)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant ~= root then
			descendant:SetAttribute("BaseTransparency", descendant.Transparency)
		end
	end
end

local function buildZone(zone: any)
	local center = vec3(zone.Center)
	local size = vec3(zone.Size)
	local accent = color3(zone.Accent)
	local zoneFolder = Instance.new("Folder")
	zoneFolder.Name = zone.Id
	zoneFolder.Parent = world

	local ground = part(
		"Ground",
		Vector3.new(size.X, 2, size.Z),
		CFrame.new(center + Vector3.new(0, -1, 0)),
		Color3.fromRGB(58 + zone.Order * 4, 78 + zone.Order * 3, 68 + zone.Order * 2),
		Enum.Material.Concrete,
		zoneFolder
	)
	ground.CanCollide = true

	local road = part(
		"Road",
		Vector3.new(size.X, 0.35, 22),
		CFrame.new(center + Vector3.new(0, 0.18, 0)),
		COLORS.Road,
		Enum.Material.Asphalt,
		zoneFolder
	)
	road.CanCollide = false

	local signPost = part(
		"SignPost",
		Vector3.new(1.2, 7, 1.2),
		CFrame.new(center + Vector3.new(-size.X * 0.40, 3.5, -size.Z * 0.34)),
		accent,
		Enum.Material.Neon,
		zoneFolder
	)
	signPost.CanCollide = false
	local requirement = if zone.MinCores > 0
		then ("%s GRAVITY · %d CORE%s"):format(zone.MinGravity, zone.MinCores, if zone.MinCores == 1 then "" else "S")
		else ("%s GRAVITY"):format(zone.MinGravity)
	billboard(signPost, string.upper(zone.DisplayName), requirement, accent)

	-- Landmark silhouettes keep each zone visually distinct without expensive asset dependencies.
	for i = 1, 9 do
		local angle = (i / 9) * math.pi * 2
		local radiusX = size.X * 0.38
		local radiusZ = size.Z * 0.36
		local height = 7 + ((i * 13 + zone.Order * 7) % 16)
		local width = 8 + ((i * 5) % 8)
		local landmark = part(
			"Landmark_" .. i,
			Vector3.new(width, height, width),
			CFrame.new(center + Vector3.new(math.cos(angle) * radiusX, height / 2, math.sin(angle) * radiusZ)),
			Color3.fromRGB(62 + zone.Order * 9, 72 + zone.Order * 8, 86 + zone.Order * 9),
			if zone.Id == "backyard" then Enum.Material.WoodPlanks else Enum.Material.Concrete,
			zoneFolder
		)
		landmark.CanCollide = true
	end

	local available = {}
	for _, definition in ObjectConfig do
		if definition.Zone == zone.Id then
			table.insert(available, definition)
		end
	end
	for objectIndex, definition in available do
		for copyIndex = 1, 9 do
			local seed = zone.Order * 10000 + objectIndex * 100 + copyIndex
			local rng = Random.new(seed)
			local x = rng:NextNumber(-size.X * 0.32, size.X * 0.32)
			local z = rng:NextNumber(-size.Z * 0.31, size.Z * 0.31)
			if math.abs(z) < 15 then
				z += if z >= 0 then 18 else -18
			end
			spawnCollectible(definition, center + Vector3.new(x, 0, z), seed)
		end
	end
end

function WorldService.collect(root: BasePart): boolean
	local claimState = claimStates[root]
	if not claimState or root:GetAttribute("Active") ~= true then
		return false
	end

	local claimed, revision = CollectionClaimRules.tryClaim(claimState)
	if not claimed then
		return false
	end

	root:SetAttribute("Active", false)
	local model = root.Parent
	if model then
		setVisible(model, false)
	end

	local respawn = math.max(0.25, tonumber(root:GetAttribute("Respawn")) or 8)
	task.delay(respawn, function()
		if root.Parent and model and model.Parent and CollectionClaimRules.reactivate(claimState, revision) then
			root:SetAttribute("Active", true)
			setVisible(model, true)
		end
	end)
	return true
end

function WorldService.start()
	local existing = Workspace:FindFirstChild("Plus1GravityWorld")
	if existing then
		existing:Destroy()
	end

	world = Instance.new("Folder")
	world.Name = "Plus1GravityWorld"
	world.Parent = Workspace

	for _, zone in ZoneConfig do
		buildZone(zone)
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "GravitySpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = CFrame.new(0, 2, 0)
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(91, 220, 239)
	spawn.Transparency = 0.15
	spawn.Neutral = true
	spawn.Parent = world

	local pathLength = 960
	local path = part(
		"GravityBoulevard",
		Vector3.new(pathLength, 0.3, 20),
		CFrame.new(430, 0.2, 0),
		COLORS.Road,
		Enum.Material.Asphalt,
		world
	)
	path.CanCollide = false
end

return WorldService
