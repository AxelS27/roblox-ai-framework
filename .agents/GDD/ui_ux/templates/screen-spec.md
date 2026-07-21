# UI Screen Spec: [Screen Name]

---

## 👥 User Story
* **As a** `[Player/Developer]`
* **I want to** `[perform action / open UI / change state]`
* **So that** `[value/benefit is achieved]`

---

## 🕹️ Input Control & Navigation Behavior

* **Character Movement State:** `[Disabled / Frozen (Modal Menu) | Enabled (HUD Overlay)]`
* **Cursor Mode:** `[Unlocked / Visible (Modal Menu) | Locked Center / Hidden (HUD Overlay)]`
* **UI Co-Existence / Stack Behavior:**
  * **Exclusive Modal:** `[Yes (Closes or blocks all other menus when opened) | No (Can stay open alongside HUD)]`
  * **Keybind Toggle:** `[e.g. KeyCode.Tab / KeyCode.M]`
  * **Back / Close Trigger:** `[e.g. KeyCode.Escape / Close Button Click]`

---

## 🎨 Visual Looks & Feel
`[Describe the aesthetic properties of this UI screen (e.g. glassmorphism opacity, borders, corner rounding).]`

* **Aesthetic Theme:** `[e.g., Frosted Glass / Neon Cyberpunk]`
* **UICorner Border Radius:** `[e.g., UDim.new(0, 12) - rounded corners]`
* **Border Thickness & Color:** `[e.g., 2px solid Hex #ffffff (30% opacity)]`
* **Translucency / Background Blur:** `[e.g., Frame Background Transparency = 0.4, Glassmorphism Blur = true]`

---

## 📐 Layout Panels & Hierarchy
`[Identify where panels, lists, or buttons are positioned (e.g. Left Panel, Right Panel, Center Preview, Bottom Actions).]`

* **Left Panel:** `[e.g., Vertical stack containing Color Pickers (RGB slider knobs)]`
* **Right Panel:** `[e.g., Grid of scrolling items (Hair selections, hat selections, clothing slots)]`
* **Center Area:** `[e.g., Clear viewport frame showing the active player character model rotating]`
* **Bottom Panel:** `[e.g., Action buttons row (Save Slot, Edit Character, Delete Character)]`

---

## 🎥 Dynamic Camera Focus & Viewport States
`[Describe any camera zoom/focus actions triggered when interacting with elements on this screen.]`

| Selected Option / Action | Camera Focus Target | Distance / Zoom Offset | Easing & Duration |
| :--- | :--- | :--- | :--- |
| `[e.g., Selecting Hair Category]` | `[Character Head Part]` | `[Zoom In - 3 studs offset]` | `[Quad InOut - 0.4s]` |
| `[e.g., Selecting Shoes Category]` | `[Character Left/Right Foot]` | `[Zoom In - 2 studs offset]` | `[Quad InOut - 0.4s]` |
| `[e.g., Clicking Cancel/Exit]` | `[Lobby Overview Camera]` | `[Zoom Out - 15 studs]` | `[Sine Out - 0.3s]` |

---

## ⚙️ Interactive Flow & State Logic
`[Detailed step-by-step logic rules for buttons, saves, deletes, and slots.]`

* **Character Rotation:** `[e.g., The viewport character dummy rotates continuously at 15 degrees/second when idle. Players can drag in the center area to manually rotate the dummy left/right.]`
* **Slot Selection Flow:**
  1. `[Step 1, e.g., Click "Save Character" button.]`
  2. `[Step 2, e.g., Triggers a Confirmation pop-up modal asking to overwrite the selected slot.]`
  3. `[Step 3, e.g., Fires SaveCustomization remote event, validating data on server and updating player DataStore.]`
