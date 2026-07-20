# UI Component Blueprint: Slider (Color / Volume / Settings)

> [!NOTE]
> Component for dragging numeric values such as RGB color pickers, sound volume, camera sensitivity, and FOV adjustments.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type SliderProps = {
    MinValue: number,
    MaxValue: number,
    Step: number?, -- Incremental snap value (e.g. 1, 0.1)
    DefaultValue: number?,
    ShowValueText: boolean?,
    OnValueChanged: ((newValue: number) -> ())?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Slider Container - Size {0, 200, 0, 30})
├── UIListLayout (FillDirection: Horizontal, VerticalAlignment: Center, Padding: 10px)
├── Frame (Slider Track Bar - Size {1, -50, 0, 6})
│   ├── UICorner (CornerRadius: UDim.new(0, 3))
│   ├── Frame (Filled Track Portion - Width % = Current Value Ratio)
│   └── Frame (Draggable Knob Handle - Size {0, 18, 0, 18}, Positioned at Value Ratio)
│       ├── UICorner (CornerRadius: UDim.new(1, 0)) -- Fully circular knob
│       └── UIStroke (Thickness: 2px, Color: White)
└── TextLabel (Numeric Value Display - e.g. "75%", Width: 40px)
```

---

## 🎨 Visual Design Tokens & States

| Element | Idle Color | Dragging Active Color |
| :--- | :--- | :--- |
| **Track Background** | `#26262b` | `#26262b` |
| **Filled Track** | `#00aaff` (Sky Blue) | `#33bbff` |
| **Draggable Knob** | `#ffffff` | `#00aaff` (Scales `1.2x` while dragging) |

---

## 🎭 Interactive Dragging Physics
* **Mouse / Touch Dragging:** Listens to `InputBegan` on knob, calculates X-offset ratio relative to track length on `RenderStepped`, and updates value.
* **Value Snapping:** If `Step` is specified, snaps current value to nearest increment.
