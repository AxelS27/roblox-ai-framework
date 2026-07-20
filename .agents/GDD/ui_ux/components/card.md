# UI Component Blueprint: Card / Item Tile

> [!NOTE]
> Component for Shop product cards, inventory grid tiles, character selection cards, and rarity-bordered items.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type RarityTier = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type CardProps = {
    Title: string,
    SubTitle: string?,
    IconId: string,
    PriceText: string?,
    Rarity: RarityTier?,
    Selected: boolean?,
    OnCardClicked: (() -> ())?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Card Container Frame - Size {0, 140, 0, 180})
├── UICorner (CornerRadius: UDim.new(0, 12))
├── UIStroke (Thickness: 2px, Color derived from Rarity Color)
├── ImageLabel (Background Banner / Glow Shader)
├── ImageLabel (Item Asset Preview Icon)
│   └── UIAspectRatioConstraint (1:1)
├── TextLabel (Item Title Text)
├── Frame (Rarity Tag Pill Badge)
│   └── TextLabel (Rarity Name)
└── TextButton (Card Action / Buy Button)
```

---

## 🎨 Visual Rarity Color Tokens

| Rarity Tier | Stroke Color (Hex) | Background Fill (Hex) | Rarity Pill Text Color |
| :--- | :--- | :--- | :--- |
| **Common** | `#aaaaaa` (Gray) | `#1a1a1a` | `#ffffff` |
| **Uncommon** | `#55ff55` (Green) | `#1a261a` | `#55ff55` |
| **Rare** | `#3399ff` (Blue) | `#1a2030` | `#3399ff` |
| **Epic** | `#aa33ff` (Purple) | `#261a30` | `#aa33ff` |
| **Legendary** | `#ffaa00` (Gold) | `#30241a` | `#ffaa00` |

---

## 🎭 State Machine & Selection Tweens

| State | Visual Behavior | Easing & Duration |
| :--- | :--- | :--- |
| **Hover** | Card lifts up slightly (`Position Y -5px`), Rarity stroke glows bright | `Quad Out (0.15s)` |
| **Selected** | Gold outer highlight outline appears, checkmark badge overlays corner | `Back Out (0.2s)` |
| **Purchased/Owned** | Shows "EQUIPPED" or "OWNED" overlay banner across bottom | `Fade (0.2s)` |
