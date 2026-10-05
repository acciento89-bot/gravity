--!strict

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local GameConfig = require(shared.config.GameConfig)
local ZoneConfig = require(shared.config.ZoneConfig)
local ObjectConfig = require(shared.config.ObjectConfig)
local CollectionClaimRules = require(shared.rules.CollectionClaimRules)
local OnboardingRules = require(shared.rules.OnboardingRules)

local ObjectVisualFactory = require(script.Parent.ObjectVisualFactory)
local ZoneVisualFactory = require(script.Parent.ZoneVisualFactory)

local WorldService = {}

local world: Folder
local claimStates: { [BasePart]: any } = {}

local COLORS = {
	Foundation = Color3.fromRGB(21, 29, 40),
	Road = Color3.fromRGB(40, 47, 57),
	Text = Color3.fromRGB(244, 247, 251),
	Locked = Color3.fromRGB(170, 74, 74),
}

local function configureLighting()
	Lighting.ClockTime = 15.2
	Lighting.Brightness = 2.15
	Lighting.Ambient = Color3.fromRGB(92, 104, 124)
	Lighting.OutdoorAmbient = Color3.fromRGB(126, 139, 160)
	Lighting.EnvironmentDiffuseScale = 0.42
	Lighting.EnvironmentSpecularScale = 0.72
	Lighting.ShadowSoftness = 0.32
	pcall(function()
		Lighting.Technology = Enum.Technology.Future
	end)

	for _, name in { "Plus1GravityAtmosphere", "Plus1GravityBloom", "Plus1GravityWorldGrade" } do
		local old = Lighting:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "Plus1GravityAtmosphere"
	atmosphere.Density = 0.22
	atmosphere.Offset = 0.08
	atmosphere.Color = Color3.fromRGB(204, 229, 244)
	atmosphere.Decay = Color3.fromRGB(112, 129, 158)
	atmosphere.Glare = 0.10
	atmosphere.Haze = 1.25
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "Plus1GravityBloom"
	bloom.Intensity = 0.22
	bloom.Size = 22
	bloom.Threshold = 1.35
	bloom.Parent = Lighting

	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "Plus1GravityWorldGrade"
	grade.Brightness = 0.015
	grade.Contrast = 0.07
	grade.Saturation = 0.06
	grade.TintColor = Color3.fromRGB(244, 249, 255)
	grade.Parent = Lighting
end

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
	heading.Name = "Heading"
	heading.Size = UDim2.new(1, -20, 0, 42)
	heading.Position = UDim2.fromOffset(10, 6)
	heading.BackgroundTransparency = 1
	heading.Font = Enum.Font.GothamBlack
	heading.Text = title
	heading.TextSize = 24
	heading.TextColor3 = COLORS.Text
	heading.Parent = frame

	local sub = Instance.new("TextLabel")
	sub.Name = "Requirement"
	sub.Size = UDim2.new(1, -20, 0, 28)
	sub.Position = UDim2.fromOffset(10, 48)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.GothamMedium
	sub.Text = subtitle
	sub.TextSize = 14
	sub.TextColor3 = accent
	sub.Parent = frame
end

local function leaderboardBoard(parent: Instance, center: Vector3, size: Vector3)
	local board = part(
		"GravityLeaderboardBoard",
		Vector3.new(18, 11, 0.7),
		CFrame.new(center + Vector3.new(0, 6.2, -size.Z * 0.36)),
		Color3.fromRGB(24, 31, 43),
		Enum.Material.Metal,
		parent
	)
	board.CanCollide = false

	local gui = Instance.new("SurfaceGui")
	gui.Name = "LeaderboardSurface"
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 550)
	gui.LightInfluence = 0
	gui.Parent = board

	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = COLORS.Foundation
	background.BorderSizePixel = 0
	background.Parent = gui

	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, -60, 0, 100)
	header.Position = UDim2.fromOffset(30, 20)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBlack
	header.Text = "MEGACITY · TOP GRAVITY"
	header.TextSize = 38
	header.TextColor3 = Color3.fromRGB(91, 220, 239)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = background

	local rows = Instance.new("Frame")
	rows.Name = "Rows"
	rows.Size = UDim2.new(1, -60, 1, -145)
	rows.Position = UDim2.fromOffset(30, 125)
	rows.BackgroundTransparency = 1
	rows.Parent = gui
	for index = 1, 5 do
		local row = Instance.new("TextLabel")
		row.Name = "Row" .. index
		row.Size = UDim2.new(1, 0, 0, 72)
		row.Position = UDim2.fromOffset(0, (index - 1) * 76)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.GothamBold
		row.Text = ("#%d  ---"):format(index)
		row.TextSize = 30
		row.TextColor3 = if index <= 3 then Color3.fromRGB(255, 211, 96) else COLORS.Text
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Parent = rows
	end
