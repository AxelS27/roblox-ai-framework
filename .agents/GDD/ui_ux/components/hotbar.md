# UI Component Blueprint: Hotbar & Inventory Slot Grid

> [!NOTE]
> Component for quick-item hotbars, equipment grid slots, active item selection outlines, and cooldown overlays.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type SlotProps = {
    SlotIndex: number,
    ItemIconId: string?,
    Quantity: number?,
    Equipped: boolean?,
    CooldownPercent: number?, -- 0.0 to 1.0
    KeybindText: string?, -- e.g. "1", "2", "E"
    OnSlotClicked: ((slotIndex: number) -> ())?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Slot Frame - Size {0, 60, 0, 60})
├── UICorner (CornerRadius: UDim.new(0, 10))
├── UIStroke (Thickness: 2px, Active Color: Hex #ffaa00, Idle Color: Hex #333333)
├── ImageLabel (Item Icon)
│   └── UIAspectRatioConstraint (1:1)
├── TextLabel (Quantity Counter - Anchored Bottom-Right)
├── TextLabel (Keybind Badge - Anchored Top-Left)
└── Frame (Cooldown Overlay)
    └── BackgroundTransparency: 0.5 (Sweeps Y Size from 1.0 to 0.0)
```

---

## 🎨 Visual Design Tokens & States

| State | Background Fill | Stroke Color & Thickness | Icon Scale |
| :--- | :--- | :--- | :--- |
| **Empty Slot** | `#121215` (Transparency: `0.5`) | `#2c2c30` (1px) | Hidden |
| **Filled (Idle)** | `#1c1c22` (Transparency: `0.3`) | `#444450` (2px) | Scale `1.0x` |
| **Equipped / Selected**| `#2a2a35` (Transparency: `0.2`) | `#ffaa00` (3px Glowing) | Scale `1.1x` |
| **Cooldown Active** | `#0a0a0d` (Transparency: `0.6`) | `#665500` (2px) | Scale `0.95x` (Grayscale) |

---

## 🎭 Interactivity & Cooldown Sweeps

| Event | Visual Action | Easing & Duration |
| :--- | :--- | :--- |
| **Equip Item** | Slot stroke turns Gold `#ffaa00`, Icon bounces up `1.15x -> 1.0x` | `Elastic Out (0.3s)` |
| **Cooldown Start** | Dark translucent frame covers slot and shrinks down to 0% | `Linear (Duration = CooldownTime)` |
| **Drag & Drop** | Dragging slot creates floating preview icon following mouse cursor | `Continuous RenderStepped` |
