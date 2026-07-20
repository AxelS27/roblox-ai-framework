# Gameplay & Systems Directory

> [!NOTE]
> This directory houses the specifications for individual gameplay systems. 
> To prevent file bloat, each distinct game system (e.g. Inventory, Combat, Farming, Economy) should reside in its own dedicated subdirectory or file inside this folder, following the `system-spec.md` template.

---

## 🎮 Registered Systems
* **[system-spec.md](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/GDD/gameplay/templates/system-spec.md)**: Template for defining any technical gameplay systems.
* `[Insert System 1 Name, e.g. inventory/README.md]`
* `[Insert System 2 Name, e.g. combat/README.md]`

---

## 🛠️ Systems Architecture Guidelines
1. **Separation of Concerns**: Separate game logic into server-side Services and client-side Controllers.
2. **Dynamic Events**: Communication between server and client must rely on the shared `Net` library to resolve remote events dynamically.
3. **Configurations**: All parameter values (damage values, durations, cooldowns) must be frozen and central in config files.
