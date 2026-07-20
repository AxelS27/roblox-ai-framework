# Badge Unlock Rewards Configuration

---

## 🎁 Rewards Mapping Table

| Badge Name | Unlock Reward / Benefit | Technical Effect (Code side) |
| :--- | :--- | :--- |
| `[e.g., Veteran Sailor]` | `[e.g., Grants the "Veteran" chat tag and +500 Gold]` | `[e.g., ChatService updates chat prefix; DataStore adds +500 Gold to profile]` |
| `[Badge Name]` | `[Unlock Reward]` | `[Technical Effect]` |

---

## 🛠️ Code Configuration Hook Schema
```lua
-- Proposed config hook schema
-- Path: src/shared/Configs/BadgeRewardsConfig.luau

export type BadgeReward = {
    coinsReward: number,
    chatTag: string?,
}

local BadgeRewardsConfig: {[number]: BadgeReward} = {
    [12345678] = { -- Replace with Badge ID
        coinsReward = 500,
        chatTag = "Veteran",
    }
}

return table.freeze(BadgeRewardsConfig)
```
