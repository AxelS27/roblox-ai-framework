# Map & World Design Overview

This folder registers all world, biome, map configurations, and sub-places for cross-world Experience loading.

## World Configuration Structure
* **[world-spec.md](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/map_design/templates/world-spec.md)**: Template for a single place/world/biome.

---

## 🛠️ Cross-World Experience Registry
`[Specify the Roblox Place IDs in your Universe. This guides the Place-Adaptive loading engine during startup.]`

* **Lobby/Menu Place ID:** `[Insert Place ID, e.g. 12345678]`
* **Main Game Server Place ID:** `[Insert Place ID, e.g. 87654321]`
* **Trading Hub Place ID:** `[Insert Place ID, e.g. 11223344]`

---

## 🛠️ Implementation Rules
1. **Place-Adaptive Code**: Do not write separate projects. The framework is unified. Place-specific logic must check `game.PlaceId` inside Service/Controller `Init()` methods to prevent loading unnecessary systems.
2. **Teleport Data**: Teleport Service parameters must be validated and sanitized upon player entry on the destination place server.
