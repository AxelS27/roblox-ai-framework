# Roblox Vibescoding Framework - AI Context Engine

Welcome to the **Roblox Vibescoding Framework**. This workspace is an AI-native codebase designed for agentic pair-programming. It structures context, skills, coding patterns, and workflows under `.agents/` so the AI assistant behaves as an elite Roblox software developer.

---

## Workspace Structure

The workspace is organized into two primary segments:
1. **Roblox Runtime (`src/`)**: Pure Luau systems using a bootstrapped, single-entry registry architecture.
2. **AI Intent Layer (`.agents/`)**: Specialized guidelines, coding patterns, and operational workflows for the AI.

```
d:\Experiments\Roblox AI Framework\
├── .agents/                      <-- AI Context & Rules Root
│   ├── AGENTS.md                 <-- Root Context & Intent Layer
│   ├── skills/                   <-- Specialist domain instructions
│   ├── patterns/                 <-- Markdown code patterns (Read before writing)
│   └── workflows/                <-- Step-by-step development procedures
│
└── src/                          <-- Roblox Luau Source
    ├── client/                   <-- Client-side bootstrap and controllers
    ├── server/                   <-- Server-side bootstrap and services
    └── shared/                   <-- Shared Core, Networking, Configs, Packages
```

---

## Local Specialist Skills (`.agents/skills/`)

This workspace defines 10 specialized skills. The active agent must read the corresponding `SKILL.md` before starting work in their respective areas:

- 👾 **[Game Designer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/game-designer/SKILL.md)**: Gameplay loops, progression, stats.
- 🗺️ **[Level Designer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/level-designer/SKILL.md)**: Zoning, map flow, environmental mechanics.
- 🎨 **[UI Designer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/ui-designer/SKILL.md)**: UX, layouts, tween animations.
- 🏗️ **[Software Architect](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/software-architect/SKILL.md)**: Module loaders, dependencies, boundaries.
- 💻 **[Software Engineer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/software-engineer/SKILL.md)**: Clean Luau, OOP, types, SOLID principles.
- 🟦 **[Roblox Engineer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/roblox-engineer/SKILL.md)**: Remotes, RunService, Workspace.
- 🚀 **[Performance Engineer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/performance-engineer/SKILL.md)**: Trove/Maid cleanup, memory leak audits, network budgets.
- 🔒 **[Security Engineer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/security-engineer/SKILL.md)**: Zero Trust, type guards, parameter checks.
- 💾 **[Backend Engineer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/backend-engineer/SKILL.md)**: DataStore, ProfileService session locking, MemoryStores.
- 📝 **[Technical Writer](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/skills/technical-writer/SKILL.md)**: ADRs, Moonwave docstrings, changelogs.

---

## Code Patterns (`.agents/patterns/`)

Always adhere to these architectural patterns when writing code. **Do not use raw templates; reference these standards:**

* **[Luau OOP Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/oop-pattern.md)**: metatable composition and Sleitnick `Maid` memory tracking.
* **[Server Service Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/service-pattern.md)**: Server singletons and initialization lifecycles.
* **[Client Controller Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/controller-pattern.md)**: Client singletons, UI/FX isolation, and remote calls.
* **[CollectionService Component Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/component-pattern.md)**: Dynamic behavior bound to tagged Workspace parts (CollectionService).
* **[Camera State Machine Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/camera-pattern.md)**: Client camera mode state machine (1st Person, 3rd Person, Viewport Focus, Drone Cinematic orbit).
* **[Audio System Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/audio-pattern.md)**: BGM cross-fading, UI sound effects, and spatial 3D audio.
* **[Toast Notification Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/notification-pattern.md)**: Client toast notifications, alerts, and banner queues.
* **[Cross-Platform Input Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/input-pattern.md)**: ContextActionService PC, Mobile, and Console control unification.
* **[Visual Effects (VFX) Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/vfx-pattern.md)**: Client-side particle emissions, hit sparks, and Debris cleanup.
* **[Match Lifecycle Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/gameloop-pattern.md)**: Server match state machine (Intermission -> Voting -> InGame -> Podium).
* **[Monetization & Store Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/store-pattern.md)**: Gamepass verification and ProcessReceipt Developer Product handling.
* **[Data Persistence Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/data-pattern.md)**: ProfileService session locking, auto-reconciliation, and DataStore fallback.
* **[Zero-Trust Security Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/security-pattern.md)**: Rate limiting, payload sanitization, NaN/Inf checks, and distance validation.
* **[Performance & Memory Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/performance-pattern.md)**: Mobile memory optimization, spatial partitioning queries, and render delegation.
* **[Loading State & Preloading Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/loading-pattern.md)**: Boot asset preloading, universe teleport overlays, and map swap transition curtains.
* **[Mock Player Testing Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/mock-player-pattern.md)**: Autonomous bot simulation, profile database injection, and multiplayer test mocking in Studio.
* **[Lighting System Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/lighting-pattern.md)**: Atmospheric technology, skybox swapping, and post-processing tween transitions (`Atmosphere`, `Sky`, `Bloom`, `DepthOfField`, `SunRays`, `ColorCorrection`).
* **[UI Layout & Coordination Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/ui-pattern.md)**: Standard UI scaling, Z-Index conventions, and native Roblox Safe Zones.
* **[Developer Debugging Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/debug-pattern.md)**: Secure developer command console, in-world testing dummy (Samsak), and sandbox testing map setup.

