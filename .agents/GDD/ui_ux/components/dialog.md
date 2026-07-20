# UI Component Blueprint: Dialog / Modal Window

> [!NOTE]
> Pop-up modal dialog component used for confirmation pop-ups, shop detail windows, and settings overlays with background blur backdrops.

---

## 🛠️ Props & API Contract Schema (Luau Types)

```lua
export type DialogType = "Confirm" | "Alert" | "Custom"

export type DialogProps = {
    Title: string,
    Message: string?,
    Type: DialogType?,
    ConfirmText: string?,
    CancelText: string?,
    OnConfirm: (() -> ())?,
    OnCancel: (() -> ())?,
}
```

---

## 🌳 Roblox Instance Tree Hierarchy

```
Frame (Backdrop Overlay - Size {1,0, 1,0}, BackgroundTransparency: 0.3)
├── BlurEffect (Parented to Lighting on open)
└── Frame (Dialog Container - Size {0.4,0, 0.5,0}, Anchored Center {0.5, 0.5})
    ├── UICorner (CornerRadius: UDim.new(0, 16))
    ├── UIStroke (Thickness: 2px, Color: Hex #3a3a3a)
    ├── UIPadding (Padding: 20px)
    ├── UIListLayout (FillDirection: Vertical, Padding: 16px)
    ├── Frame (Header Row)
    │   ├── TextLabel (Title)
    │   └── ImageButton (Close X Button)
    ├── Frame (Content Body Frame)
    │   └── TextLabel (Message Body)
    └── Frame (Footer Actions Row)
        ├── UIListLayout (FillDirection: Horizontal, HorizontalAlignment: Right, Padding: 12px)
        ├── Button (Cancel Button - Secondary Variant)
        └── Button (Confirm Button - Primary/Danger Variant)
```

---

## 🎨 Visual Design Tokens

| Element | Background Fill | Border / Stroke | Typography |
| :--- | :--- | :--- | :--- |
| **Backdrop** | `#000000` (Transparency: `0.35`) | None | N/A |
| **Dialog Frame** | `#1a1a1e` (Glassmorphism Translucency: `0.15`) | `#ffffff` (15% Opacity) | N/A |
| **Header Title** | Transparent | None | Gotham Bold, 22px, `#ffffff` |
| **Body Message** | Transparent | None | Source Sans Pro, 16px, `#cccccc` |

---

## 🎭 Open / Close Transitions & Tweens

| Event | Action & Animation | Easing & Duration | SFX |
| :--- | :--- | :--- | :--- |
| **Open** | Backdrop fades in (`0 -> 0.35`). Container scales `0.8 -> 1.0` and fades in. Blur size `0 -> 16` | `Back Out (0.3s)` | PopOpen `rbxassetid://45678901` |
| **Close** | Container scales `1.0 -> 0.8` and fades out. Backdrop fades out. Blur size `16 -> 0` | `Quad In (0.2s)` | PopClose `rbxassetid://45678902` |
| **Backdrop Click** | Clicking outside the dialog triggers `OnCancel()` | `None` | Click Tick |

---

## 📱 Accessibility & Input Rules
* **Escape Key / Gamepad B:** Pressing Escape or Gamepad B automatically triggers the Cancel action.
* **Focus Locking:** Input signals behind the modal backdrop are captured and blocked from reaching the world HUD.
