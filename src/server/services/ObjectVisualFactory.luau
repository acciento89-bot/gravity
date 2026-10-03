--!strict

local ObjectVisualFactory = {}

local function rgb(values: { number }): Color3
	return Color3.fromRGB(values[1], values[2], values[3])
end

local function lighten(color: Color3, amount: number): Color3
	return color:Lerp(Color3.new(1, 1, 1), math.clamp(amount, 0, 1))
end

local function darken(color: Color3, amount: number): Color3
	return color:Lerp(Color3.new(0, 0, 0), math.clamp(amount, 0, 1))
end

local function piece(
	model: Model,
	root: BasePart,
	name: string,
	size: Vector3,
	offset: Vector3,
	color: Color3,
	material: Enum.Material?,
	rotation: CFrame?,
	shape: Enum.PartType?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = root.CFrame * CFrame.new(offset) * (rotation or CFrame.identity)
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Shape = shape or Enum.PartType.Block
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item:SetAttribute("BaseCanQuery", false)
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item:SetAttribute("BaseTransparency", 0)
	item.Parent = model
	return item
end

local function bar(
	model: Model,
	root: BasePart,
	name: string,
	a: Vector3,
	b: Vector3,
	thickness: number,
	color: Color3,
	material: Enum.Material?
)
	local worldA = root.CFrame:PointToWorldSpace(a)
	local worldB = root.CFrame:PointToWorldSpace(b)
	local delta = worldB - worldA
	local length = delta.Magnitude
	if length <= 0.001 then
		return
	end
	local item = Instance.new("Part")
	item.Name = name
	item.Size = Vector3.new(thickness, thickness, length)
	item.CFrame = CFrame.lookAt((worldA + worldB) / 2, worldB)
	item.Color = color
	item.Material = material or Enum.Material.Metal
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item:SetAttribute("BaseCanQuery", false)
	item:SetAttribute("BaseTransparency", 0)
	item.Parent = model
end

local function wheel(model: Model, root: BasePart, offset: Vector3, diameter: number, width: number)
	piece(
		model,
		root,
		"Wheel",
		Vector3.new(width, diameter, diameter),
		offset,
		Color3.fromRGB(31, 34, 39),
		Enum.Material.SmoothPlastic,
		nil,
		Enum.PartType.Cylinder
	)
	piece(
		model,
		root,
		"Hub",
		Vector3.new(width + 0.04, diameter * 0.42, diameter * 0.42),
		offset,
		Color3.fromRGB(146, 151, 160),
		Enum.Material.Metal,
		nil,
		Enum.PartType.Cylinder
	)
end

local function vehicleWheels(model: Model, root: BasePart, size: Vector3, diameter: number)
	for side = -1, 1, 2 do
		for axle = -1, 1, 2 do
			wheel(
				model,
				root,
				Vector3.new(side * size.X * 0.47, -size.Y * 0.34, axle * size.Z * 0.31),
				diameter,
				math.max(0.34, size.X * 0.10)
			)
		end
	end
end

local function buildCan(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"CanBody",
		Vector3.new(size.Y * 0.94, size.X * 0.88, size.Z * 0.88),
		Vector3.zero,
		base,
		Enum.Material.Metal,
		CFrame.Angles(0, 0, math.rad(90)),
		Enum.PartType.Cylinder
	)
	for y = -1, 1, 2 do
		piece(
			model,
			root,
			"Rim",
			Vector3.new(0.08, size.X * 0.92, size.Z * 0.92),
			Vector3.new(0, y * size.Y * 0.46, 0),
			lighten(base, 0.35),
			Enum.Material.Metal,
			CFrame.Angles(0, 0, math.rad(90)),
			Enum.PartType.Cylinder
		)
	end
	piece(
		model,
		root,
		"Tab",
		Vector3.new(size.X * 0.24, 0.04, size.Z * 0.34),
		Vector3.new(0, size.Y * 0.49, 0),
		darken(base, 0.45),
		Enum.Material.Metal
	)
end

local function buildToyBlock(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(model, root, "Block", size * 0.88, Vector3.zero, base, Enum.Material.SmoothPlastic)
	for x = -1, 1, 2 do
		for z = -1, 1, 2 do
			piece(
				model,
				root,
				"Stud",
				Vector3.new(size.X * 0.22, size.Y * 0.13, size.Z * 0.22),
				Vector3.new(x * size.X * 0.24, size.Y * 0.48, z * size.Z * 0.24),
				lighten(base, 0.12),
				Enum.Material.SmoothPlastic,
				CFrame.Angles(0, 0, math.rad(90)),
				Enum.PartType.Cylinder
			)
		end
	end
end

local function buildShoe(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Sole",
		Vector3.new(size.X, size.Y * 0.24, size.Z),
		Vector3.new(0, -size.Y * 0.33, 0),
		Color3.fromRGB(228, 229, 232),
		Enum.Material.SmoothPlastic
	)
	piece(
		model,
		root,
		"Upper",
		Vector3.new(size.X * 0.82, size.Y * 0.55, size.Z * 0.72),
		Vector3.new(-size.X * 0.08, 0, 0),
		base,
		Enum.Material.Fabric
	)
	piece(
		model,
		root,
		"Toe",
		Vector3.new(size.X * 0.42, size.Y * 0.38, size.Z * 0.76),
		Vector3.new(size.X * 0.38, -size.Y * 0.07, 0),
		lighten(base, 0.08),
		Enum.Material.Fabric
	)
	piece(
		model,
		root,
		"Heel",
		Vector3.new(size.X * 0.20, size.Y * 0.45, size.Z * 0.72),
		Vector3.new(-size.X * 0.47, 0.02, 0),
		darken(base, 0.25),
		Enum.Material.Fabric
	)
	for x = -1, 1, 2 do
		bar(
			model,
			root,
			"Lace",
			Vector3.new(-size.X * 0.1, size.Y * (0.12 + x * 0.08), -size.Z * 0.25),
			Vector3.new(size.X * 0.17, size.Y * (0.12 + x * 0.08), size.Z * 0.25),
			0.035,
			Color3.fromRGB(238, 238, 238),
			Enum.Material.Fabric
		)
	end
end

local function buildChair(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Seat",
		Vector3.new(size.X * 0.82, 0.18, size.Z * 0.82),
		Vector3.new(0, -size.Y * 0.04, 0),
		base,
		Enum.Material.SmoothPlastic
	)
	piece(
		model,
		root,
		"Back",
		Vector3.new(size.X * 0.82, size.Y * 0.48, 0.16),
		Vector3.new(0, size.Y * 0.30, -size.Z * 0.34),
		base,
		Enum.Material.SmoothPlastic,
		CFrame.Angles(math.rad(-8), 0, 0)
	)
	for x = -1, 1, 2 do
		for z = -1, 1, 2 do
			piece(
				model,
				root,
				"Leg",
				Vector3.new(0.12, size.Y * 0.50, 0.12),
				Vector3.new(x * size.X * 0.32, -size.Y * 0.29, z * size.Z * 0.31),
				darken(base, 0.12),
				Enum.Material.Metal
			)
		end
	end
end

local function buildBarbecue(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Bowl",
		Vector3.new(size.X * 0.75, size.Y * 0.42, size.Z * 0.75),
		Vector3.new(0, size.Y * 0.10, 0),
		base,
		Enum.Material.Metal,
		nil,
		Enum.PartType.Ball
	)
	piece(
		model,
		root,
		"Lid",
		Vector3.new(size.X * 0.72, size.Y * 0.22, size.Z * 0.72),
		Vector3.new(0, size.Y * 0.30, 0),
		darken(base, 0.10),
		Enum.Material.Metal,
		nil,
		Enum.PartType.Ball
	)
	piece(
		model,
		root,
		"Handle",
		Vector3.new(size.X * 0.30, 0.08, 0.10),
		Vector3.new(0, size.Y * 0.45, 0),
		Color3.fromRGB(190, 194, 201),
		Enum.Material.Metal
	)
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"Leg",
			Vector3.new(0.11, size.Y * 0.52, 0.11),
			Vector3.new(x * size.X * 0.22, -size.Y * 0.28, 0),
			Color3.fromRGB(145, 149, 156),
			Enum.Material.Metal,
			CFrame.Angles(0, 0, math.rad(x * 8))
		)
	end
	wheel(model, root, Vector3.new(size.X * 0.34, -size.Y * 0.43, 0), size.X * 0.20, 0.12)
end

local function buildCone(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Base",
		Vector3.new(size.X, size.Y * 0.12, size.Z),
		Vector3.new(0, -size.Y * 0.44, 0),
		darken(base, 0.18),
		Enum.Material.SmoothPlastic
	)
	for tier = 0, 4 do
		local t = tier / 4
		local diameter = size.X * (0.62 - t * 0.38)
		local height = size.Y * 0.16
		local color = if tier == 2 then Color3.fromRGB(245, 245, 238) else base
		piece(
			model,
			root,
			"ConeTier",
			Vector3.new(height, diameter, diameter),
			Vector3.new(0, -size.Y * 0.31 + tier * size.Y * 0.16, 0),
			color,
			Enum.Material.SmoothPlastic,
			CFrame.Angles(0, 0, math.rad(90)),
			Enum.PartType.Cylinder
		)
	end
end

local function buildMailbox(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Post",
		Vector3.new(size.X * 0.16, size.Y * 0.72, size.Z * 0.16),
		Vector3.new(0, -size.Y * 0.18, 0),
		darken(base, 0.18),
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Box",
		Vector3.new(size.X * 0.88, size.Y * 0.34, size.Z * 0.88),
		Vector3.new(0, size.Y * 0.25, 0),
		base,
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Roof",
		Vector3.new(size.X * 0.88, size.Y * 0.30, size.Z * 0.88),
		Vector3.new(0, size.Y * 0.39, 0),
		lighten(base, 0.08),
		Enum.Material.Metal,
		CFrame.Angles(0, 0, math.rad(90)),
		Enum.PartType.Cylinder
	)
	piece(
		model,
		root,
		"FlagPost",
		Vector3.new(0.07, size.Y * 0.34, 0.07),
		Vector3.new(size.X * 0.52, size.Y * 0.31, 0),
		Color3.fromRGB(220, 61, 61),
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Flag",
		Vector3.new(0.08, size.Y * 0.14, size.Z * 0.32),
		Vector3.new(size.X * 0.52, size.Y * 0.46, -size.Z * 0.12),
		Color3.fromRGB(220, 61, 61),
		Enum.Material.Metal
	)
end

local function buildBicycle(model: Model, root: BasePart, size: Vector3, base: Color3)
	for z = -1, 1, 2 do
		wheel(model, root, Vector3.new(0, -size.Y * 0.16, z * size.Z * 0.38), size.Y * 0.66, 0.10)
	end
	local frame = lighten(base, 0.1)
	bar(
		model,
		root,
		"Frame",
		Vector3.new(0, -size.Y * 0.08, -size.Z * 0.30),
		Vector3.new(0, size.Y * 0.20, 0),
		0.09,
		frame,
		Enum.Material.Metal
	)
	bar(
		model,
		root,
		"Frame",
		Vector3.new(0, size.Y * 0.20, 0),
		Vector3.new(0, -size.Y * 0.08, size.Z * 0.30),
		0.09,
		frame,
		Enum.Material.Metal
	)
	bar(
		model,
		root,
		"Frame",
		Vector3.new(0, -size.Y * 0.08, -size.Z * 0.30),
		Vector3.new(0, -size.Y * 0.08, size.Z * 0.30),
		0.09,
		frame,
		Enum.Material.Metal
	)
	bar(
		model,
		root,
		"Fork",
		Vector3.new(0, -size.Y * 0.12, size.Z * 0.38),
		Vector3.new(0, size.Y * 0.34, size.Z * 0.28),
		0.07,
		darken(frame, 0.1),
		Enum.Material.Metal
	)
	bar(
		model,
		root,
		"Handlebar",
		Vector3.new(-size.X * 0.22, size.Y * 0.36, size.Z * 0.28),
		Vector3.new(size.X * 0.22, size.Y * 0.36, size.Z * 0.28),
		0.07,
		Color3.fromRGB(70, 74, 82),
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Seat",
		Vector3.new(size.X * 0.40, 0.12, size.Z * 0.18),
		Vector3.new(0, size.Y * 0.32, -size.Z * 0.04),
		Color3.fromRGB(45, 47, 52),
		Enum.Material.SmoothPlastic
	)
end

local function buildDumpster(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Body",
		Vector3.new(size.X * 0.92, size.Y * 0.72, size.Z * 0.88),
		Vector3.new(0, -size.Y * 0.08, 0),
		base,
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Lid",
		Vector3.new(size.X * 0.96, 0.16, size.Z * 0.92),
		Vector3.new(0, size.Y * 0.34, 0),
		darken(base, 0.15),
		Enum.Material.Metal,
		CFrame.Angles(math.rad(-5), 0, 0)
	)
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"Rib",
			Vector3.new(0.10, size.Y * 0.56, size.Z * 0.94),
			Vector3.new(x * size.X * 0.32, -size.Y * 0.08, 0),
			lighten(base, 0.12),
			Enum.Material.Metal
		)
	end
	for x = -1, 1, 2 do
		wheel(model, root, Vector3.new(x * size.X * 0.36, -size.Y * 0.43, size.Z * 0.31), size.Y * 0.16, 0.14)
	end
