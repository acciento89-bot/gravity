--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

while ReplicatedStorage:GetAttribute("Plus1GravityServerReady") ~= true do
	ReplicatedStorage:GetAttributeChangedSignal("Plus1GravityServerReady"):Wait()
end

local controllers = script.controllers
local OrbitController = require(controllers.OrbitController)
local HudController = require(controllers.HudController)
local CollapseFxController = require(controllers.CollapseFxController)

OrbitController.start()
HudController.start()
CollapseFxController.start()

print("[+1 Gravity] client initialized")
