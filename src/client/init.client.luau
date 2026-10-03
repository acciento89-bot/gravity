--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

while ReplicatedStorage:GetAttribute("Plus1GravityServerReady") ~= true do
	ReplicatedStorage:GetAttributeChangedSignal("Plus1GravityServerReady"):Wait()
end

local controllers = script.controllers
local OrbitController = require(controllers.OrbitController)
local HudController = require(controllers.HudController)
local CollapseFxController = require(controllers.CollapseFxController)
local AttractionFeedbackController = require(controllers.AttractionFeedbackController)
local ZoneGateController = require(controllers.ZoneGateController)

OrbitController.start()
HudController.start()
CollapseFxController.start()
AttractionFeedbackController.start()
ZoneGateController.start()

print("[+1 Gravity] client initialized")