end

local function buildCar(model: Model, root: BasePart, size: Vector3, base: Color3, bus: boolean)
	local bodyHeight = if bus then size.Y * 0.64 else size.Y * 0.42
	piece(
		model,
		root,
		"Body",
		Vector3.new(size.X * 0.94, bodyHeight, size.Z * 0.90),
		Vector3.new(0, -size.Y * 0.06, 0),
		base,
		Enum.Material.SmoothPlastic
	)
	local cabinSize = if bus
		then Vector3.new(size.X * 0.88, size.Y * 0.42, size.Z * 0.78)
		else Vector3.new(size.X * 0.78, size.Y * 0.38, size.Z * 0.46)
	piece(
		model,
		root,
		"Cabin",
		cabinSize,
		Vector3.new(0, size.Y * 0.27, -size.Z * 0.05),
		lighten(base, 0.08),
		Enum.Material.SmoothPlastic
	)
	local glass = Color3.fromRGB(82, 117, 142)
	if bus then
		for z = -3, 3 do
			if z ~= 0 then
				piece(
					model,
					root,
					"Window",
					Vector3.new(size.X * 0.96, size.Y * 0.20, size.Z * 0.075),
					Vector3.new(0, size.Y * 0.29, z * size.Z * 0.10),
					glass,
					Enum.Material.Glass
				)
			end
		end
	else
		piece(
			model,
			root,
			"Windshield",
			Vector3.new(size.X * 0.72, size.Y * 0.23, 0.08),
			Vector3.new(0, size.Y * 0.29, size.Z * 0.24),
			glass,
			Enum.Material.Glass,
			CFrame.Angles(math.rad(-12), 0, 0)
		)
		piece(
			model,
			root,
			"RearGlass",
			Vector3.new(size.X * 0.66, size.Y * 0.20, 0.08),
			Vector3.new(0, size.Y * 0.27, -size.Z * 0.28),
			glass,
			Enum.Material.Glass,
			CFrame.Angles(math.rad(10), 0, 0)
		)
	end
	vehicleWheels(model, root, size, math.max(0.72, size.Y * 0.42))
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"Headlight",
			Vector3.new(size.X * 0.18, size.Y * 0.12, 0.08),
			Vector3.new(x * size.X * 0.30, -size.Y * 0.07, size.Z * 0.46),
			Color3.fromRGB(255, 238, 166),
			Enum.Material.Neon
		)
	end
