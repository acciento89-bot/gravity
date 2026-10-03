--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local AttractionRules = require(shared.rules.AttractionRules)

local AttractionFeedbackController = {}

local UPDATE_INTERVAL = 0.2
local LOCKED_FILL = Color3.fromRGB(214, 92, 78)
local LOCKED_OUTLINE = Color3.fromRGB(255, 196, 112)

local accumulator = 0
local currentCandidate: BasePart? = nil
local currentHighlight: Highlight? = nil
local currentBillboard: BillboardGui? = nil
local currentLabel: TextLabel? = nil

local function clearFeedback()
	if currentHighlight then
		currentHighlight:Destroy()
		currentHighlight = nil
	end
	if currentBillboard then
		currentBillboard:Destroy()
		currentBillboard = nil
	end
	currentLabel = nil
	currentCandidate = nil
end

local function showFeedback(candidate: BasePart, requiredGravity: number)
	if currentCandidate == candidate and currentLabel then
		currentLabel.Text = ("NEED %s GRAVITY"):format(math.floor(requiredGravity))
		return
	end

	clearFeedback()
	currentCandidate = candidate

	local highlight = Instance.new("Highlight")
	highlight.Name = "GravityLockedHighlight"
	highlight.Adornee = candidate.Parent
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = LOCKED_FILL
	highlight.FillTransparency = 0.82
	highlight.OutlineColor = LOCKED_OUTLINE
	highlight.OutlineTransparency = 0.05
	highlight.Parent = candidate
	currentHighlight = highlight

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "GravityLockedRequirement"
	billboard.Adornee = candidate
	billboard.Size = UDim2.fromOffset(190, 38)
	billboard.StudsOffset = Vector3.new(0, candidate.Size.Y / 2 + 1.25, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 70
	billboard.Parent = candidate
	currentBillboard = billboard

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = LOCKED_OUTLINE
	stroke.Thickness = 1.5
	stroke.Transparency = 0.15
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -14, 1, 0)
	label.Position = UDim2.fromOffset(7, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = ("NEED %s GRAVITY"):format(math.floor(requiredGravity))
	label.TextColor3 = Color3.fromRGB(248, 249, 252)
	label.TextSize = 14
	label.TextScaled = false
	label.Parent = frame
	currentLabel = label
end

local function update()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		clearFeedback()
		return
	end

	local gravity = tonumber(player:GetAttribute("Gravity")) or 0
	local previewRadius = AttractionRules.radiusForGravity(gravity) + 3
	local nearest: BasePart? = nil
	local nearestDistance = math.huge
	local nearestRequirement = 0

	for _, candidate in CollectionService:GetTagged("GravityCollectible") do
		if candidate:IsA("BasePart") and candidate:GetAttribute("Active") == true then
			local requiredGravity = tonumber(candidate:GetAttribute("RequiredGravity"))
			if requiredGravity and requiredGravity > gravity then
				local distance = (candidate.Position - root.Position).Magnitude
				if distance <= previewRadius and distance < nearestDistance then
					nearest = candidate
					nearestDistance = distance
					nearestRequirement = requiredGravity
				end
			end
		end
	end

	if nearest then
		showFeedback(nearest, nearestRequirement)
	else
		clearFeedback()
	end
end

function AttractionFeedbackController.start()
	RunService.Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < UPDATE_INTERVAL then
			return
		end
		accumulator = 0
		update()
	end)

	player.CharacterAdded:Connect(function()
		clearFeedback()
	end)
end

return AttractionFeedbackController
