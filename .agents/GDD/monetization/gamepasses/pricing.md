# Monetization Pricing & Utility Configuration

---

## 📊 Robux-to-Utility Conversion Matrices

### Purchase Value Conversions:
| USD Price (Est.) | Robux Price | Value Granted | Bonus Modifier / Multiplier |
| :--- | :--- | :--- | :--- |
| `[e.g., $4.99]` | `[400 Robux]` | `[e.g., VIP Status]` | `[e.g., +20% Coin Income]` |
| `[USD]` | `[Robux]` | `[Value]` | `[Bonus]` |

---

## 🛠️ Code Configuration Hook Schema
```lua
-- Proposed config hook schema
-- Path: src/shared/Configs/MonetizationConfig.luau

export type GamepassData = {
    Price: number,
    BonusMultiplier: number,
}

local MonetizationConfig: {[number]: GamepassData} = {
    [12345678] = { -- Replace with Gamepass Asset ID
        Price = 400,
        BonusMultiplier = 1.2,
    }
}

return table.freeze(MonetizationConfig)
```
