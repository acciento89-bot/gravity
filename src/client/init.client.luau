--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

while ReplicatedStorage:GetAttribute("Plus1GravityServerReady") ~= true do
	ReplicatedStorage:GetAttributeChangedSignal("Plus1GravityServerReady"):Wait()
end

local controllers = script.controllers
local OrbitController = require(controllers.OrbitController)
local HudController = require(controllers.HudController)
local CosmeticsController = require(controllers.CosmeticsController)
local DailyController = require(controllers.DailyController)
local LeaderboardController = require(controllers.LeaderboardController)
local ShopController = require(controllers.ShopController)
local GameFeelController = require(controllers.GameFeelController)
local AccessibilityController = require(controllers.AccessibilityController)
local WorldLocalizationController = require(controllers.WorldLocalizationController)
local ControllerNavController = require(controllers.ControllerNavController)
local HapticsController = require(controllers.HapticsController)
local CollapseFxController = require(controllers.CollapseFxController)
local AttractionFeedbackController = require(controllers.AttractionFeedbackController)
local ZoneGateController = require(controllers.ZoneGateController)

OrbitController.start()
HudController.start()
CosmeticsController.start()
DailyController.start()
LeaderboardController.start()
ShopController.start()
GameFeelController.start()
AccessibilityController.start()
WorldLocalizationController.start()
ControllerNavController.start()
HapticsController.start()
CollapseFxController.start()
AttractionFeedbackController.start()
ZoneGateController.start()

print("[+1 Gravity] client initialized")