end

local function buildPallet(model: Model, root: BasePart, size: Vector3, base: Color3)
	for z = -2, 2 do
		piece(
			model,
			root,
			"Slat",
			Vector3.new(size.X * 0.92, size.Y * 0.22, size.Z * 0.14),
			Vector3.new(0, size.Y * 0.22, z * size.Z * 0.17),
			lighten(base, z * 0.01 + 0.04),
			Enum.Material.WoodPlanks
		)
	end
	for x = -1, 1 do
		piece(
			model,
			root,
			"Runner",
			Vector3.new(size.X * 0.18, size.Y * 0.30, size.Z * 0.88),
			Vector3.new(x * size.X * 0.32, -size.Y * 0.18, 0),
			darken(base, 0.12),
			Enum.Material.WoodPlanks
		)
	end
end

local function buildBarrel(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Drum",
		Vector3.new(size.Y * 0.92, size.X * 0.88, size.Z * 0.88),
		Vector3.zero,
		base,
		Enum.Material.Metal,
		CFrame.Angles(0, 0, math.rad(90)),
		Enum.PartType.Cylinder
	)
	for y = -1, 1, 2 do
		piece(
			model,
			root,
			"Ring",
			Vector3.new(0.11, size.X * 0.96, size.Z * 0.96),
			Vector3.new(0, y * size.Y * 0.30, 0),
			lighten(base, 0.35),
			Enum.Material.Metal,
			CFrame.Angles(0, 0, math.rad(90)),
			Enum.PartType.Cylinder
		)
	end
