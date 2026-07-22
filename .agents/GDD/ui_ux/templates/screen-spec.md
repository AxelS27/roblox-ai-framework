# UI Screen Spec: [Screen Name]

---

## 👥 User Stories (Target 10+ entries from diverse POVs, states & conditions)

### Story 1: New / First-Time Player POV
* **As a** `[New Player]`
* **I want to** `[see intuitive visual icons and prominent close buttons]`
* **So that** `[I can navigate this screen without needing a manual]`

### Story 2: Veteran / Power User PC POV
* **As a** `[PC Power User]`
* **I want to** `[toggle this menu via quick keyboard hotkeys (e.g. Tab, M, B, Esc)]`
* **So that** `[I can perform actions instantly without mouse clicks]`

### Story 3: Mobile Touch HUD POV
* **As a** `[Mobile / iPad Player]`
* **I want to** `[access this screen via a dedicated frosted HUD button with safe-margin placement]`
* **So that** `[I never experience touch overlap with native controls]`

### Story 4: Mid-Combat / In-Game Overlay Condition
* **As a** `[Player Opening Menu in Danger Zone]`
* **I want to** `[have non-blocking semi-transparent glassmorphic panels]`
* **So that** `[I can still see incoming threats in the peripheral background]`

### Story 5: Low Health / Warning State Condition
* **As a** `[Player at Low Health]`
* **I want to** `[see glowing red vital alerts prioritized above modal panels]`
* **So that** `[I'm warned if taking damage while managing UI]`

### Story 6: Audio & Tactile Sensory Feedback State
* **As a** `[Player Interacting with Buttons]`
* **I want to** `[hear hover sounds and click SFX with subtle UI scale animations]`
* **So that** `[every interaction feels tactile and satisfying]`

### Story 7: Purchase / DevProduct Trigger Condition
* **As a** `[Gamepass / Product Buyer]`
* **I want to** `[trigger Roblox native purchase prompts directly from shop buttons]`
* **So that** `[I can complete purchases seamlessly]`

### Story 8: Reconnection / State Refresh Condition
* **As a** `[Player Reconnecting After Desync]`
* **I want to** `[have the UI automatically re-sync with server state]`
* **So that** `[I don't view stale data or broken counters]`

### Story 9: Multi-Language / Localization Edge Case
* **As a** `[Non-English Player]`
* **I want to** `[have auto-scaling text labels and localizable text keys]`
* **So that** `[translated text never clips or overflows frames]`

### Story 10: In-World Proximity Trigger POV
* **As a** `[Player Approaching In-World NPC/Booth]`
* **I want to** `[trigger this panel via a ProximityPrompt and auto-close when walking >15 studs away]`
* **So that** `[UI state stays synced with my physical location]`

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

* **Camera State Mode:** `[ThirdPerson | FirstPerson | ViewportFocus | DroneCinematic | Cutscene]`

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
