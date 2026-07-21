# Roblox UI Layout & Coordination Pattern

> **Guidelines for Responsive Scaling, Z-Index Layering, and Roblox Native UI Safe-Zone Integration**

---

## 📌 Overview
This pattern defines the standards for custom UI design, responsive scaling, Z-index layer ordering, and coordination with Roblox's native CoreGui elements (Chat, Leaderstats, Backpack) to guarantee zero overlapping.

---

## 📐 1. Responsive Scaling & Constraints
To ensure UI elements scale correctly across Mobile, Tablet, PC, and Console screens:

1. **Scale Over Offset**: Always use the Scale component of UDim2 for Size and Position properties. Avoid absolute pixel Offsets except for thin borders or padding.
   ```luau
   -- Good (Responsive):
   frame.Size = UDim2.new(0.3, 0, 0.4, 0)
   -- Bad (Fixed Pixels):
   frame.Size = UDim2.new(0, 360, 0, 480)
   ```
2. **AnchorPoints**: Use AnchorPoints for precise relative centering or alignment.
   * Center Alignment: `AnchorPoint = Vector2.new(0.5, 0.5)` and `Position = UDim2.new(0.5, 0, 0.5, 0)`.
   * Bottom-Left HUD: `AnchorPoint = Vector2.new(0, 1)` and `Position = UDim2.new(0, 20, 1, -20)`.
3. **Aspect Ratio Preservation**: Use `UIAspectRatioConstraint` to prevent square buttons or viewport frames from stretching on wide monitors.

---

## 🥞 2. Z-Index Layering Conventions
All custom ScreenGuis must adhere to this standard layout order and ZIndex layering:

| Layer Level | ZIndex Range | UI Component Category | Description |
| :--- | :--- | :--- | :--- |
| **Layer 1** | `1` | Background Canvas & Fills | Solid panels, glassmorphism backing frames |
| **Layer 2** | `2` | Frame Containers & Lists | ScrollingFrames, layout containers, grid slots |
| **Layer 3** | `3 – 5` | Content, Text & Status Bars | HP/Stamina fill bars, text labels, icons, click buttons |
| **Layer 4** | `10` | Fullscreen Windows | Evolution Tree Menu, Store Shop Menu, Custom Inventory |
| **Layer 5** | `50` | Tooltips, Modals & Dialogs | Confirmation popups, item hover tooltips, invite prompts |
| **Layer 6** | `100+` | Toast Notifications & Alerts | High-priority banners, damage numbers, survival warnings |

---

## 🛡️ 3. Roblox Native UI Coordination (Safe Zones)
To prevent custom elements from clashing with native Roblox systems:

```
[ Native Chat (Top-Left) ]                                [ Native Leaderstats (Top-Right) ]
  Avoid Custom HUD here                                     Avoid Custom HUD here
  (Offset: X:0-0.3, Y:0-0.25)                               (Offset: X:0.7-1.0, Y:0-0.25)
              │                                                         │
              ▼                                                         ▼
    ┌─────────────────────────────────────────────────────────────────────┐
    │                                                                     │
    │  ◄── [Toast Alerts (Middle-Left)]                                    │
    │      (Offset: X:0.02, Y:0.35)                                       │
    │                                                                     │
    │                                                                     │
    │                                                                     │
    │                                                                     │
    │  [Vitals HUD (Bottom-Left)] ──►                                     │
    │  (Offset: X:0.02, Y:0.95)                                           │
    │                                                                     │
    └─────────────────────────────────────────────────────────────────────┘
```

1. **Top-Right Corner (Leaderstats / Player List)**:
   * Keep coordinates `UDim2.new(X >= 0.7, Y <= 0.25)` clear of custom HUD elements.
2. **Top-Left Corner (Native Chat)**:
   * Keep coordinates `UDim2.new(X <= 0.3, Y <= 0.25)` clear of custom HUD elements.
3. **Programmatic Relocation & Toggling**:
   * If a custom HUD requires the Top-Left or Top-Right areas, you must programmatically disable or relocate the native CoreGui:
   ```luau
   local StarterGui = game:GetService("StarterGui")
   
   -- Disable native backpack or playerlist if custom ones are built
   StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
   StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
   
   -- To relocate Chat or configure custom ZIndex (using modern TextChatService):
   local TextChatService = game:GetService("TextChatService")
   local chatWindowConfiguration = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
   if chatWindowConfiguration then
       -- Adjust chat window properties if needed
   end
   ```

---

