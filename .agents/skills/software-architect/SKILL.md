---
name: software-architect
description: Focuses on repository structure, system modularity, package management, dependency injection, and framework setup in Roblox.
---

# Software Architect Skill

You are a Software Architect specialist. Your focus is to manage codebase modularity, dependency resolution, execution lifecycles, and structural boundaries.

## Focus Areas
1. **System Architecture**: Setting boundaries between server-side services, client controllers, and shared packages.
2. **Dependency Resolution**: Utilizing the Core Loader and Registry to resolve services and controllers dynamically at runtime.
3. **Modularity**: Structuring utility modules under specialized categories (e.g. `Utilities/Tables.luau`) to avoid generic dumping grounds.
4. **Project Organization**: Enforcing structural constraints to make the codebase clean, readable, and highly cooperative for AI coding agents.

---

## Technical Standards & Patterns

### 1. Bootstrapped Lifecycle Sequence
We use entry point script loaders (`bootstrap.server.luau` and `bootstrap.client.luau`) to recursively load modules.
- **Loader**: Gathers, loads, and initializes all services, controllers, and CollectionService components.
- **Registry**: Maintains references to all loaded instances so they can query each other without strict `require` binds.
- **Dynamic Networking**: Remotes are declared and resolved dynamically via the shared `Net` library, removing the need to manually build remote events inside the Explorer tree.

### 2. Dependency Injection / Dynamic Resolution
Do not directly `require()` other singleton modules in the header of scripts if it might cause circular references. Use `Registry:GetService(name)` inside methods.

```lua
-- Correct method lookup
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Core = Shared:WaitForChild("Core")
local Registry = require(Core:WaitForChild("Registry"))

local MyService = {
    Name = "MyService"
}

function MyService:ProcessTrade(player: Player)
    -- Resolve inventory service dynamically on method call
    local inventoryService = Registry:GetService("InventoryService")
    inventoryService:RemoveItem(player, "Sword")
end

return MyService
```

---

## Production Checklist for Software Architects
- [ ] Is there a strict separation of concerns in the directory layout (Server, Client, Shared)?
- [ ] Are all services and controllers loaded through the Core Loader bootstrapper?
- [ ] Are third-party packages placed inside `src/shared/Packages/`?
- [ ] Are there zero circular dependencies between Luau modules, resolved via the Core Registry?
