--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local CosmeticConfig = require(shared.config.CosmeticConfig)

local GameService = require(script.Parent.GameService)
local ProfileService = require(script.Parent.ProfileService)
local RemotesService = require(script.Parent.RemotesService)

local CosmeticService = {}

local function definitionFor(category: string, name: string): any?
	if category == "Orbit" then
		return CosmeticConfig.OrbitSkins[name]
	elseif category == "Singularity" then
		return CosmeticConfig.SingularitySkins[name]
	end
	return nil
end

local function ownedMap(profile: any, category: string): any?
	if category == "Orbit" then
		return profile.OrbitSkins
	elseif category == "Singularity" then
		return profile.SingularitySkins
	end
	return nil
end

local function equip(profile: any, category: string, name: string)
	if category == "Orbit" then
		profile.EquippedOrbitSkin = name
	else
		profile.EquippedSingularitySkin = name
	end
end

function CosmeticService.start()
	local remote = RemotesService.getFolder():WaitForChild("CosmeticAction") :: RemoteEvent
	remote.OnServerEvent:Connect(function(player: Player, action: any, category: any, name: any)
		if type(action) ~= "string" or type(category) ~= "string" or type(name) ~= "string" then
			return
		end
		local profile = ProfileService.get(player)
		local definition = definitionFor(category, name)
		local owned = profile and ownedMap(profile, category)
		if not profile or not definition or not owned then
			return
		end

		if action == "Buy" then
			if owned[name] == true then
				return
			end
			local price = tonumber(definition.Price) or math.huge
			if profile.Shards < price then
				return
			end
			profile.Shards -= price
			owned[name] = true
			equip(profile, category, name)
		elseif action == "Equip" then
			if owned[name] ~= true then
				return
			end
			equip(profile, category, name)
		else
			return
		end

		ProfileService.markDirty(player)
		GameService.pushState(player, "CosmeticUpdated")
	end)
end

return CosmeticService