## 🎬 4. Shared UI Animation Utility (UIAnimate)
All client controllers must use the shared [UIAnimate](file:///d:/Experiments/Roblox%20AI%20Framework/src/shared/Utilities/UIAnimate.luau) utility module to apply premium animations instead of writing local TweenService scripts:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIAnimate = require(ReplicatedStorage.Shared.Utilities.UIAnimate)

-- 1. Hover & Click Elastic Bouncing on a button
local cleanup = UIAnimate.bindHoverScale(button, 1.15, 0.85)

-- 2. Button UIStroke Scale or Visibility on hover
local cleanupStroke = UIAnimate.bindStrokeScale(button, button.UIStroke)

-- 3. Dynamic PopIn/PopOut frame transitions
local isOpen = true
UIAnimate.bounce(frame, originalFrameSize, isOpen) -- Elastic bouncy pop
-- Or: UIAnimate.popup(frame, originalFrameSize, isOpen) -- Standard smooth pop
-- Or: UIAnimate.rotateIn(frame, originalFrameSize, 15, isOpen) -- Slanted spin in
```

---

## 🎨 5. Premium UI Aesthetics & Design Tokens (Glassmorphism)
To prevent plain, flat, or clashing UIs (like default black boxes or overlapping alert frames), all custom interfaces must comply with these premium aesthetic standards:

### 1. Glassmorphism Design System
All HUD panels, menu frames, and hotbar slots must employ a frosted glass aesthetic:
* **Background Transparency**: Set `BackgroundTransparency` between `0.25` and `0.4` using a dark base color (e.g., `Color3.fromRGB(15, 15, 22)`).
* **Rounded Corners**: Attach a `UICorner` to every frame with a `CornerRadius` of `8` to `12` pixels (`UDim.new(0, 8)`).
* **Glossy Border Outline**: Attach a `UIStroke` to panels to mimic glass refraction:
  ```luau
  stroke.Color = Color3.fromRGB(255, 255, 255)
  stroke.Transparency = 0.85
  stroke.Thickness = 1
  stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  ```
* **Visual Depth (Gradients)**: Apply a `UIGradient` to background frames with a subtle vertical color fade (e.g., top color slightly lighter than bottom).

### 2. High-Contrast Gradient Progress Bars
Avoid solid primary colors (such as pure red or pure cyan). Progress bars (HP, Hunger, Stamina, DNA/XP) must use dual-color gradients:
* **Health (HP)**: Emerald-to-Lime Green (`Color3.fromRGB(16, 185, 129)` to `Color3.fromRGB(110, 231, 183)`) or Ruby-to-Rose Red.
* **Stamina**: Electric-to-Sky Blue (`Color3.fromRGB(14, 165, 233)` to `Color3.fromRGB(125, 211, 252)`).
* **Hunger**: Amber-to-Orange (`Color3.fromRGB(245, 158, 11)` to `Color3.fromRGB(253, 186, 116)`).
* **DNA / XP**: Amethyst-to-Magenta (`Color3.fromRGB(168, 85, 247)` to `Color3.fromRGB(216, 180, 254)`).

### 3. Layout Separation Invariant (Anti-Overlap Guard)
To prevent layout clashes (such as toast alerts overlapping vitals HUD or chat boxes):
* **Separation Margin**: Maintain a minimum vertical gap of `40` pixels between independent screen elements.
* **Vitals & Toast Placement**:
  * Vitals HUD (Bottom-Left): `Position = UDim2.new(0, 25, 1, -25)`, `AnchorPoint = Vector2.new(0, 1)`.
  * Toast Alerts (Middle-Left): `Position = UDim2.new(0, 25, 0.4, 0)`, `AnchorPoint = Vector2.new(0, 0)`.
  * This guarantees that alerts and vitals can never collide or overlap, regardless of screen resolution.
* **Text Padding**: Use `UIPadding` to give text labels a minimum of `8` pixels padding away from frame borders to avoid text truncation.

### 4. Typography, Icons & Audio Feedback
* **Fonts**: Use modern, clean sans-serif typography such as `Montserrat`, `BuilderSans`, or `GothamSSm`. Never use `Legacy` or default pixel fonts.
* **Iconography**: Add high-quality vector icons next to stats (e.g., a heart icon for HP, a bolt for Stamina, meat for Hunger, and a double-helix for DNA/XP) instead of raw text labels.
* **Interactive Audio Feedback**: Every interactive UI button MUST play a subtle hover sound when the mouse cursor enters, and a satisfying select/click sound when pressed. While `AudioController` binds this automatically to all ScreenGui buttons on spawn, any custom-coded buttons must preserve this audio feedback standard.

---

## 🔘 6. Menu Access & UX Trigger Standards (HUD Buttons vs. World Interaction)
Forcing players to memorize keyboard keys (like pressing `B` for Shop or `K` for Emotes) is a severe UX anti-pattern that breaks the game for Mobile/iPad players and makes the world feel static. All menus and systems must employ dual-access mechanisms:

### 1. The HUD Navigation Bar (Direct Access)
* **Never Lock Behind Keybinds**: Keyboard shortcuts (e.g. `B` for Shop) are strictly secondary accelerators. Every menu must have a prominent, click/tap-accessible button on the main ScreenGui.
* **Unified Sidebar/Menu Toolbar**: Combine secondary menus (Shop, Emotes, Skins, Settings) into a clean, unified toolbar positioned in a safe zone (e.g. Left-Center or Top-Center):
  * **Visual Design**: Transparent glassmorphic circle buttons (`50x50`px) with modern icons instead of text.
  * **Mobile Comfort**: Buttons must be large enough to tap easily without misclicking.

### 2. World Integration: Themed Shop Booths & NPCs
To increase player immersion and map fidelity, major shops or gameplay systems must have a physical presence in the world (e.g., the Game lobby or map spawn zone):
* **Physical Staging**: Stage themed 3D structures (e.g., a styled wooden Trading Booth, a glowing Crystal Nest, or a Shop NPC) directly in the map during Edit Mode.
* **ProximityPrompt Interaction**: Attach a `ProximityPrompt` to the world structure:
  * Set `ActionText` to descriptive labels (e.g., *"Open Cosmetic Shop"*, *"Trade Items"*).
  * Set `ObjectText` to the booth/NPC name.
  * Set `HoldDuration` to `0.2` seconds for snappy responsiveness.
* **UI Trigger**: When the `ProximityPrompt` is triggered, pop open the corresponding UI panel smoothly using `UIAnimate.bounce`.
* **Proximity Dismissal**: If a player walks more than `15` studs away from the physical booth, automatically fade out/close the open UI panel.


