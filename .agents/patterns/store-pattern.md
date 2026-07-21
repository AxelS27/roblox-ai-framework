# Monetization & Store Pattern

---

## 📌 Overview
The **StoreService** manages server-side Developer Product purchases (`ProcessReceipt`) and Gamepass verification.

---

## 🛠️ Implementation Standard (`StoreService.luau`)

```lua
--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local StoreService = {
    Name = "StoreService"
}

local productHandlers: { [number]: (player: Player) -> boolean } = {}

function StoreService:RegisterProduct(productId: number, handler: (player: Player) -> boolean)
    productHandlers[productId] = handler
end

function StoreService:UserOwnsGamepass(player: Player, gamepassId: number): boolean
    local success, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, gamepassId)
    return success and owns
end

function StoreService:Init()
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local handler = productHandlers[receiptInfo.ProductId]
        if handler then
            local success = handler(player)
            if success then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end

        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

return StoreService
```
