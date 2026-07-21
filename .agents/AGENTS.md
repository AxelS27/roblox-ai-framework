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
      * **Extreme Technical Specification**: Each generated task must not be generic. It must detail the exact UI panels layouts, button slots, camera zoom focus targets/offsets, environment lighting properties, or audio/sfx parameters described in the GDD.
      * **Agile User Story Wrap**: Every task file must contain a clear, user-facing User Story (As a / I want to / So that) to establish the logical flow and player value.
      * **Mandatory Edit-Mode Staging Requirements**: Every task that implements or modifies a visual component (such as UI panels in `StarterGui`) or physical component (such as map models, lighting, or zones in `Workspace`/`ReplicatedStorage`) MUST include a mandatory, explicit requirement to physically build and stage those assets natively in Roblox Studio (Edit Mode via MCP) *before* any scripting or logic integration for that task is executed, ensuring the user can always inspect them visually in the viewport.
      * **Mandatory Mock Multiplayer Bot Testing Task**: The generated task list **MUST** include a dedicated task at the end of the roadmap (e.g., `Task XXX: Mock Multiplayer Bot Integration`) that sets up `MockPlayerService` and spawns autonomous, animated cover-seeking bots in Studio to verify the entire multiplayer round loop for solo development testing.
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
     - Technical systems specs and config variables -> `gameplay/` (creating `gameplay/system-name/README.md` and Luau config blueprints).
     - Badges -> `monetization/badges/README.md` & `rewards.md`.
     - Gamepasses & Dev Products -> `monetization/gamepasses/README.md` & `pricing.md`.
     - Map structure, level progression table, or biomes -> `map_design/` (writing `map_design/README.md` and dedicated files for EVERY single place registered in the Cross-World Registry—including Lobby/Menu, Trading Hubs, and individual worlds—at `map_design/worlds/[world-name].md` using `templates/world-spec.md`).
     - UI screens flow, responsive layouts, palettes -> `ui_ux/` (writing `ui_ux/design-system.md` and dedicated files for each UI screen/component at `ui_ux/components/[screen-name].md` using `templates/screen-spec.md`).
     - Custom mechanics (e.g. Weapons, Crafting, Game Modes) -> Create new specialized domain subfolders or markdown files inside `.agents/GDD/`.
   - **Mandatory User Stories**: EVERY individual UI component spec file and Map world spec file MUST contain its own clear User Story section (`As a ... / I want to ... / So that ...`) to define player intent and value.
   - Overwrite the empty template skeleton structures in the workspace with these formatted, actual game design specifications.
   - Report exactly which files were created or updated.
