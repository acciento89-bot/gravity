--!strict

local ZoneVisualFactory = {}

local function rgb(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material?,
	canCollide: boolean?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Anchored = true
	item.CanCollide = canCollide == true
	item.CanTouch = false
	item.CanQuery = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function makeCylinder(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material?,
	canCollide: boolean?
): Part
	local item = makePart(parent, name, size, cframe, color, material, canCollide)
	item.Shape = Enum.PartType.Cylinder
	return item
end

local function neonWindow(parent: Instance, cframe: CFrame, size: Vector3, color: Color3)
	local window = makePart(parent, "Window", size, cframe, color, Enum.Material.Neon, false)
	window.Transparency = 0.18
end

local function building(
	parent: Instance,
	name: string,
	position: Vector3,
	size: Vector3,
	body: Color3,
	windowColor: Color3,
	accent: Color3?
)
	local structure = Instance.new("Model")
	structure.Name = name
	structure.Parent = parent

	makePart(
		structure,
		"Body",
		size,
		CFrame.new(position + Vector3.new(0, size.Y / 2, 0)),
		body,
		Enum.Material.Concrete,
		true
	)
	local floors = math.clamp(math.floor(size.Y / 8), 2, 8)
	for floor = 1, floors do
		local y = 3 + (floor - 1) * ((size.Y - 6) / math.max(1, floors - 1))
		for side = -1, 1, 2 do
			neonWindow(
				structure,
				CFrame.new(position + Vector3.new(side * size.X * 0.28, y, size.Z / 2 + 0.04)),
				Vector3.new(size.X * 0.20, math.min(2.2, size.Y / floors * 0.34), 0.10),
				windowColor
			)
		end
	end
	if accent then
		makePart(
			structure,
			"Accent",
			Vector3.new(size.X * 0.08, size.Y * 0.94, 0.16),
			CFrame.new(position + Vector3.new(-size.X * 0.43, size.Y / 2, size.Z / 2 + 0.08)),
			accent,
			Enum.Material.Neon,
			false
		)
	end
end

local function tree(parent: Instance, position: Vector3, scale: number)
	makeCylinder(
		parent,
		"TreeTrunk",
		Vector3.new(5 * scale, 0.8 * scale, 0.8 * scale),
		CFrame.new(position + Vector3.new(0, 2.5 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(105, 76, 49),
		Enum.Material.Wood,
		true
	)
	for _, offset in
		{
			Vector3.new(0, 5.6, 0),
			Vector3.new(1.8, 5.0, 0.6),
			Vector3.new(-1.8, 5.1, -0.5),
		}
	do
		local crown = makePart(
			parent,
			"TreeCrown",
			Vector3.new(4.2, 4.2, 4.2) * scale,
			CFrame.new(position + offset * scale),
			Color3.fromRGB(68, 147, 86),
			Enum.Material.Grass,
			false
		)
		crown.Shape = Enum.PartType.Ball
	end
end

local function fence(parent: Instance, position: Vector3, length: number)
	local color = Color3.fromRGB(226, 222, 206)
	local count = math.max(2, math.floor(length / 4))
	for index = 0, count do
		local z = -length / 2 + index * (length / count)
		makePart(
			parent,
			"FencePicket",
			Vector3.new(0.28, 3.2, 0.28),
			CFrame.new(position + Vector3.new(0, 1.6, z)),
			color,
			Enum.Material.WoodPlanks,
			false
		)
	end
	for y = 0.9, 2.2, 1.3 do
		makePart(
			parent,
			"FenceRail",
			Vector3.new(0.24, 0.22, length),
			CFrame.new(position + Vector3.new(0, y, 0)),
			color,
			Enum.Material.WoodPlanks,
			false
		)
	end
end

local function streetLight(parent: Instance, position: Vector3, accent: Color3)
	makePart(
		parent,
		"StreetLightPole",
		Vector3.new(0.28, 8.5, 0.28),
		CFrame.new(position + Vector3.new(0, 4.25, 0)),
		Color3.fromRGB(62, 68, 78),
		Enum.Material.Metal,
		false
	)
	makePart(
		parent,
		"StreetLightArm",
		Vector3.new(2.6, 0.22, 0.22),
		CFrame.new(position + Vector3.new(1.15, 8.2, 0)),
		Color3.fromRGB(62, 68, 78),
		Enum.Material.Metal,
		false
	)
	local lamp = makePart(
		parent,
		"StreetLight",
		Vector3.new(0.8, 0.18, 0.5),
		CFrame.new(position + Vector3.new(2.2, 8.0, 0)),
		accent,
		Enum.Material.Neon,
		false
	)
	lamp.Transparency = 0.08
end

local function buildBackyard(parent: Instance, center: Vector3, size: Vector3)
	local grass = Color3.fromRGB(70, 104, 76)
	for side = -1, 1, 2 do
		local x = center.X + side * size.X * 0.34
		for row = -1, 1, 2 do
			local z = center.Z + row * size.Z * 0.28
			local houseColor = if row == -1 then Color3.fromRGB(173, 118, 89) else Color3.fromRGB(109, 143, 164)
			local house = Instance.new("Model")
			house.Name = "BackyardHouse"
			house.Parent = parent
			makePart(
				house,
				"House",
				Vector3.new(20, 9, 16),
				CFrame.new(x, 4.5, z),
				houseColor,
				Enum.Material.WoodPlanks,
				true
			)
			local roof = makePart(
				house,
				"Roof",
				Vector3.new(22, 4, 18),
				CFrame.new(x, 10, z),
				Color3.fromRGB(71, 67, 67),
				Enum.Material.Slate,
				false
			)
			roof.Shape = Enum.PartType.Wedge
			neonWindow(
				house,
				CFrame.new(x - side * 10.05, 5.5, z - 3.5),
				Vector3.new(0.10, 2.3, 3.0),
				Color3.fromRGB(255, 223, 153)
			)
			neonWindow(
				house,
				CFrame.new(x - side * 10.05, 5.5, z + 3.5),
				Vector3.new(0.10, 2.3, 3.0),
				Color3.fromRGB(255, 223, 153)
			)
		end
	end
	fence(parent, Vector3.new(center.X - size.X * 0.44, 0, center.Z), size.Z * 0.74)
	fence(parent, Vector3.new(center.X + size.X * 0.44, 0, center.Z), size.Z * 0.74)
	tree(parent, center + Vector3.new(-size.X * 0.28, 0, -size.Z * 0.08), 1.15)
	tree(parent, center + Vector3.new(size.X * 0.26, 0, size.Z * 0.11), 1.05)
	makePart(
		parent,
		"Lawn",
		Vector3.new(size.X * 0.72, 0.18, size.Z * 0.72),
		CFrame.new(center + Vector3.new(0, 0.1, 0)),
		grass,
		Enum.Material.Grass,
		false
	)

	local rift = Instance.new("Model")
	rift.Name = "GravityRift"
	rift.Parent = parent
	local riftCenter = center + Vector3.new(0, 7, -size.Z * 0.37)
	for index = 1, 12 do
		local angle = (index - 1) / 12 * math.pi * 2
		local node = makePart(
			rift,
			"RiftNode",
			Vector3.new(1.0, 1.0, 1.0),
			CFrame.new(riftCenter + Vector3.new(math.cos(angle) * 6.2, math.sin(angle) * 6.2, 0)),
			if index % 2 == 0 then Color3.fromRGB(91, 220, 239) else Color3.fromRGB(164, 134, 255),
			Enum.Material.Neon,
			false
		)
		node.Shape = Enum.PartType.Ball
	end
	local core = makePart(
		rift,
		"GravityRiftCore",
		Vector3.new(5.0, 5.0, 0.5),
		CFrame.new(riftCenter),
		Color3.fromRGB(112, 92, 205),
		Enum.Material.ForceField,
		false
	)
	core.Transparency = 0.34
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(128, 213, 255)
	light.Brightness = 1.4
	light.Range = 24
	light.Shadows = false
	light.Parent = core
end

local function buildDowntown(parent: Instance, center: Vector3, size: Vector3, accent: Color3)
	local bodies = {
		Color3.fromRGB(71, 82, 98),
		Color3.fromRGB(93, 91, 103),
		Color3.fromRGB(65, 75, 86),
	}
	for index = 1, 6 do
		local side = if index <= 3 then -1 else 1
		local slot = ((index - 1) % 3) - 1
		local position = center + Vector3.new(side * size.X * 0.34, 0, slot * size.Z * 0.28)
		local height = 24 + index * 4
		building(
			parent,
			"DowntownTower",
			position,
			Vector3.new(24, height, 23),
			bodies[((index - 1) % #bodies) + 1],
			Color3.fromRGB(109, 200, 229),
			accent
		)
	end
	for z = -2, 2 do
		streetLight(parent, center + Vector3.new(-size.X * 0.20, 0, z * 26), accent)
		streetLight(parent, center + Vector3.new(size.X * 0.20, 0, z * 26), accent)
	end
	for stripe = -3, 3 do
		makePart(
			parent,
			"Crosswalk",
			Vector3.new(1.8, 0.08, 13),
			CFrame.new(center + Vector3.new(stripe * 3.0, 0.28, 0)),
			Color3.fromRGB(224, 227, 232),
			Enum.Material.Concrete,
			false
		)
	end
end

local function buildIndustrial(parent: Instance, center: Vector3, size: Vector3, accent: Color3)
	local warehouseColor = Color3.fromRGB(78, 84, 86)
	for side = -1, 1, 2 do
		local warehouse = Instance.new("Model")
		warehouse.Name = "Warehouse"
		warehouse.Parent = parent
		local position = center + Vector3.new(side * size.X * 0.35, 0, -size.Z * 0.20)
		makePart(
			warehouse,
			"Shell",
			Vector3.new(42, 14, 36),
			CFrame.new(position + Vector3.new(0, 7, 0)),
			warehouseColor,
			Enum.Material.Metal,
			true
		)
		makePart(
			warehouse,
			"Door",
			Vector3.new(18, 9, 0.18),
			CFrame.new(position + Vector3.new(-side * 21.1, 4.5, 0)),
			Color3.fromRGB(50, 55, 61),
			Enum.Material.Metal,
			false
		)
		makePart(
			warehouse,
			"Stripe",
			Vector3.new(42.2, 1.0, 36.2),
			CFrame.new(position + Vector3.new(0, 11.0, 0)),
			accent,
			Enum.Material.Neon,
			false
		)
	end
	for index = -1, 1 do
		local tankPosition = center + Vector3.new(index * 24, 0, size.Z * 0.31)
		makeCylinder(
			parent,
			"StorageTank",
			Vector3.new(15, 11, 11),
			CFrame.new(tankPosition + Vector3.new(0, 7.5, 0)) * CFrame.Angles(0, 0, math.rad(90)),
			Color3.fromRGB(112, 120, 124),
			Enum.Material.Metal,
			true
		)
		makePart(
			parent,
			"TankBand",
			Vector3.new(0.35, 11.5, 11.5),
			CFrame.new(tankPosition + Vector3.new(0, 7.5, 0)),
			accent,
			Enum.Material.Metal,
			false
		)
	end
	for side = -1, 1, 2 do
		makePart(
			parent,
			"PipePost",
			Vector3.new(0.8, 10, 0.8),
			CFrame.new(center + Vector3.new(side * 28, 5, 28)),
			Color3.fromRGB(118, 124, 132),
			Enum.Material.Metal,
			false
		)
	end
	makePart(
		parent,
		"OverheadPipe",
		Vector3.new(58, 0.9, 0.9),
		CFrame.new(center + Vector3.new(0, 9, 28)),
		Color3.fromRGB(188, 113, 57),
		Enum.Material.Metal,
		false
	)
end

local function buildAirport(parent: Instance, center: Vector3, size: Vector3, accent: Color3)
	local terminal = Instance.new("Model")
	terminal.Name = "Terminal"
	terminal.Parent = parent
	makePart(
		terminal,
		"TerminalBody",
		Vector3.new(70, 18, 28),
		CFrame.new(center + Vector3.new(0, 9, -size.Z * 0.33)),
		Color3.fromRGB(159, 168, 178),
		Enum.Material.Metal,
		true
	)
	makePart(
		terminal,
		"GlassFront",
		Vector3.new(66, 10, 0.20),
		CFrame.new(center + Vector3.new(0, 9, -size.Z * 0.33 + 14.1)),
		Color3.fromRGB(91, 151, 183),
		Enum.Material.Glass,
		false
	)
	makePart(
		terminal,
		"TerminalAccent",
		Vector3.new(70.4, 1.0, 28.4),
		CFrame.new(center + Vector3.new(0, 16.2, -size.Z * 0.33)),
		accent,
		Enum.Material.Neon,
		false
	)

	local towerPos = center + Vector3.new(size.X * 0.32, 0, -size.Z * 0.23)
	makeCylinder(
		parent,
		"ControlTower",
		Vector3.new(34, 5, 5),
		CFrame.new(towerPos + Vector3.new(0, 17, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(176, 182, 190),
		Enum.Material.Concrete,
		true
	)
	makePart(
		parent,
		"ControlCab",
		Vector3.new(12, 5, 12),
		CFrame.new(towerPos + Vector3.new(0, 34, 0)),
		Color3.fromRGB(74, 125, 151),
		Enum.Material.Glass,
		true
	)
	makePart(
		parent,
		"ControlRoof",
		Vector3.new(14, 0.8, 14),
		CFrame.new(towerPos + Vector3.new(0, 37, 0)),
		accent,
		Enum.Material.Metal,
		false
	)

	for line = -1, 1, 2 do
		makePart(
			parent,
			"TaxiLine",
			Vector3.new(size.X * 0.72, 0.06, 0.34),
			CFrame.new(center + Vector3.new(0, 0.28, line * 8)),
			Color3.fromRGB(244, 213, 85),
			Enum.Material.Neon,
			false
		)
	end
	for index = -4, 4 do
		makePart(
			parent,
			"RunwayMark",
			Vector3.new(6, 0.07, 0.8),
			CFrame.new(center + Vector3.new(index * 14, 0.29, 0)),
			Color3.fromRGB(230, 233, 238),
			Enum.Material.Concrete,
			false
		)
	end
end

local function buildMegacity(parent: Instance, center: Vector3, size: Vector3, accent: Color3)
	local towerColors = {
		Color3.fromRGB(39, 49, 68),
		Color3.fromRGB(47, 55, 76),
		Color3.fromRGB(52, 46, 70),
	}
	for index = 1, 8 do
		local side = if index <= 4 then -1 else 1
		local slot = ((index - 1) % 4) - 1.5
		local position = center + Vector3.new(side * size.X * 0.34, 0, slot * size.Z * 0.20)
		local height = 44 + ((index * 11) % 35)
		local towerAccent = if index % 2 == 0 then accent else Color3.fromRGB(164, 134, 255)
		building(
			parent,
			"MegacityTower",
			position,
			Vector3.new(25, height, 25),
			towerColors[((index - 1) % #towerColors) + 1],
			Color3.fromRGB(107, 197, 228),
			towerAccent
		)
	end

	local spirePosition = center + Vector3.new(0, 0, size.Z * 0.33)
	makePart(
		parent,
		"SpireBase",
		Vector3.new(22, 56, 22),
		CFrame.new(spirePosition + Vector3.new(0, 28, 0)),
		Color3.fromRGB(42, 49, 67),
		Enum.Material.Metal,
		true
	)
	makePart(
		parent,
		"SpireGlow",
		Vector3.new(2.4, 58, 2.4),
		CFrame.new(spirePosition + Vector3.new(0, 30, 11.1)),
		accent,
		Enum.Material.Neon,
		false
	)
	makeCylinder(
		parent,
		"SpireNeedle",
		Vector3.new(32, 0.8, 0.8),
		CFrame.new(spirePosition + Vector3.new(0, 72, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		accent,
		Enum.Material.Neon,
		false
	)

	for side = -1, 1, 2 do
		makePart(
			parent,
			"SkyRailPost",
			Vector3.new(1.2, 15, 1.2),
			CFrame.new(center + Vector3.new(side * size.X * 0.18, 7.5, 0)),
			Color3.fromRGB(76, 84, 100),
			Enum.Material.Metal,
			false
		)
	end
	makePart(
		parent,
		"SkyRail",
		Vector3.new(size.X * 0.42, 0.9, 2.4),
		CFrame.new(center + Vector3.new(0, 14.5, 0)),
		Color3.fromRGB(88, 98, 117),
		Enum.Material.Metal,
		false
	)
end

local function zoneBeaconDetails(parent: Instance, center: Vector3, size: Vector3, accent: Color3)
	local beaconCenter = center + Vector3.new(-size.X * 0.40, 0.34, -size.Z * 0.34)
	local halo = makeCylinder(
		parent,
		"ZoneBeaconHalo",
		Vector3.new(0.14, 13, 13),
		CFrame.new(beaconCenter) * CFrame.Angles(0, 0, math.rad(90)),
		accent,
		Enum.Material.Neon,
		false
	)
	halo.Transparency = 0.68
	halo.CanQuery = false

	for index = 1, 4 do
		local angle = (index - 1) / 4 * math.pi * 2
		local position = beaconCenter
			+ Vector3.new(math.cos(angle) * 5.2, 3.1 + (index % 2) * 0.8, math.sin(angle) * 5.2)
		local shard = makePart(
			parent,
			"FloatingZoneShard",
			Vector3.new(0.7, 3.8, 0.7),
			CFrame.new(position) * CFrame.Angles(math.rad(12), angle, math.rad(18)),
			if index % 2 == 0 then accent else accent:Lerp(Color3.fromRGB(190, 160, 255), 0.42),
			Enum.Material.Neon,
			false
		)
		shard.Transparency = 0.16
		shard.CanQuery = false
	end
end

function ZoneVisualFactory.decorate(parent: Instance, zone: any)
	local center = Vector3.new(zone.Center[1], zone.Center[2], zone.Center[3])
	local size = Vector3.new(zone.Size[1], zone.Size[2], zone.Size[3])
	local accent = rgb(zone.Accent)

	if zone.Id == "backyard" then
		buildBackyard(parent, center, size)
	elseif zone.Id == "downtown" then
		buildDowntown(parent, center, size, accent)
	elseif zone.Id == "industrial" then
		buildIndustrial(parent, center, size, accent)
	elseif zone.Id == "airport" then
		buildAirport(parent, center, size, accent)
	elseif zone.Id == "megacity" then
		buildMegacity(parent, center, size, accent)
	end

	zoneBeaconDetails(parent, center, size, accent)
end

return ZoneVisualFactory
