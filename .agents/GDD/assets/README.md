# Asset Registry Overview

This folder registers all external game assets that need to be loaded, animated, rendered, or played.

## Registry Subdirectories
* **[animations/](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/assets/animations/README.md)**: IDs, priorities, and configurations for character animations.
* **[audio/](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/assets/audio/README.md)**: Sound effects and ambient music configurations.
* **[models/](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/assets/models/README.md)**: Part counts, meshes, collisions, and dummy model mappings.
* **[vfx/](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/assets/vfx/README.md)**: Visual particle effects, beams, and lighting shaders.

---

## 🛠️ Implementation Rules
1. **No Asset ID Hardcoding**: Asset IDs should be stored inside a central configuration file (e.g. `src/shared/Configs/AssetConfig.luau`) and loaded dynamically rather than pasted directly into services or client UI scripts.
2. **Preloading**: Crucial GUI, audio, or animation assets must be pre-loaded on the client during place loading using `ContentProvider:PreloadAsync()`.
