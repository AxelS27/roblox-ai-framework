# UI Component Blueprint: Tooltip / Stats Info Popup

> [!NOTE]
> Floating information card that appears when hovering or holding touch over items, skills, or weapons to reveal detailed stats.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type TooltipStat = {
    Label: string,
    Value: string,
    ValueColor: Color3?,
}

export type TooltipProps = {
    Title: string,
    Description: string?,
    Stats: { TooltipStat }?,
    RarityColor: Color3?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Tooltip Container - Positioned dynamically near cursor / touch position)
├── UICorner (CornerRadius: UDim.new(0, 10))
├── UIStroke (Thickness: 2px, Color: Rarity Color or Hex #444455)
├── UIPadding (Padding: 12px)
├── UIListLayout (FillDirection: Vertical, Padding: 8px)
├── TextLabel (Item Title Text - Bold, Color derived from Rarity)
├── Frame (Divider Line - Height 1px, Color: White 20% Opacity)
├── TextLabel (Description Text - Wrapped)
└── Frame (Stats List Container)
    ├── UIListLayout (FillDirection: Vertical, Padding: 4px)
    └── Frame (Stat Row - Repeats per Stat)
        ├── TextLabel (Stat Label - Left Aligned)
        └── TextLabel (Stat Value - Right Aligned)
```

---

## 🎨 Visual Design Tokens & Behavior

| Element | Specification |
| :--- | :--- |
| **Container Fill** | `#121216` (Translucency: `0.1` - Dark High Contrast) |
| **Position Anchor** | Automatically clamps inside screen margins to prevent going off-screen |
| **Fade Animation** | Displays after `0.2s` hover delay. Fades in (`Opacity 0 -> 1`, `Duration 0.15s`) |
