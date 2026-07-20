# UI Component Blueprint: Progress Bar

> [!NOTE]
> Component for Health bars, Stamina bars, XP bars, loading progress indicators, and custom resource meters.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type ProgressBarVariant = "Health" | "Stamina" | "XP" | "Custom"

export type ProgressBarProps = {
    CurrentValue: number,
    MaxValue: number,
    Variant: ProgressBarVariant?,
    ShowText: boolean?,
    CustomColor: Color3?,
    Animated: boolean?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Track Background - Size {1, 0, 0, 16})
├── UICorner (CornerRadius: UDim.new(0, 8))
├── UIStroke (Thickness: 1px, Color: Hex #ffffff 20% Opacity)
├── Frame (Lag Fill - Secondary delayed damage indicator fill)
│   └── UICorner (CornerRadius: UDim.new(0, 8))
├── Frame (Active Fill Bar - Size {Current/Max, 0, 1, 0})
│   ├── UICorner (CornerRadius: UDim.new(0, 8))
│   └── UIGradient (Color Gradient for shine/glow effect)
└── TextLabel (Value Indicator - e.g. "75 / 100", TextScaled)
```

---

## 🎨 Visual Color Tokens

| Variant | Fill Gradient Start | Fill Gradient End | Lag Fill (Damage) |
| :--- | :--- | :--- | :--- |
| **Health** | `#ff3355` (Red) | `#ff6688` | `#ffffff` (White Flash) |
| **Stamina** | `#33cc66` (Green) | `#66ff99` | `#ffcc00` |
| **XP** | `#9933ff` (Purple) | `#cc66ff` | `#441188` |
| **Shield / Mana** | `#00aaff` (Cyan) | `#66ccff` | `#003366` |

---

## 🎭 Interpolation & Lag Fill Animations

| State Change | Visual Behavior | Easing & Duration |
| :--- | :--- | :--- |
| **Value Loss (Damage)** | Active bar shrinks instantly. Lag Fill bar waits 0.3s then smoothly catches up | `Quad Out (0.5s delay)` |
| **Value Gain (Heal/XP)** | Active bar smoothly expands up to target percentage | `Sine Out (0.3s)` |
| **Low Health Alert (<20%)**| Bar pulses transparency and plays red flash gradient | `Repeat PingPong (0.4s)` |
