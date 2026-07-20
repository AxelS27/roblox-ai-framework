# Economy, Monetization & Progression Directory

This directory governs all details regarding monetization assets, pricing configurations, XP progression curves, and badges.

## Subdirectories
* **[badges/](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/monetization/badges/README.md)**: Game achievement badges, unlocking triggers, and rewards.
* **[gamepasses/](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/monetization/gamepasses/README.md)**: Gamepasses, Developer Products, pricing metrics.

---

## 🛠️ Global Economy Rules
1. **Zero-Trust Purchases**: All gamepass checks and dev product purchases must occur server-side.
2. **Deterministic Scaling**: Level formulas ($XP = f(Level)$) should be defined using deterministic math formulas inside configurations rather than large hardcoded arrays.
