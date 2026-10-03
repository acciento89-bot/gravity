local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local function fail(message)
	error("[STUDIO-SMOKE] FAIL: " .. message, 0)
end

local function expect(condition, message)
	if not condition then
		fail(message)
	end
end

local function child(parent, name)
	local value = parent:FindFirstChild(name)
	expect(value ~= nil, ("%s missing under %s"):format(name, parent:GetFullName()))
	return value
end

local shared = child(ReplicatedStorage, "Plus1Gravity")
local server = child(ServerScriptService, "Plus1GravityServer")
local services = child(server, "services")
local worldServiceModule = child(services, "WorldService")

local ObjectConfig = require(child(child(shared, "config"), "ObjectConfig"))
local ZoneConfig = require(child(child(shared, "config"), "ZoneConfig"))
local WorldService = require(worldServiceModule)

expect(#ObjectConfig == 25, "ObjectConfig must contain exactly 25 object classes")
expect(#ZoneConfig == 5, "ZoneConfig must contain exactly five zones")

WorldService.start()

local world = child(Workspace, "Plus1GravityWorld")
local expectedZones = {
	backyard = true,
	downtown = true,
	industrial = true,
	airport = true,
	megacity = true,
}

local zoneCount = 0
for zoneId in expectedZones do
	local zone = child(world, zoneId)
	expect(zone:IsA("Folder"), zoneId .. " must be a Folder")
	zoneCount += 1
end
expect(zoneCount == 5, "five expected zone folders")

expect(child(world, "GravitySpawn"):IsA("SpawnLocation"), "GravitySpawn must be a SpawnLocation")
expect(child(world, "GravityBoulevard"):IsA("BasePart"), "GravityBoulevard must exist")

local collectibles = CollectionService:GetTagged("GravityCollectible")
expect(#collectibles == 150, ("expected 150 collectible roots, got %d"):format(#collectibles))

local counts = {}
for _, root in collectibles do
	expect(root:IsA("BasePart"), "collectible tag must only be on BaseParts")
	expect(root:GetAttribute("Active") == true, root:GetFullName() .. " must start Active")
	expect(root.Transparency == 1, root:GetFullName() .. " hitbox root must stay invisible")
	expect(root.CanQuery == false, root:GetFullName() .. " hitbox root must not be queryable")
	local objectId = root:GetAttribute("ObjectId")
	expect(type(objectId) == "string" and objectId ~= "", root:GetFullName() .. " missing ObjectId")
	counts[objectId] = (counts[objectId] or 0) + 1

	local model = root.Parent
	expect(model and model:IsA("Model"), root:GetFullName() .. " must be parented to an object Model")
	local visualPartCount = 0
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant ~= root then
			visualPartCount += 1
		end
	end
	expect(visualPartCount >= 1, model:GetFullName() .. " must contain visible procedural geometry")
end

local uniqueObjectIds = 0
for _, definition in ObjectConfig do
	uniqueObjectIds += 1
	expect(
		counts[definition.Id] == 6,
		("%s expected 6 copies, got %s"):format(definition.Id, tostring(counts[definition.Id]))
	)
	counts[definition.Id] = nil
end
expect(uniqueObjectIds == 25, "25 configured object IDs")
expect(next(counts) == nil, "world contains unknown collectible ObjectId")

local gates = CollectionService:GetTagged("GravityZoneGate")
expect(#gates == 4, ("expected four progression gates, got %d"):format(#gates))
local expectedGates = {
	downtown = true,
	industrial = true,
	airport = true,
	megacity = true,
}
for _, gate in gates do
	expect(gate:IsA("Model"), "zone gate must be a Model")
	local zoneId = gate:GetAttribute("ZoneId")
	expect(expectedGates[zoneId] == true, "unexpected or duplicate gate: " .. tostring(zoneId))
	expectedGates[zoneId] = nil
	expect(gate:FindFirstChild("GateField") ~= nil, tostring(zoneId) .. " missing GateField")
	expect(gate:FindFirstChild("GateBeam") ~= nil, tostring(zoneId) .. " missing GateBeam")
	local glowCount = 0
	for _, item in gate:GetChildren() do
		if item.Name == "GateGlow" then
			glowCount += 1
		end
	end
	expect(glowCount == 2, tostring(zoneId) .. " must have two GateGlow parts")
end
expect(next(expectedGates) == nil, "one or more expected gates are missing")

local landmarkChecks = {
	backyard = { "BackyardHouse", "Lawn" },
	downtown = { "DowntownTower", "Crosswalk" },
	industrial = { "Warehouse", "StorageTank", "OverheadPipe" },
	airport = { "Terminal", "ControlTower", "RunwayMark" },
	megacity = { "MegacityTower", "SpireBase", "SkyRail" },
}
for zoneId, names in landmarkChecks do
	local zone = child(world, zoneId)
	for _, name in names do
		expect(zone:FindFirstChild(name) ~= nil, ("%s missing landmark %s"):format(zoneId, name))
	end
end

local sample = collectibles[1]
expect(sample ~= nil, "sample collectible missing")
local sampleModel = sample.Parent
local visiblePart = nil
for _, descendant in sampleModel:GetDescendants() do
	if descendant:IsA("BasePart") and descendant ~= sample and descendant.Transparency < 1 then
		visiblePart = descendant
		break
	end
end
expect(visiblePart ~= nil, "sample must have at least one visible visual part")

local originalRespawn = sample:GetAttribute("Respawn")
sample:SetAttribute("Respawn", 0.25)
expect(WorldService.collect(sample) == true, "first collection claim must succeed")
expect(sample:GetAttribute("Active") == false, "claimed root must become inactive")
expect(WorldService.collect(sample) == false, "second collection claim in same lifecycle must fail")
expect(visiblePart.Transparency == 1, "claimed visuals must hide")

task.wait(0.40)
expect(sample:GetAttribute("Active") == true, "sample must reactivate after respawn delay")
expect(visiblePart.Transparency < 1, "sample visuals must restore after respawn")
sample:SetAttribute("Respawn", originalRespawn)

print(
	("[STUDIO-SMOKE] PASS zones=%d collectibles=%d objectClasses=%d gates=%d"):format(
		#ZoneConfig,
		#collectibles,
		#ObjectConfig,
		#gates
	)
)
