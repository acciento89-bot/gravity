--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local RemoteDefinitions = require(shared.remotes.RemoteDefinitions)

local RemotesService = {}
local folder: Folder? = nil

function RemotesService.start(): Folder
	local existing = ReplicatedStorage:FindFirstChild("Plus1GravityRemotes")
	if existing then
		existing:Destroy()
	end

	local created = Instance.new("Folder")
	created.Name = "Plus1GravityRemotes"
	created.Parent = ReplicatedStorage

	for _, definition in RemoteDefinitions do
		local remote
		if definition.Kind == "Function" then
			remote = Instance.new("RemoteFunction")
		else
			remote = Instance.new("RemoteEvent")
		end
		remote.Name = definition.Name
		remote.Parent = created
	end

	folder = created
	return created
end

function RemotesService.getFolder(): Folder
	return folder or (ReplicatedStorage:WaitForChild("Plus1GravityRemotes") :: Folder)
end

return RemotesService
