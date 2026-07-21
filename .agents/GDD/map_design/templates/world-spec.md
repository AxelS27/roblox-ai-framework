# World Spec: [World/Place Name]

---

## 👥 User Story
* **As a** `[Player / Seeker / Hider]`
* **I want to** `[navigate/explore/hide in this specific map environment]`
* **So that** `[I experience engaging gameplay with high cover density, atmospheric lighting, and clear visual paths]`

---

## 📊 Place Information
* **Roblox Place ID:** `[Insert Place ID / Placeholder]`
* **Player Capacity:** `[e.g., 1 (Lobby) / 50 (Multiplayer Hub)]`
* **Objective/Role:** `[e.g., Customization lobby, endless dungeon zone]`

---

## 🎭 Environment & Aesthetics
`[Describe the physical world setting and lighting rules.]`

### Setting Details:
* **Style:** `[e.g., Cyberpunk City Ruins / Sci-Fi Station]`
* **Skybox:** `[e.g., Starry Night Skybox / Neon Glitch Skybox]`
* **Key Materials/Vibe:** `[e.g., Concrete walls with glowing neon stripes, glass windows, metal foundations]`

### Lighting Settings (Properties):
* **Technology:** `[Enum.Technology.Future]`
* **Ambient:** `[Color3.fromRGB(r, g, b)]`
* **OutdoorAmbient:** `[Color3.fromRGB(r, g, b)]`
* **Brightness:** `[e.g., 2.0]`
* **ClockTime:** `[e.g., 22.0 - Night Time]`

### Post-Processing Effects:
* **ColorCorrection:** `[Contrast: 0.2, Saturation: 0.15, Tint: Color3.fromRGB(r, g, b)]`
* **DepthOfField (Blur Background):** `[FocusDistance: 10, InFocusRadius: 5, NearIntensity: 0.8, FarIntensity: 0.5]`
* **Bloom (Glow):** `[Intensity: 0.75, Size: 24, Threshold: 0.8]`

---

## 🏛️ Environmental Staging & Architectural Detailing

### Composite Building Structures:
* **`[Structure 1]`**: `[e.g. Main Central Tower with dark metal foundation trim, glass windows, and neon roof borders]`
* **`[Structure 2]`**: `[e.g. Substation Alleyway with multi-level stairs and rooftop access]`

### Prop Staging Hierarchy:
* **Ground Level Props**: `[e.g. Sidewalk curbs, road tiles, tile patterns, manhole covers]`
* **Cover Props (Gameplay Hiding Spots)**: `[e.g. Wooden crates, metal oil drums, shipping containers, concrete barriers, dumpsters]`
* **Vertical Props**: `[e.g. Street lamps with PointLight, wall pipes, fire escapes, hanging neon signs]`

---

## 📦 Asset Placements & Spawns

### Spawns & Teleport Anchors:
* **SpawnPoint Position:** `[Vector3(x, y, z)]`
* **Seeker Cage Anchor:** `[Vector3(x, y, z)]`
* **Hider Teleport Points:** `[Array of Vector3(x, y, z)]`
