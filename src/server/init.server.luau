--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesService = require(script.services.RemotesService)
local ProfileService = require(script.services.ProfileService)
local WorldService = require(script.services.WorldService)
local GameService = require(script.services.GameService)
local CosmeticService = require(script.services.CosmeticService)
local LeaderboardService = require(script.services.LeaderboardService)
local MonetizationService = require(script.services.MonetizationService)

RemotesService.start()
ProfileService.start()
WorldService.start()
GameService.start()
CosmeticService.start()
LeaderboardService.start()
MonetizationService.start()

ReplicatedStorage:SetAttribute("Plus1GravityServerReady", true)
print("[+1 Gravity] server initialized")