---

## Core Framework Constraints

1. **Dynamic Remotes Management**: Do not instantiate remote assets in the Roblox Explorer. Use the shared **[Net](file:///d:/Experiments/Roblox%20AI%20Framework/src/shared/Network/Net.luau)** library to dynamically create and hook Events and Functions on demand.
2. **Single-Entry Bootstrappers**: All server and client modules are loaded recursively via the **[Loader](file:///d:/Experiments/Roblox%20AI%20Framework/src/shared/Core/Loader.luau)** and cached in the **[Registry](file:///d:/Experiments/Roblox%20AI%20Framework/src/shared/Core/Registry.luau)**. Never execute stand-alone scripts in the workspace.
3. **Third-Party Packages**: Crucial dependencies (`Maid`, `Signal`, `Promise`) reside inside `src/shared/Packages/` for easy hot-swapping.
4. **Zero Trust boundaries**: All remote calls must be sanitized by type checks, NaN checks, and distance validations on the server.
5. **No Dumping Grounds**: Do not place generic code inside `Utils`. Split them into granular modules under `Utilities/` (e.g. `Utilities/Tables.luau`).
6. **Senior Commenting Rules**: Write self-documenting code (expressive naming, clean functions). Do NOT write redundant comments that echo the code (e.g. `-- checking if nil`). Document public API surfaces using LDoc/Moonwave syntax, and only write internal comments to explain the "Why" (engine workarounds, non-obvious logic) rather than the "What".
7. **Mandatory Edit-Mode Visual Staging (WYSIWYG)**: Maps, Lighting, Buildings, Props, and UI Screens (`StarterGui`) MUST be instantiated and built natively in Roblox Studio during Edit Mode (via MCP `execute_luau`) before playtesting, so everything can be inspected and monitored visually in the Studio Viewport without needing to hit F5 first.
8. **Physical Asset Templates & Template Cloning**: For items spawned dynamically at runtime (e.g. bullets, projectiles, coins, powerups, crates, loot drops), DO NOT construct raw geometry imperatively via `Instance.new()` inside runtime scripts. Instead, instantiate pre-built, styled 3D Physical Model Templates into `ReplicatedStorage.Shared.Assets` or `ServerStorage.Templates` during Edit Mode, and simply clone (`template:Clone()`) them at runtime.
9. **Explicit Design Clarification & Genius Game Developer Fallback**: When ingesting GDD drafts or designing mechanics, if there are underspecified requirements, ambiguities, or design choices, ALWAYS ask the user first for explicit clarification. If the user defers or asks the AI to decide, fallback to the mindset of an **Elite, Genius Roblox Game Developer & Designer**, recommending and choosing the coolest, highest-retention, and most visually stunning options for player enjoyment.
10. **High-Fidelity Styled 3D Rigs (No Plain Blocks)**: For creature rigs staged in `ReplicatedStorage.Shared.Assets.SpeciesRigs`, DO NOT build simple grey parts/blocks. Rigs must contain bone joint hierarchies connected via `Motor6D`, customized styled mesh parts or visual assemblies, and a themed primary color palette (e.g., crimson chitin for Ant, gray fur for Wolf, obsidian scales for Dragon) to ensure the game looks visually premium.
11. **UI Placement Coordination & Roblox Native UI Integration**: All UI components (both custom and native Roblox elements) must be explicitly coordinated in layout to prevent clashing or overlapping. (1) **Roblox Native Safe Zones**: Respect the top-right corner for native `leaderstats` and top-left for the native Chat UI. (2) **Relocation & Customization**: If custom UI components are placed in standard native positions, you must programmatically relocate or toggle the native UI using `StarterGui:SetCoreGuiEnabled` or `TextChatService` settings (e.g. moving the chat window to bottom-left/bottom-right if top-left is used by custom HUD). (3) **Layout Exclusion**: If player vitals are placed at the bottom-left, toast notifications must be positioned elsewhere (e.g. middle-left or top-center) with clean Z-Index margins. (4) **Premium Glassmorphism & Anti-Overlap Invariant**: Every UI frame must use a frosted glass aesthetic (rounded corners via `UICorner`, semi-transparent backing, subtle white `UIStroke` border outlines), gradient fills (no solid flat colors) for progress bars, and strict layout separation margins (minimum `40` pixels vertical gap) to permanently prevent overlap bugs (such as alerts clashing on top of player health/hunger metrics). (5) **Interactive Button Audio Feedback**: Every single interactive button in any custom ScreenGui MUST play a subtle hover sound when hovered and a select click sound when clicked (using the centralized `AudioController` auto-bindings) to ensure satisfying sensory response.
12. **Robust Morph Animation & Rig Replication**: Locomotion animations (Idle, Walk, Run, Flight) MUST play correctly after character morphing. Ensure that when swapping character rigs: (1) Parent an `Animator` object inside the new `Humanoid`, (2) Clone and parent a client-side wrapper `Animate` script to hook locomotion tracks, and (3) Properly register animations via `Humanoid.Animator:LoadAnimation()`.
13. **Mandatory New Player Onboarding (Tutorial & Markers)**: Include a new player onboarding overlay or starter quest guide on first spawn (e.g., a small HUD Quest Widget: *"Goal: Eat 5 Berries (0/5) to Evolve"*), and place simple 3D green highlights or marker arrows pointing to nearby flora food sources so new players immediately understand how to play.
14. **Roblox Creator Marketplace (Toolbox) Asset Ingestion & Auditing**: You may search and insert high-quality assets (3D creature rigs, environmental props, audio tracks, sound effects) from the Roblox Creator Marketplace/Toolbox. However, you MUST strictly audit all imported models: (1) Immediately delete all embedded scripts (`Script`, `LocalScript`, `ModuleScript`) to remove potential backdoors or viruses. (2) Strip out unwanted components, duplicate UI frames, or unnecessary physics constraints. (3) Preserve only clean mesh parts, Motor6D joint structures, attachments, sounds, and textures before parenting them to `ReplicatedStorage.Shared.Assets`.
15. **High-Fidelity Level Design, Non-Flat Topography & Non-Generic Scattering (Toolbox Integration)**: All map environments staged in Roblox Studio MUST have natural terrain elevation (hills, valleys, riverbeds—never flat baseplates). When generating vegetation (trees, rocks, flora, environmental props, audio tracks), you are encouraged to search and insert these models/assets from the Roblox Creator Marketplace/Toolbox per **Constraint 14**. DO NOT duplicate a single model statically. Select 3-4 visual model variants from the Toolbox, audit/sanitize them, scatter them dynamically, and randomize their orientation (`CFrame.Angles(0, math.rad(math.random(0, 360)), 0)`) and scale factors (`0.8` to `1.3` range). Avoid Z-fighting (overlapping parallel parts flickering) by applying a small offset (minimum `0.02` studs) to intersecting parts. Detail environments with spatial 3D sounds (water flowing, wind, bird calls) to make the map immersive and alive.
16. **Custom Mobile HUD Layout & Comfort UX**: When developing cross-platform support, DO NOT use unstyled default `ContextActionService` touch buttons for mobile/iPad players. Instead, you must design a custom Mobile Action HUD (Sprint toggle, Dash/Roll, Jump, and active skills) placed in an arc layout within the bottom-right safe zone. Touch buttons must use premium feedback scaling (UIAnimate) and display clean radial cooldown sweeps when skills are on cooldown.
17. **Strict Functional Completeness Invariant (No Fake Mockups)**: Every UI screen, HUD widget, store/shop menu, and backend system implemented MUST be 100% functional. Writing empty UI grids with non-functioning buttons, hardcoding static mock values on the client without proper server synchronization, or creating hollow features that do not affect the gameplay or save state is strictly FORBIDDEN. All shop purchase buttons must trigger real Roblox purchase prompts (Gamepass/Developer Product), verified on the server via `MarketplaceService` callbacks, and grant actual in-game rewards. Every task completion is blocked until unit tests and manual playtesting confirm end-to-end functionality.
18. **Interactive Menu Trigger & In-World Integration Standards (No Keyboard Lockouts)**: Forcing players to use keyboard hotkeys (like pressing `B` for Shop or `M` for Map) to open panels is strictly FORBIDDEN, as it breaks Mobile/iPad controls and ruins immersion. All menus must be accessible via: (1) **HUD Navigation Toolbar**: A unified sidebar containing prominent frosted circle buttons (`50x50`px) with clear icons for mouse/touch access. (2) **Physical Map Interaction**: Important systems (like Shops or Trading) must have themed physical booths or NPCs staged in the map during Edit Mode. Approaching these nodes triggers a descriptive `ProximityPrompt` that opens the UI panel. UI panels must automatically close if the player walks more than `15` studs away from the in-world node. Keyboard keybinds are strictly secondary shortcuts for PC power-users.

---

## Custom Agent Commands

Any AI assistant reading this workspace must handle the following commands directly in the chat:

1. **`/get-context`**: 
   - Read [AGENTS.md](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/AGENTS.md), the current task checklist [task.md](file:///C:/Users/farre/.gemini/antigravity/brain/72460545-d628-47ad-ae4b-cb3f39cbb400/task.md), the master task index [tasks/README.md](file:///d:/Experiments/Roblox%20AI%20Framework/tasks/README.md), and all active Game Design Documents under `.agents/GDD/`.
   - **Live Studio Inspection**: Query the active Roblox Studio session via `roblox-studio` MCP tools (e.g., `get_studio_state` or `search_game_tree`) to inspect the live naming hierarchy of `ReplicatedStorage`, `ServerScriptService`, `StarterPlayerScripts`, and `Workspace`.
   - Provide a concise summary of the framework architecture, live Roblox Studio explorer tree status, coding rules, game design context (overview, systems, badges, ui/ux), current completion status, and active next steps.

2. **`/init-project`**:
   - Read [init-project.luau](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/scripts/init-project.luau).
   - Run the Luau scaffolder script inside the active Roblox Studio instance via the `execute_luau` MCP tool (using `datamodel_type = "Edit"`).
   - Confirm that all directories, scripts, and modules have been initialized natively in the Roblox Studio Explorer tree.

3. **`/task`**:
   - Scan the `tasks/` directory at the project root and all design documents inside `.agents/GDD/`.
    - **Initial Generation**: If no tasks exist, generate a sequential, highly granular (one-by-one) roadmap of implementation tasks. Create each task as a separate file at `tasks/XXX-name.md` using the structure in [task-blueprint.md.template](file:///d:/Experiments/Roblox%20AI%20Framework/tasks/task-blueprint.md.template). Write a master task index at [README.md](file:///d:/Experiments/Roblox%20AI%20Framework/tasks/README.md) showing all tasks under the "To Do" section.
      * **Exhaustive GDD Mapping Invariant**: NEVER generate high-level or summary tasks. Every single `.md` file in `.agents/GDD/` (maps, UI screens, combat matrix, mutations, world disasters, soundscapes, camera, mobile controls, shop catalog) MUST be mapped to dedicated, hyper-detailed task files.
      * **Extreme Technical Specification & GDD Value Fidelity**: Each task file MUST copy and detail exact RGBA/Color3 values, UI frame layouts, button keybinds, species scale multipliers, camera distance targets, skill damage numbers, status effect durations, sound asset IDs, and 3D rig template paths **if and only if they are explicitly defined in the GDD**. If a specific value (like a color code or offset) is NOT explicitly specified in the GDD, do NOT invent arbitrary hardcoded values; reference the central GDD design tokens or describe the functional visual requirement.
      * **Strict 5-Phase Task Generation Order**: The generated task roadmap **MUST ALWAYS** follow this exact sequential phase ordering:
        - **Phase 1: Physical 3D Map & World Geometry Staging**:
          * Task 001: Map Geometry & Biomes Staging (Building physical terrain, landmarks, sub-locations, spawns, and tagged zones directly in `Workspace.CurrentMap` via MCP Edit Mode).
          * Task 002: Physical Asset Templates & Rigs Staging (Building pre-styled 3D creature rigs, flora nodes, carcass props, nest base, and crystal templates directly in `ReplicatedStorage.Shared.Assets` via MCP Edit Mode per Rule 8).
        - **Phase 2: Lighting, Skybox & Atmospheric Setup**:
          * Task 003: Lighting, Atmosphere & Post-Processing (Setting up Future lighting technology, Atmosphere, Sky, Bloom, DepthOfField, SunRays, and ColorCorrectionEffect in `Lighting` via MCP Edit Mode).
        - **Phase 3: UI Screens & HUD Visual Layout Staging (1 Task per UI Screen/Component Spec)**:
          * Separate staging tasks for every UI spec file in `ui_ux/components/`: Survival HUD (vitals, skill hotbar, and Mobile/iPad Touch Action Buttons layout - including Dash/Roll, Sprint, Jump, and Skill buttons with radial cooldown layers), Evolution Tree Menu (3D ViewportFrame & tier tree), Territory & Nest Panel (party list & nest storage grid), Shop & Emote Wheel Menu (5 Gamepasses & radial wheel), Toast Notifications & Overhead Cards (StarterGui.ToastNotificationGui & OverheadBillboardGui), and Preloader Loading Screen. (Note: NO custom leaderboard UI; use Roblox native top-right `leaderstats`).
        - **Phase 4: Gameplay Systems & Backend Services (1 Task per System Domain)**:
          * Separate Luau implementation tasks for: Core Framework Bootstrappers & Net Remotes, Native Roblox Leaderstats (`Player.leaderstats` folder with DNA, Kills, Species), Cross-Platform Mobile & Touch Input Controller, Vitals Engine & Ecosystem Fauna Spawner, Evolution & Mutation Progression System, Action Combat & Skill Engine, Dynamic World Events & Ecosystem Bosses, Hunting Party & Nest Territory Buffs, Dynamic Species Camera Controller, Spatial Audio & Biome Soundscape System, Client VFX & Particle Emitter Controller, and DataStore ProfileService & DevProduct/Gamepass Verification.
        - **Phase 5: Mock Multiplayer Bot Integration**:
          * Final Task: `MockPlayerService` autonomous bot simulation suite (10-20 bots, state machine, stress testing with zero errors in Studio).
    - **Reconciliation**: If tasks already exist, preserve the "Completed" task history. Reconcile the pending tasks under "To Do" with any new GDD context, updating existing files or adding new ones.
    - **Execution**: When instructed by the user (e.g., "Execute task 001"), move the task to "In Progress" in `tasks/README.md` and the task file, read its specifications, perform the code changes, and execute the **Professional SE Testing Protocol**:
      * **Unit/Integration Testing**: Run Luau unit testing scripts in Roblox Studio using MCP `execute_luau`.
      * **Visual & Scene Hierarchy Checks**: Inspect `StarterGui` or `Workspace` via tree search tools to verify staged UI and physical map assets.
      * **Roblox Studio Console Log Audit**: Trigger playtesting via MCP `start_stop_play` (if testing runtime logic), wait 3-5 seconds, and invoke MCP `get_console_output` to retrieve recent logs.
      * **Zero-Error Invariant Constraint**: The captured console logs **MUST contain exactly 0 red error traces or warn stack traces** originating from the modified or created modules. If errors are found, the task is NOT complete; revert status, fix code, and re-test.
      * Mark it as "Completed" in both `tasks/README.md` and the task file only upon a clean console log verification, and paste the log snippet as proof.

4. **`/gdd`**:
   - Receive input via `/gdd [file_path]` or `/gdd [raw pasted text]`.
   - **Parsing & Mapping**: If a file path is provided, read the file. Parse the unstructured draft text and map the information into the modular `.agents/GDD/` documents:
     - Concepts, loops, target audience, and user stories -> `GDD/overview.md`.
     - Technical systems specs and config variables -> `gameplay/` (creating a comprehensive `gameplay/master-systems-spec.md` with complete formulas, drain rates, thresholds, and species combat matrices, plus sub-domain `gameplay/system-name/README.md` Luau config blueprints).
     - Badges -> `monetization/badges/README.md` & `rewards.md`.
     - Gamepasses & Dev Products -> `monetization/gamepasses/README.md` & `pricing.md`.
     - Map structure, level progression table, or biomes -> `map_design/` (writing `map_design/README.md` and dedicated files for EVERY single place registered in the Cross-World Registry—including Lobby/Menu, Trading Hubs, and individual worlds—at `map_design/worlds/[world-name].md` using `templates/world-spec.md`).
     - UI screens flow, responsive layouts, palettes -> `ui_ux/` (writing `ui_ux/design-system.md` and dedicated files for each UI screen/component at `ui_ux/components/[screen-name].md` using `templates/screen-spec.md`).
     - Custom mechanics (e.g. Weapons, Crafting, Game Modes) -> Create new specialized domain subfolders or markdown files inside `.agents/GDD/`.
    - **Mandatory Comprehensive User Stories**: EVERY document requiring User Stories (UI component specs, world specs, character/ability specs, PRDs, etc.) MUST contain **as many User Stories as possible (10, 15, 20+ or more, without upper limit)** covering all diverse POVs (New Player, Veteran, Casual, Mobile/iPad, PC, Admin, Gamepass Buyer), states (normal, combat, disconnected, low resource, full inventory), and edge cases/failure modes. Avoid brief placeholders.
   - Overwrite the empty template skeleton structures in the workspace with these formatted, actual game design specifications.
   - Report exactly which files were created or updated.
