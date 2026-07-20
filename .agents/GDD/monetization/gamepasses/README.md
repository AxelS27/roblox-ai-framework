# Gamepasses & Products Domain Spec

---

## 🎟️ Gamepasses (One-Time Purchases)

| Gamepass Name | Description / Benefit | In-Game Technical Utility | Price Category (Robux) | Asset ID |
| :--- | :--- | :--- | :--- | :--- |
| `[e.g., VIP Pass]` | `[e.g., Grants a gold name tag and +20% coins multiplier.]` | `[e.g., Checked via UserOwnsGamePassAsync on player joined]` | `[e.g., 250 Robux]` | `[Asset ID]` |
| `[Gamepass Name]` | `[Benefit]` | `[Technical Implementation]` | `[Price]` | `[Asset ID]` |

---

## 💎 Developer Products (Repeatable Purchases)

| Product Name | Purpose / Quantity | In-Game Technical Utility | Price Category (Robux) | Product ID |
| :--- | :--- | :--- | :--- | :--- |
| `[e.g., 1000 Coins]` | `[e.g., Instant purchase of 1,000 gold coins.]` | `[e.g., Processed via ProcessReceipt, adding +1000 to profile data]` | `[e.g., 99 Robux]` | `[Product ID]` |
| `[Product Name]` | `[Quantity]` | `[Technical Implementation]` | `[Price]` | `[Product ID]` |