end

local function buildToolChest(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Cabinet",
		Vector3.new(size.X * 0.92, size.Y * 0.84, size.Z * 0.86),
		Vector3.new(0, 0, 0),
		base,
		Enum.Material.Metal
	)
	for row = -2, 2 do
		piece(
			model,
			root,
			"DrawerLine",
			Vector3.new(size.X * 0.82, 0.045, size.Z * 0.02),
			Vector3.new(0, row * size.Y * 0.12, size.Z * 0.44),
			darken(base, 0.32),
			Enum.Material.Metal
		)
		piece(
			model,
			root,
			"Handle",
			Vector3.new(size.X * 0.34, 0.045, 0.08),
			Vector3.new(0, row * size.Y * 0.12 + 0.04, size.Z * 0.49),
			Color3.fromRGB(210, 214, 220),
			Enum.Material.Metal
		)
	end
	for x = -1, 1, 2 do
		wheel(model, root, Vector3.new(x * size.X * 0.32, -size.Y * 0.45, size.Z * 0.28), size.Y * 0.16, 0.12)
	end
end

local function buildForklift(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Chassis",
		Vector3.new(size.X * 0.82, size.Y * 0.30, size.Z * 0.58),
		Vector3.new(0, -size.Y * 0.26, -size.Z * 0.08),
		base,
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Counterweight",
		Vector3.new(size.X * 0.80, size.Y * 0.52, size.Z * 0.24),
		Vector3.new(0, 0, -size.Z * 0.31),
		base,
		Enum.Material.Metal
	)
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"CabPost",
			Vector3.new(0.14, size.Y * 0.58, 0.14),
			Vector3.new(x * size.X * 0.31, size.Y * 0.16, -size.Z * 0.04),
			darken(base, 0.2),
			Enum.Material.Metal
		)
		piece(
			model,
			root,
			"Mast",
			Vector3.new(0.15, size.Y * 0.88, 0.15),
			Vector3.new(x * size.X * 0.26, size.Y * 0.05, size.Z * 0.31),
			Color3.fromRGB(57, 61, 68),
			Enum.Material.Metal
		)
		piece(
			model,
			root,
			"Fork",
			Vector3.new(0.16, 0.12, size.Z * 0.50),
			Vector3.new(x * size.X * 0.26, -size.Y * 0.42, size.Z * 0.47),
			Color3.fromRGB(70, 74, 82),
			Enum.Material.Metal
		)
	end
	piece(
		model,
		root,
		"Roof",
		Vector3.new(size.X * 0.72, 0.14, size.Z * 0.42),
		Vector3.new(0, size.Y * 0.46, -size.Z * 0.05),
		darken(base, 0.15),
		Enum.Material.Metal
	)
	vehicleWheels(model, root, size, size.Y * 0.28)
