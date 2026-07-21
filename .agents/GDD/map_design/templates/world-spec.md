# World Spec: [World/Map Name]

---

## 👥 User Story
* **As a** `[Player / Role]`
* **I want to** `[navigate / explore / interact in this specific map environment]`
* **So that** `[I experience engaging gameplay with high cover density, atmospheric lighting, and dynamic environment events]`

---

## 🏬 Map Overview & Setting
* **Theme / Setting:** `[e.g. Sci-Fi Station, Fantasy Kingdom, Downtown City]`
* **Key Visual Aesthetics:** `[e.g. Metallic floors, neon lights, glass windows]`
* **Roblox Place ID:** `[Insert Place ID / Placeholder]`
* **Player Capacity:** `[e.g. 16 Players]`

---

## ⚡ Dynamic Environment Event Chain Sequence
`[Specify the 3-stage dynamic environmental events triggered during the match on this map.]`

1. **Stage 1 Event (Early Match):** `[e.g. Power Outage - Ambient lighting dims for 10 seconds]`
2. **Stage 2 Event (Mid Match):** `[e.g. Environmental Hazard - Water level rises or low gravity activates]`
3. **Stage 3 Event (Late Match Climax):** `[e.g. Map Collapse - Main bridge breaks, opening alternative path]`

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
* **`[Structure 1]`**: `[e.g. Central Tower with foundation trim, glass windows, and roof neon trim]`
* **`[Structure 2]`**: `[e.g. Side Annex with multi-level stairs and balcony access]`

### Prop Staging Hierarchy:
* **Ground Level Props**: `[e.g. Sidewalk curbs, tile floor patterns, floor drains]`
* **Cover Props (Gameplay Obstacles)**: `[e.g. Wooden crates, metal barrels, shipping containers, barriers]`
* **Vertical Props**: `[e.g. Street lamps, wall pipes, hanging banners, neon signs]`

---

## 🏗️ Workspace Map Architecture & Anchors

Every map model instantiated natively into `ReplicatedStorage.Maps` or `Workspace` must contain:
* `Workspace.CurrentMap.PlayerSpawns` (`Folder` of CFrame parts)
* `Workspace.CurrentMap.LobbyCage` (`Model` or `Folder` with spawn barrier)
* `Workspace.CurrentMap.EventTriggers` (`Folder` containing event anchors, moving doors, triggers)
