--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local ZoneConfig = require(shared.config.ZoneConfig)
local LocaleText = require(script.Parent.LocaleText)
local WorldLocalizationController = {}
local zoneById: { [string]: any } = {}
for _, zone in ZoneConfig do
	zoneById[zone.Id] = zone
end

local function requirement(minGravity: number, minCores: number): string
	if minCores > 0 then
		return LocaleText.t("zone_requirement_cores", tostring(minGravity), minCores, LocaleText.coreWord(minCores))
	end
	return LocaleText.t("zone_requirement", tostring(minGravity))
end

local function apply()
	local world = Workspace:WaitForChild("Plus1GravityWorld")
	for _, gui in world:GetDescendants() do
		if gui:IsA("BillboardGui") and gui.Name == "ZoneSign" then
			local adornee = gui.Adornee
			local heading = gui:FindFirstChild("Heading", true)
			local subtitle = gui:FindFirstChild("Requirement", true)
			if adornee and heading and heading:IsA("TextLabel") and subtitle and subtitle:IsA("TextLabel") then
				if adornee.Name == "DowntownTease" then
					heading.Text = LocaleText.t("downtown_ahead")
					subtitle.Text = LocaleText.t("downtown_keep_growing")
				else
					local gate = adornee:FindFirstAncestorWhichIsA("Model")
					local zone = if gate and type(gate:GetAttribute("ZoneId")) == "string"
						then zoneById[gate:GetAttribute("ZoneId") :: string]
						else zoneById[adornee.Parent.Name]
					if zone then
						local name = string.upper(LocaleText.zoneName(zone.Id, zone.DisplayName))
						heading.Text = if gate then LocaleText.t("zone_prefix", zone.Order, name) else name
						subtitle.Text = requirement(zone.MinGravity, zone.MinCores)
					end
				end
			end
		end
	end
	local board = world:FindFirstChild("GravityLeaderboardBoard", true)
	local header = board and board:FindFirstChild("Header", true)
	if header and header:IsA("TextLabel") then
		header.Text = LocaleText.t("megacity_top_gravity")
	end
end

function WorldLocalizationController.start()
	task.defer(apply)
end

return WorldLocalizationController
