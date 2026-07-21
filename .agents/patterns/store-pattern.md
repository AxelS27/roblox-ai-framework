# Monetization & Store Pattern

> **Standards for Server-Side Transactions, Gamepass Verification, and Premium Functional Shop Interfaces**

---

## 📌 Overview
The **StoreService** handles Developer Product receipts (`ProcessReceipt`) and Gamepass ownership checks, while the client-side **StoreController** manages the Shop UI. This pattern enforces that all shop interfaces must be visually premium, interactive, and **100% functional** (zero fake mockups).

---

## 📐 1. Premium Shop UI & 3D Viewport Preview Standards
Avoid plain, static grid lists that simply show purchase buttons. Premium Roblox shops must feature interactive selection and 3D preview mechanics:

```
┌────────────────────────────────────────────────────────────────────────┐
│  🛒 COSMETIC & EMOTE SHOP                            [X] Close Button  │
├──────────────────────────────┬─────────────────────────────────────────┤
│                              │  Category: [ Gamepasses ] [ Skins ]     │
│       ┌──────────────┐       ├─────────────────────────────────────────┤
│       │              │       │  ┌──────────────┐  ┌──────────────┐     │
│       │   Viewport   │       │  │ Item Card 1  │  │ Item Card 2  │     │
│       │    Frame     │       │  │  (Selected)  │  │              │     │
│       │ (3D Rotating │       │  └──────────────┘  └──────────────┘     │
│       │    Model)    │       │                                         │
│       │              │       │  ┌──────────────┐  ┌──────────────┐     │
│       └──────────────┘       │  │ Item Card 3  │  │ Item Card 4  │     │
│   "Mythical Skin Pack"       │  │              │  │              │     │
│                              │  └──────────────┘  └──────────────┘     │
│   [   BUY FOR 499 R$   ]     │                                         │
└──────────────────────────────┴─────────────────────────────────────────┘
```

1. **Split-Panel Layout**:
   * **Left Panel (Preview)**: A dedicated `ViewportFrame` that displays a rotating 3D model of the selected Rig, Skin, or Emote. Clicking different items in the grid must dynamically swap the model inside the Viewport.
   * **Right Panel (Catalog)**: A scrolling grid containing category tabs (e.g., Gamepasses, Skins, Consumables) and item cards.
2. **Selected Visual State**:
   * Hovering or selecting an item card must trigger a visual border highlight (`UIStroke`) and scale bounce using `UIAnimate` to make the menu feel alive.
3. **Interactive Actions**:
   * Hovering the purchase button must show price changes or a hover glow, and clicking it must initiate a real Marketplace prompt.

---

## 🔒 2. Strict End-to-End Functional Invariant
**Every single item listed in a shop must possess a complete, working backend implementation. Placeholder code is forbidden.**
* **Gamepasses**: Clicking "Buy" must invoke `MarketplaceService:PromptGamePassPurchase`. The server must monitor `PromptGamePassPurchaseFinished` and immediately grant the in-game perks (e.g. applying VIP tag, enabling double DNA).
* **Developer Products**: Clicking "Buy" must invoke `MarketplaceService:PromptProductPurchase`. The server must process the product transaction via `ProcessReceipt`, verify the purchase, save the state, and immediately grant the items (e.g. giving 100 Cosmetic Tokens).

---

## 🛠️ Implementation Standard (`StoreService.luau`)

```lua
--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Net = require(Shared:WaitForChild("Network"):WaitForChild("Net"))

local StoreService = {
    Name = "StoreService"
}

local productHandlers: { [number]: (player: Player) -> boolean } = {}

-- 1. Register handlers for developer product effects
function StoreService:RegisterProduct(productId: number, handler: (player: Player) -> boolean)
    productHandlers[productId] = handler
end

-- 2. Check Gamepass ownership (cached)
function StoreService:UserOwnsGamepass(player: Player, gamepassId: number): boolean
    local success, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, gamepassId)
    return success and owns
end

function StoreService:Init()
    -- Dynamically expose remote function for client-side ownership queries
    Net:Function("CheckGamepassOwnership").OnServerInvoke = function(player: Player, gamepassId: number)
        return self:UserOwnsGamepass(player, gamepassId)
    end

    -- 3. Core ProcessReceipt callback for Developer Products
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local handler = productHandlers[receiptInfo.ProductId]
        if handler then
            local success = handler(player)
            if success then
                -- Immediately notify the client to update HUD UI
                Net:Event("PurchaseSuccessful"):FireClient(player, receiptInfo.ProductId)
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end

        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

return StoreService
```