end

local function buildContainer(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"ContainerBody",
		Vector3.new(size.X * 0.94, size.Y * 0.94, size.Z * 0.96),
		Vector3.zero,
		base,
		Enum.Material.Metal
	)
	for z = -5, 5 do
		piece(
			model,
			root,
			"Rib",
			Vector3.new(size.X * 0.98, size.Y * 0.96, 0.11),
			Vector3.new(0, 0, z * size.Z * 0.075),
			lighten(base, 0.10),
			Enum.Material.Metal
		)
	end
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"DoorFrame",
			Vector3.new(0.10, size.Y * 0.86, 0.11),
			Vector3.new(x * size.X * 0.23, 0, size.Z * 0.49),
			darken(base, 0.28),
			Enum.Material.Metal
		)
		piece(
			model,
			root,
			"Latch",
			Vector3.new(0.07, size.Y * 0.72, 0.07),
			Vector3.new(x * size.X * 0.13, 0, size.Z * 0.51),
			Color3.fromRGB(196, 199, 204),
			Enum.Material.Metal
		)
	end
end

local function buildLuggageCart(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Platform",
		Vector3.new(size.X * 0.92, size.Y * 0.22, size.Z * 0.90),
		Vector3.new(0, -size.Y * 0.24, 0),
		base,
		Enum.Material.Metal
	)
	for x = -1, 1, 2 do
		bar(
			model,
			root,
			"Rail",
			Vector3.new(x * size.X * 0.42, -size.Y * 0.18, -size.Z * 0.40),
			Vector3.new(x * size.X * 0.42, size.Y * 0.38, -size.Z * 0.40),
			0.10,
			darken(base, 0.2),
			Enum.Material.Metal
		)
		bar(
			model,
			root,
			"Rail",
			Vector3.new(x * size.X * 0.42, size.Y * 0.38, -size.Z * 0.40),
			Vector3.new(x * size.X * 0.42, size.Y * 0.38, size.Z * 0.40),
			0.10,
			darken(base, 0.2),
			Enum.Material.Metal
		)
	end
	vehicleWheels(model, root, size, size.Y * 0.30)