end

local function progressionGate(parent: Instance, zone: any, center: Vector3, size: Vector3, accent: Color3)
	if (zone.Order or 0) <= 1 then
		return
	end

	local gateModel = Instance.new("Model")
	gateModel.Name = "ZoneGate_" .. tostring(zone.Id)
	gateModel:SetAttribute("ZoneId", zone.Id)
	gateModel:SetAttribute("DisplayName", zone.DisplayName)
	gateModel:SetAttribute("MinGravity", zone.MinGravity)
	gateModel:SetAttribute("MinCores", zone.MinCores)
	gateModel:SetAttribute("AccentR", accent.R)
	gateModel:SetAttribute("AccentG", accent.G)
	gateModel:SetAttribute("AccentB", accent.B)
	gateModel.Parent = parent
	CollectionService:AddTag(gateModel, "GravityZoneGate")

	local entryX = center.X - size.X / 2 + 3
	local gateZ = center.Z
	for side = -1, 1, 2 do
		local pillar = part(
			"GatePillar",
			Vector3.new(1.3, 10, 1.3),
			CFrame.new(entryX, 5, gateZ + side * 11),
			accent,
			Enum.Material.Metal,
			gateModel
		)
		pillar.CanCollide = false

		local glow = part(
			"GateGlow",
			Vector3.new(0.45, 8.2, 0.45),
			CFrame.new(entryX - 0.7, 5, gateZ + side * 11),
			accent,
			Enum.Material.Neon,
			gateModel
		)
		glow.CanCollide = false
		glow:SetAttribute("GateVisualRole", "Glow")
	end

	local beam = part(
		"GateBeam",
		Vector3.new(1.3, 1.3, 23.5),
		CFrame.new(entryX, 10, gateZ),
		accent,
		Enum.Material.Metal,
		gateModel
	)
	beam.CanCollide = false

	local field = part(
		"GateField",
		Vector3.new(0.28, 8.2, 20.5),
		CFrame.new(entryX, 5, gateZ),
		accent,
		Enum.Material.ForceField,
		gateModel
	)
	field.Transparency = 0.74
	field.CanCollide = false
	field.CanTouch = false
	field.CanQuery = false
	field:SetAttribute("GateVisualRole", "Field")

	local requirement = if zone.MinCores > 0
		then ("%s GRAVITY · %d CORE%s"):format(zone.MinGravity, zone.MinCores, if zone.MinCores == 1 then "" else "S")
		else ("%s GRAVITY"):format(zone.MinGravity)
	billboard(beam, ("ZONE %d · %s"):format(zone.Order, string.upper(zone.DisplayName)), requirement, accent)
end

local function setVisible(model: Instance, visible: boolean)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Transparency = if visible then descendant:GetAttribute("BaseTransparency") or 0 else 1
			descendant.CanQuery = visible and descendant:GetAttribute("BaseCanQuery") ~= false
		end
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
	root.CanTouch = false
	root.CanQuery = false
	root.CastShadow = false
	root.Transparency = 1
	root:SetAttribute("BaseCanQuery", false)
	root:SetAttribute("ObjectId", definition.Id)
	root:SetAttribute("DisplayName", definition.Name)
	root:SetAttribute("RequiredGravity", definition.RequiredGravity)
	root:SetAttribute("GravityGain", definition.GravityGain)
	root:SetAttribute("XP", definition.XP)
	root:SetAttribute("Respawn", definition.Respawn)
	root:SetAttribute("BaseTransparency", 1)
	root:SetAttribute("Active", true)
	CollectionService:AddTag(root, "GravityCollectible")
	claimStates[root] = CollectionClaimRules.newState()
	model.PrimaryPart = root

	ObjectVisualFactory.decorate(model, root, definition)
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

	progressionGate(zoneFolder, zone, center, size, accent)
	ZoneVisualFactory.decorate(zoneFolder, zone)
	if zone.Id == "megacity" then
		leaderboardBoard(zoneFolder, center, size)
	end

	local available = {}
	for _, definition in ObjectConfig do
		if definition.Zone == zone.Id then
			table.insert(available, definition)
		end
	end
	for objectIndex, definition in available do
		for copyIndex = 1, GameConfig.World.CollectibleCopiesPerObject do
			local seed = zone.Order * 10000 + objectIndex * 100 + copyIndex
			local guidedX, guidedZ =
				if zone.Id == "backyard" then OnboardingRules.collectibleOffset(definition.Id, copyIndex) else nil, nil
			if guidedX and guidedZ then
				spawnCollectible(definition, center + Vector3.new(guidedX, 0, guidedZ), seed)
			else
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

	if zone.Id == "backyard" then
		local tease = part(
			"DowntownTease",
			Vector3.new(1, 5.5, 1),
			CFrame.new(center + Vector3.new(70, 2.75, -10)),
			Color3.fromRGB(91, 220, 239),
			Enum.Material.Neon,
			zoneFolder
		)
		tease.CanCollide = false
		billboard(tease, "DOWNTOWN AHEAD", "120 GRAVITY · KEEP GROWING", Color3.fromRGB(91, 220, 239))
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

