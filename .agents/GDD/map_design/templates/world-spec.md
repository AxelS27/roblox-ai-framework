# World Spec: [World/Map Name]

---

## 👥 User Story
* **As a** `[Player / Role]`
* **I want to** `[navigate / explore / interact in this specific map environment]`
* **So that** `[I experience engaging gameplay with high cover density, atmospheric lighting, and dynamic environment events]`

---

## 🏬 Map Overview & Setting
* **Theme / Setting:** `[e.g. Volcanic Island, Sci-Fi Station, Gothic Castle]`
* **Key Visual Aesthetics:** `[e.g. Glowing magma rivers, dark basalt rock, ash particles, metal catwalks]`
* **Roblox Place ID:** `[Insert Place ID / Placeholder]`
* **Player Capacity:** `[e.g. 16 Players]`

---

## 🗺️ Sub-Locations, Landmarks & Layout Connectivity
`[Divide the map into distinct sub-areas/landmarks and detail how they connect and what mechanics exist in each area.]`

| Sub-Location / Landmark | Visual & Architectural Theme | Connected To | Gameplay Function / Mechanics & Tags |
| :--- | :--- | :--- | :--- |
| **`[Area 1: e.g., Volcanic Crater]`** | `[High elevation, glowing magma pool rim]` | `[Connects to Area 2 via Rope Bridge]` | `[Stage 3 Eruption Event Anchor, Tag: HighGround]` |
| **`[Area 2: e.g., Lava River Bridge]`** | `[Narrow wooden/metal bridge over magma]` | `[Connects Area 1 and Area 3]` | `[Hazard: Fall damage / Lava Damage, Tag: DamageZone]` |
| **`[Area 3: e.g., Obsidian Caverns]`** | `[Enclosed dark cave system with basalt pillars]` | `[Connects to Area 2 and Sub-Exit]` | `[High cover density, Tag: StealthZone]` |

---

## ⚡ Dynamic Environment Event Chain Sequence
`[Specify the 3-stage dynamic environmental events triggered during the match on this map.]`

1. **Stage 1 Event (Early Match):** `[e.g. Minor Tremor - Screen shake and falling ash particles]`
2. **Stage 2 Event (Mid Match):** `[e.g. Lava Level Rise - Magma pool in Area 2 rises 4 studs]`
3. **Stage 3 Event (Late Match Climax):** `[e.g. Volcanic Eruption - Lava rocks rain from the sky, opening secret exit in Area 3]`

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
* `Workspace.CurrentMap.GameplayZones` (`Folder` containing CollectionService-tagged zone parts: `DamageZone`, `HealZone`, `SpeedZone`, etc.)