end

local function buildServiceCart(model: Model, root: BasePart, size: Vector3, base: Color3)
	buildCar(model, root, size, base, false)
	piece(
		model,
		root,
		"CargoBox",
		Vector3.new(size.X * 0.86, size.Y * 0.54, size.Z * 0.44),
		Vector3.new(0, size.Y * 0.10, -size.Z * 0.25),
		lighten(base, 0.12),
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Beacon",
		Vector3.new(0.12, 0.24, 0.12),
		Vector3.new(0, size.Y * 0.50, size.Z * 0.22),
		Color3.fromRGB(255, 181, 60),
		Enum.Material.Neon,
		nil,
		Enum.PartType.Ball
	)
end

local function buildJetStair(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Chassis",
		Vector3.new(size.X * 0.82, size.Y * 0.18, size.Z * 0.70),
		Vector3.new(0, -size.Y * 0.36, -size.Z * 0.05),
		darken(base, 0.18),
		Enum.Material.Metal
	)
	for step = 0, 6 do
		local t = step / 6
		piece(
			model,
			root,
			"Step",
			Vector3.new(size.X * 0.64, 0.15, size.Z * 0.10),
			Vector3.new(0, -size.Y * 0.24 + t * size.Y * 0.62, -size.Z * 0.28 + t * size.Z * 0.48),
			base,
			Enum.Material.Metal
		)
	end
	for x = -1, 1, 2 do
		bar(
			model,
			root,
			"Rail",
			Vector3.new(x * size.X * 0.36, -size.Y * 0.16, -size.Z * 0.30),
			Vector3.new(x * size.X * 0.36, size.Y * 0.48, size.Z * 0.22),
			0.09,
			Color3.fromRGB(201, 205, 211),
			Enum.Material.Metal
		)
	end
	vehicleWheels(model, root, size, size.Y * 0.16)
end

