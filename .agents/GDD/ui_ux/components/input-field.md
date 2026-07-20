# UI Component Blueprint: Input Field / Search Bar

> [!NOTE]
> Component for text inputs, player search bars, promo code entry boxes, and numerical value pickers.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type InputFieldProps = {
    PlaceholderText: string,
    DefaultValue: string?,
    IconId: string?, -- Search glass icon
    ClearButton: boolean?,
    MaxCharacters: number?,
    OnTextChanged: ((newText: string) -> ())?,
    OnSubmit: ((finalText: string) -> ())?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Input Frame - Size {0, 240, 0, 40})
├── UICorner (CornerRadius: UDim.new(0, 8))
├── UIStroke (Thickness: 1px, Focused Color: Hex #00aaff, Idle Color: Hex #333333)
├── UIPadding (PaddingLeft: 10px, PaddingRight: 10px)
├── UIListLayout (FillDirection: Horizontal, VerticalAlignment: Center, Padding: 8px)
├── ImageLabel (Search Icon / Prefix Icon)
├── TextBox (Roblox Native Text Focus Input)
└── ImageButton (Clear Text "X" Button - Appears when text length > 0)
```

---

## 🎨 Visual Design Tokens & States

| State | Fill Color | Stroke Color | Text Color |
| :--- | :--- | :--- | :--- |
| **Idle** | `#16161a` | `#33333e` | `#ffffff` (Placeholder: `#777788`) |
| **Focused (Typing)**| `#1f1f26` | `#00aaff` (Sky Blue) | `#ffffff` |
| **Error / Invalid** | `#26161a` | `#ff3355` (Red Alert) | `#ff8888` |

---

## 🎭 Input Behaviors & Validation
* **Focus In:** Stroke color tweens to Sky Blue `#00aaff`. Virtual keyboard opens on Mobile devices.
* **Character Limit Enforcement:** Truncates input automatically if length exceeds `MaxCharacters`.
* **Clear Action:** Clicking the "X" button clears `TextBox.Text` instantly and refocuses input.
