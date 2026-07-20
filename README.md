# 🚀 Roblox Vibescoding Framework

An **AI-Native, Agentic Roblox Game Development Framework** designed for seamless pair-programming between human game developers and AI coding agents via local MCP (Model Context Protocol).

---

## 💡 How The Framework Works

The **Roblox Vibescoding Framework** operates on a dual-layer architecture:

1. **Pure Luau Runtime Engine (`src/`)**: A single-entry, bootstrapped Roblox runtime using recursive module loaders, dynamic remote event resolution, and memory-safe object composition.
2. **AI Intent & Knowledge Layer (`.agents/` & `tasks/`)**: Domain-separated knowledge bases, specialist skill definitions, architectural patterns, and a file-based tasking engine that allow AI coding agents to understand, plan, format, and build complex game systems with extreme technical precision.

---

## ✨ Features & What This Framework Provides

### 1. ⚙️ Roblox Luau Runtime (`src/`)
* **Single-Entry Bootstrappers**: Server (`ServerScriptService.Server.Bootstrap`) and Client (`StarterPlayerScripts.Client.Bootstrap`) mount the entire game recursively. No stand-alone scripts cluttered across Roblox Explorer.
* **Recursive Loader (`Loader.luau`)**: Recursively discovers, requires, and manages two-stage initialization (`Init()` and `Start()`) for Services, Controllers, and CollectionService Components.
* **Dependency-Free Registry (`Registry.luau`)**: Central database providing dynamic runtime module resolution to prevent circular dependency deadlocks (`Registry:GetService("DataService")`).
* **Dynamic Remotes Management (`Net.luau`)**: Automatically creates and resolves `RemoteEvents` and `RemoteFunctions` on-demand without manual instantiation in Roblox Explorer.
* **Core Utilities & Packages**:
  * **`Maid`**: Trove/Maid memory cleanup to prevent memory leaks.
  * **`Signal`**: Pure Luau event emitter with thread safety.
  * **`Promise`**: Asynchronous execution handler.
  * **`Tables`**: Deepcopy, table freezing, and schema reconciliation utilities.
* **CollectionService Component System**: Dynamic behavior binding for tagged workspace instances (`ExampleComponent` on server, `ExampleClientComponent` for client visual effects).

---

### 2. 🧠 AI Intent Layer & Knowledge Base (`.agents/GDD/`)
A domain-separated **"One domain, one folder, one responsibility"** knowledge base optimized for AI agents to inspect specific context without token bloat:

* **`GDD/`**: Executive summary, core gameplay loops, target audience, player stories, and narrative/dialogue FSMs.
* **`gameplay/`**: Technical specs for gameplay mechanics (Combat, Inventory, Farming) and corresponding Luau config schemas.
* **`monetization/`**: Badges registry (`badges/`), unlock rewards (`rewards.md`), gamepasses (`gamepasses/`), and Robux pricing matrices (`pricing.md`).
* **`assets/`**: Pre-loading guidelines and separate registries for `animations/`, `audio/`, `models/`, and `vfx/`.
* **`map_design/`**: Level-based vs Open World specs, place IDs (Lobby, Main Game, Trade Hub), lighting properties (Ambient, Shadows), and post-processing effects.
* **`ui_ux/`**: Design system tokens (HSL/Hex palettes, typography, easing styles) and an ultra-detailed **UI Component Library** (`button.md`, `dialog.md`, `hotbar.md`, `progress-bar.md`, `card.md`, `input-field.md`, `slider.md`, `tab-bar.md`, `tooltip.md`).

---

### 3. 🎯 Specialist Agent Skills (`.agents/skills/`)
10 built-in domain skills equipping AI agents with specialist guidelines:
* 👾 **Game Designer**: Gameplay loops, progression curves, state machines.
* 🗺️ **Level Designer**: Zoning, map flow, environmental mechanics.
* 🎨 **UI Designer**: User experience, layouts, tween animations.
* 🏗️ **Software Architect**: System boundaries, loaders, package management.
* 💻 **Software Engineer**: Clean Luau, OOP metatables, SOLID principles.
* 🟦 **Roblox Engineer**: Engine APIs, RunService, dynamic networking.
* 🚀 **Performance Engineer**: Memory leak audits, Maid cleanup, network budgets.
* 🔒 **Security Engineer**: Zero Trust boundaries, remote sanitization.
* 💾 **Backend Engineer**: ProfileService DataStores, session locking, MemoryStores.
* 📝 **Technical Writer**: Architecture decision records (ADR) and Moonwave docs.

---

## ⚡ Custom Slash Commands

You can invoke these specialized commands directly in the chat window:

| Command | Action / Behavior |
| :--- | :--- |
| **`/get-context`** | Reads `AGENTS.md`, `task.md`, `tasks/README.md`, `.agents/GDD/`, and inspects the live **Roblox Studio Explorer tree** (ReplicatedStorage, ServerScriptService, StarterPlayerScripts) via MCP to synthesize a complete 360° overview of codebase, live Studio state, and active next steps. |
| **`/init-project`** | Executes `.agents/scripts/init-project.luau` inside your open Roblox Studio session via MCP (`execute_luau`), programmatically building the native folder and script tree in Roblox Studio Explorer. |
| **`/gdd [file | text]`** | Parses unstructured game design notes/drafts and maps them into the modular `.agents/GDD/` Knowledge Base (creating domain folders, config table blueprints, and component specs automatically). |
| **`/task`** | Analyzes GDD specifications to generate an ordered, file-based task roadmap (`tasks/XXX-name.md`) wrapped in Agile User Stories (*As a / I want to / So that*) with extreme technical specifications. Reconciles task status and executes step-by-step upon prompt (*"Kerjakan task 001"*). |

---

## 📁 Workspace Directory Layout

```
Roblox AI Framework/
├── .agents/                      <-- AI Context & Intent Layer Root
│   ├── AGENTS.md                 <-- Framework Rules & Custom Commands
│   ├── GDD/                      <-- AI-Readable GDD Knowledge Base
│   │   ├── GDD/                  <-- Concept & Lore
│   │   ├── gameplay/             <-- Gameplay Systems & Luau Configs
│   │   ├── monetization/         <-- Badges & Gamepasses
│   │   ├── assets/               <-- Animations, Models, Audio, VFX
│   │   ├── map_design/           <-- World Specs & Lighting
│   │   └── ui_ux/                <-- Design System & UI Components
│   ├── patterns/                 <-- Code Standard Markdown Patterns
│   ├── scripts/                  <-- Luau Native Scaffolder Scripts
│   └── skills/                   <-- 10 Specialist Domain Skills
│
├── tasks/                        <-- Workspace-Root Tasking Engine
│   ├── README.md                 <-- Master Task Board (To Do, In Progress, Done)
│   ├── task-blueprint.md.template<-- Task File Specification Blueprint
│   └── 001-sample-task.md        <-- Granular Task Files
│
└── src/                          <-- Roblox Luau Source Code
    ├── client/                   <-- Client Bootstrap, Controllers, Components
    ├── server/                   <-- Server Bootstrap, Services, Components
    └── shared/                   <-- Shared Core, Net, Configs, Packages, Utilities
```

---

## 🚦 Getting Started

1. Open your Roblox project in **Roblox Studio**.
2. Run the command **`/init-project`** in the AI chat window to build the bootstrapped code tree in Roblox Studio.
3. Import or draft your game concept using **`/gdd`**.
4. Generate your implementation roadmap by running **`/task`**.
5. Start building feature by feature: *"Kerjakan task 001"*!