local function buildJetEngine(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Nacelle",
		Vector3.new(size.Z * 0.88, size.X * 0.92, size.Y * 0.92),
		Vector3.zero,
		base,
		Enum.Material.Metal,
		nil,
		Enum.PartType.Cylinder
	)
	piece(
		model,
		root,
		"Intake",
		Vector3.new(size.Z * 0.16, size.X, size.Y),
		Vector3.new(size.X * 0.43, 0, 0),
		lighten(base, 0.38),
		Enum.Material.Metal,
		nil,
		Enum.PartType.Cylinder
	)
	piece(
		model,
		root,
		"Core",
		Vector3.new(size.Z * 0.14, size.X * 0.25, size.Y * 0.25),
		Vector3.new(size.X * 0.49, 0, 0),
		Color3.fromRGB(43, 47, 55),
		Enum.Material.Metal,
		nil,
		Enum.PartType.Cylinder
	)
	for blade = 0, 7 do
		local angle = blade * math.pi / 4
		local y = math.cos(angle) * size.Y * 0.25
		local z = math.sin(angle) * size.Z * 0.25
		bar(
			model,
			root,
			"FanBlade",
			Vector3.new(size.X * 0.50, 0, 0),
			Vector3.new(size.X * 0.50, y, z),
			0.09,
			Color3.fromRGB(125, 132, 143),
			Enum.Material.Metal
		)
	end
end

local function buildTree(model: Model, root: BasePart, size: Vector3)
	local trunk = Color3.fromRGB(103, 73, 46)
	piece(
		model,
		root,
		"Planter",
		Vector3.new(size.X * 0.58, size.Y * 0.12, size.Z * 0.58),
		Vector3.new(0, -size.Y * 0.43, 0),
		Color3.fromRGB(110, 114, 120),
		Enum.Material.Concrete
	)
	piece(
		model,
		root,
		"Trunk",
		Vector3.new(size.Y * 0.52, size.X * 0.18, size.Z * 0.18),
		Vector3.new(0, -size.Y * 0.08, 0),
		trunk,
		Enum.Material.Wood,
		CFrame.Angles(0, 0, math.rad(90)),
		Enum.PartType.Cylinder
	)
	local green = Color3.fromRGB(68, 151, 88)
	for _, offset in
		{
			Vector3.new(0, size.Y * 0.29, 0),
			Vector3.new(size.X * 0.22, size.Y * 0.22, 0),
			Vector3.new(-size.X * 0.20, size.Y * 0.20, size.Z * 0.10),
			Vector3.new(0, size.Y * 0.18, -size.Z * 0.20),
		}
	do
		piece(
			model,
			root,
			"Crown",
			Vector3.new(size.X * 0.54, size.X * 0.54, size.Z * 0.54),
			offset,
			green,
			Enum.Material.Grass,
			nil,
			Enum.PartType.Ball
		)
	end
end

local function buildBillboard(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Panel",
		Vector3.new(size.X * 0.94, size.Y * 0.72, size.Z * 0.28),
		Vector3.new(0, size.Y * 0.10, 0),
		base,
		Enum.Material.Metal
	)
	piece(
		model,
		root,
		"Face",
		Vector3.new(size.X * 0.86, size.Y * 0.62, 0.08),
		Vector3.new(0, size.Y * 0.10, size.Z * 0.18),
		Color3.fromRGB(34, 40, 55),
		Enum.Material.SmoothPlastic
	)
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"Post",
			Vector3.new(size.X * 0.06, size.Y * 0.48, size.Z * 0.10),
			Vector3.new(x * size.X * 0.28, -size.Y * 0.32, 0),
			darken(base, 0.28),
			Enum.Material.Metal
		)
	end
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"NeonEdge",
			Vector3.new(0.10, size.Y * 0.64, 0.10),
			Vector3.new(x * size.X * 0.44, size.Y * 0.10, size.Z * 0.21),
			Color3.fromRGB(255, 216, 104),
			Enum.Material.Neon
		)
	end
end

local function buildCraneSection(model: Model, root: BasePart, size: Vector3, base: Color3)
	local x = size.X * 0.34
	local y = size.Y * 0.34
	local z = size.Z * 0.46
	for sx = -1, 1, 2 do
		for sy = -1, 1, 2 do
			bar(
				model,
				root,
				"LongRail",
				Vector3.new(sx * x, sy * y, -z),
				Vector3.new(sx * x, sy * y, z),
				0.16,
				base,
				Enum.Material.Metal
			)
		end
	end
	for segment = -4, 3 do
		local z0 = segment * size.Z * 0.10
		local z1 = z0 + size.Z * 0.10
		bar(
			model,
			root,
			"Brace",
			Vector3.new(-x, -y, z0),
			Vector3.new(x, y, z1),
			0.10,
			darken(base, 0.10),
			Enum.Material.Metal
		)
		bar(
			model,
			root,
			"Brace",
			Vector3.new(x, -y, z0),
			Vector3.new(-x, y, z1),
			0.10,
			darken(base, 0.10),
			Enum.Material.Metal
		)
	end
