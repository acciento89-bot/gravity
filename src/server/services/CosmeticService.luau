--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local CosmeticConfig = require(shared.config.CosmeticConfig)
local SecurityRules = require(shared.rules.SecurityRules)

local GameService = require(script.Parent.GameService)
local ProfileService = require(script.Parent.ProfileService)
local RemotesService = require(script.Parent.RemotesService)

local CosmeticService = {}
local actionCooldown: { [Player]: number } = {}

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
		if not SecurityRules.validCosmeticPayload(action, category, name) then
			return
		end
		local now = os.clock()
		local previous = actionCooldown[player]
		if not SecurityRules.allow(now, previous, 0.30) then
			return
		end
		actionCooldown[player] = now

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
	Players.PlayerRemoving:Connect(function(player)
		actionCooldown[player] = nil
	end)
end

return CosmeticService
