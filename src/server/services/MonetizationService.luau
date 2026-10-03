--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Plus1Gravity")
local MonetizationConfig = require(shared.config.MonetizationConfig)
local ReceiptRules = require(shared.profile.ReceiptRules)

local GameService = require(script.Parent.GameService)
local ProfileService = require(script.Parent.ProfileService)

local MonetizationService = {}

local productsById: { [number]: any } = {}
for _, product in MonetizationConfig.Products do
	if product.ProductId > 0 then
		productsById[product.ProductId] = product
	end
end

local function processReceipt(receipt: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local profile = ProfileService.get(player)
	if not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local product = productsById[receipt.ProductId]
	if not product then
		warn(("[+1 Gravity] unknown developer product %s"):format(tostring(receipt.ProductId)))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local purchaseId = tostring(receipt.PurchaseId or "")
	local granted, reason = ReceiptRules.apply(profile, purchaseId, product, os.time())
	if not granted and reason ~= "AlreadyProcessed" then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if granted then
		ProfileService.markDirty(player)
	end
	if not ProfileService.save(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	GameService.pushState(player, "PurchaseGranted")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function MonetizationService.start()
	MarketplaceService.ProcessReceipt = processReceipt
end

return MonetizationService
