# World Spec: [World/Map Name]

---

## 👥 User Story
* **As a** `[Hider / Seeker]`
* **I want to** `[navigate/explore/hide in this specific map environment]`
* **So that** `[I experience engaging gameplay with high cover density, atmospheric lighting, and dynamic reality collapse events]`

---

## 🏬 Map Overview & Setting
* **Theme / Setting:** `[e.g. Hospital ER, Operating Rooms, Basement Morgue]`
* **Key Visual Aesthetics:** `[e.g. Sterilized tile floors, flickering fluorescent lights, dark basement morgue]`
* **Roblox Place ID:** `[Insert Place ID / Placeholder]`
* **Player Capacity:** `[e.g., 12 Players (1 Seeker, 11 Hiders)]`

---

## ⚡ Reality Collapse Event Chain Sequence
`[Specify the 3-stage dynamic reality events triggered during the match on this map.]`

1. **Stage 1 Event (Intermission -> Early Match):** `[e.g., Power Outage - All ambient lights turn off for 10 seconds]`
2. **Stage 2 Event (Mid Match):** `[e.g., Flooded Basement - Water plane rises 5 studs in the lower level]`
3. **Stage 3 Event (Late Match Climax):** `[e.g., Collapsed Hallway - Debris blocks main exit, opening secret vent path]`

---

## 🎭 Environment & Atmospheric Lighting
`[Describe the physical world setting and lighting rules.]`

### Lighting Settings (Properties):
* **Technology:** `Enum.Technology.Future`
* **ClockTime:** `[e.g., 22.0 - Night / Dark Mood]`
* **Ambient:** `Color3.fromRGB(18, 12, 32)`
* **OutdoorAmbient:** `Color3.fromRGB(28, 18, 48)`
* **Brightness:** `1.5`

### Post-Processing Effects:
* **ColorCorrection:** `[Contrast: 0.2, Saturation: 0.15, Tint: Color3.fromRGB(240, 230, 255)]`
* **DepthOfField:** `[FocusDistance: 10, InFocusRadius: 5]`
* **Bloom:** `[Intensity: 0.75, Size: 24, Threshold: 0.8]`

---

## 🏛️ Environmental Staging & Architectural Detailing

### Composite Building Structures:
* **`[Structure 1]`**: `[e.g. Main Hospital Building with dark metal foundation trim, glass windows, and neon roof borders]`
* **`[Structure 2]`**: `[e.g. Basement Morgue with tiled walls, metal gurney props, and narrow alcoves]`

### Prop Staging Hierarchy:
* **Ground Level Props**: `[e.g. Sidewalk curbs, tile floor patterns, floor drains]`
* **Cover Props (Gameplay Hiding Spots)**: `[e.g. Hospital beds, medical supply crates, filing cabinets, dumpsters]`
* **Vertical Props**: `[e.g. Emergency exit lights, ceiling IV poles, wall pipes, hanging wires]`

---

## 🏗️ Workspace Map Architecture & Anchors

Every map model instantiated natively into `ReplicatedStorage.Maps` or `Workspace` must contain:
* `Workspace.CurrentMap.HiderSpawns` (`Folder` of CFrame parts)
* `Workspace.CurrentMap.SeekerCage` (`Model` with locked door barrier)
* `Workspace.CurrentMap.EventTriggers` (`Folder` containing event anchors, rising water planes, moving doors)
