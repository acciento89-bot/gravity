--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local ZoneGateController = {}

local OPEN_COLOR = Color3.fromRGB(105, 224, 154)

local function accentFromGate(gate: Instance): Color3
	return Color3.new(
		tonumber(gate:GetAttribute("AccentR")) or 1,
		tonumber(gate:GetAttribute("AccentG")) or 1,
		tonumber(gate:GetAttribute("AccentB")) or 1
	)
end

local function requirementText(minGravity: number, minCores: number): string
	if minCores > 0 then
		return ("%s GRAVITY · %d CORE%s"):format(
			math.floor(minGravity),
			math.floor(minCores),
			if minCores == 1 then "" else "S"
		)
	end
	return ("%s GRAVITY"):format(math.floor(minGravity))
end

local function updateGate(gate: Instance)
	if not gate:IsA("Model") then
		return
	end

	local gravity = tonumber(player:GetAttribute("Gravity")) or 0
	local cores = tonumber(player:GetAttribute("GravityCores")) or 0
	local minGravity = math.max(0, tonumber(gate:GetAttribute("MinGravity")) or 0)
	local minCores = math.max(0, tonumber(gate:GetAttribute("MinCores")) or 0)
	local unlocked = gravity >= minGravity and cores >= minCores
	local accent = accentFromGate(gate)

	for _, descendant in gate:GetDescendants() do
		if descendant:IsA("BasePart") then
			local role = descendant:GetAttribute("GateVisualRole")
			if role == "Field" then
				descendant.Transparency = if unlocked then 1 else 0.74
			elseif role == "Glow" then
				descendant.Transparency = if unlocked then 0.58 else 0.04
				descendant.Color = if unlocked then OPEN_COLOR else accent
			end
		elseif descendant:IsA("TextLabel") and descendant.Name == "Requirement" then
			descendant.Text = if unlocked then "OPEN" else requirementText(minGravity, minCores)
			descendant.TextColor3 = if unlocked then OPEN_COLOR else accent
		end
	end
end

local function updateAll()
	for _, gate in CollectionService:GetTagged("GravityZoneGate") do
		updateGate(gate)
	end
end

function ZoneGateController.start()
	CollectionService:GetInstanceAddedSignal("GravityZoneGate"):Connect(function(gate)
		task.defer(updateGate, gate)
	end)
	player:GetAttributeChangedSignal("Gravity"):Connect(updateAll)
	player:GetAttributeChangedSignal("GravityCores"):Connect(updateAll)
	updateAll()
end

return ZoneGateController