local function buildGravityVista()
	local vista = Instance.new("Folder")
	vista.Name = "GravityVista"
	vista.Parent = world

	local cyan = Color3.fromRGB(91, 220, 239)
	local violet = Color3.fromRGB(164, 134, 255)
	local gold = Color3.fromRGB(255, 210, 105)

	for index = 0, 8 do
		local x = 45 + index * 108
		for _, side in { -1, 1 } do
			local height = 24 + (index % 4) * 9 + math.abs(side) * 2
			local monolith = part(
				"GravityHorizonMonolith",
				Vector3.new(10 + (index % 3) * 3, height, 10 + (index % 2) * 2),
				CFrame.new(x, height / 2 - 4, side * (96 + (index % 3) * 17)),
				Color3.fromRGB(34 + index * 2, 43 + index * 2, 61 + index * 2),
				if index % 3 == 0 then Enum.Material.Glass else Enum.Material.Metal,
				vista
			)
			monolith.CanCollide = false
			monolith.CanTouch = false
			monolith.CanQuery = false
			if index % 3 == 0 then
				monolith.Transparency = 0.18
			end

			local crown = part(
				"GravityMonolithCrown",
				Vector3.new(monolith.Size.X * 0.72, 0.18, 0.22),
				monolith.CFrame * CFrame.new(0, height / 2 + 0.28, -monolith.Size.Z / 2 - 0.08),
				if (index + side) % 2 == 0 then cyan else violet,
				Enum.Material.Neon,
				vista
			)
			crown.Transparency = 0.38
			crown.CanCollide = false
			crown.CanTouch = false
			crown.CanQuery = false
		end
	end

	for _, z in { -11.3, 11.3 } do
		local guide = part(
			"BoulevardGuide",
			Vector3.new(910, 0.08, 0.24),
			CFrame.new(430, 0.39, z),
			if z < 0 then cyan else violet,
			Enum.Material.Neon,
			vista
		)
		guide.Transparency = 0.18
		guide.CanCollide = false
		guide.CanTouch = false
		guide.CanQuery = false
	end

	local sun = part(
		"GravitySunDisc",
		Vector3.new(28, 28, 28),
		CFrame.new(720, 92, -210),
		gold,
		Enum.Material.Neon,
		vista
	)
	sun.Shape = Enum.PartType.Ball
	sun.Transparency = 0.12
	sun.CanCollide = false
	sun.CanTouch = false
	sun.CanQuery = false

	local halo = part(
		"GravitySunHalo",
		Vector3.new(52, 52, 52),
		CFrame.new(720, 92, -213),
		Color3.fromRGB(255, 222, 166),
		Enum.Material.Neon,
		vista
	)
	halo.Shape = Enum.PartType.Ball
	halo.Transparency = 0.92
	halo.CanCollide = false
	halo.CanTouch = false
	halo.CanQuery = false
end

function WorldService.start()
	configureLighting()
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

	buildGravityVista()

	for slot = 1, GameConfig.World.TargetMaxPlayers do
		local x, z = OnboardingRules.spawnOffset(slot)
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = ("GravitySpawn%02d"):format(slot)
		spawn.Size = Vector3.new(2.4, 0.5, 2.4)
		spawn.CFrame = CFrame.new(x, 2, z)
		spawn.Material = Enum.Material.Neon
		spawn.Color = Color3.fromRGB(91, 220, 239)
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.Neutral = true
		spawn.Duration = 0
		spawn.Parent = world
	end

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