end

local function buildBuildingChunk(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(
		model,
		root,
		"Concrete",
		Vector3.new(size.X * 0.92, size.Y * 0.92, size.Z * 0.92),
		Vector3.zero,
		base,
		Enum.Material.Concrete
	)
	local glass = Color3.fromRGB(76, 118, 145)
	for floor = -1, 1 do
		for side = -1, 1, 2 do
			piece(
				model,
				root,
				"Window",
				Vector3.new(size.X * 0.28, size.Y * 0.18, 0.08),
				Vector3.new(side * size.X * 0.22, floor * size.Y * 0.27, size.Z * 0.47),
				glass,
				Enum.Material.Glass
			)
		end
	end
	for x = -1, 1, 2 do
		piece(
			model,
			root,
			"Rebar",
			Vector3.new(0.12, size.Y * 0.34, 0.12),
			Vector3.new(x * size.X * 0.32, size.Y * 0.58, -size.Z * 0.26),
			Color3.fromRGB(120, 73, 58),
			Enum.Material.Metal,
			CFrame.Angles(0, 0, math.rad(x * 8))
		)
	end
end

local function buildGeneric(model: Model, root: BasePart, size: Vector3, base: Color3)
	piece(model, root, "Body", size * 0.88, Vector3.zero, base, Enum.Material.SmoothPlastic)
	piece(
		model,
		root,
		"Accent",
		Vector3.new(size.X * 0.92, math.max(0.08, size.Y * 0.08), size.Z * 0.92),
		Vector3.new(0, size.Y * 0.28, 0),
		lighten(base, 0.24),
		Enum.Material.Metal
	)
end

function ObjectVisualFactory.decorate(model: Model, root: BasePart, definition: any)
	local size = root.Size
	local base = rgb(definition.Color)
	local id = definition.Id

	if id == "can" then
		buildCan(model, root, size, base)
	elseif id == "toy_block" then
		buildToyBlock(model, root, size, base)
	elseif id == "shoe" then
		buildShoe(model, root, size, base)
	elseif id == "garden_chair" then
		buildChair(model, root, size, base)
	elseif id == "barbecue" then
		buildBarbecue(model, root, size, base)
	elseif id == "traffic_cone" then
		buildCone(model, root, size, base)
	elseif id == "mailbox" then
		buildMailbox(model, root, size, base)
	elseif id == "bicycle" then
		buildBicycle(model, root, size, base)
	elseif id == "dumpster" then
		buildDumpster(model, root, size, base)
	elseif id == "compact_car" then
		buildCar(model, root, size, base, false)
	elseif id == "pallet" then
		buildPallet(model, root, size, base)
	elseif id == "barrel" then
		buildBarrel(model, root, size, base)
	elseif id == "tool_chest" then
		buildToolChest(model, root, size, base)
	elseif id == "forklift" then
		buildForklift(model, root, size, base)
	elseif id == "container" then
		buildContainer(model, root, size, base)
	elseif id == "luggage_cart" then
		buildLuggageCart(model, root, size, base)
	elseif id == "service_cart" then
		buildServiceCart(model, root, size, base)
	elseif id == "airport_bus" or id == "city_bus" then
		buildCar(model, root, size, base, true)
	elseif id == "jet_stair" then
		buildJetStair(model, root, size, base)
	elseif id == "jet_engine" then
		buildJetEngine(model, root, size, base)
	elseif id == "street_tree" then
		buildTree(model, root, size)
	elseif id == "billboard" then
		buildBillboard(model, root, size, base)
	elseif id == "crane_section" then
		buildCraneSection(model, root, size, base)
	elseif id == "building_chunk" then
		buildBuildingChunk(model, root, size, base)
	else
		buildGeneric(model, root, size, base)
	end
end

return ObjectVisualFactory
