---
name: game-designer
description: Focuses on gameplay mechanics, progression systems, balancing values, and the core game loop in Roblox experiences.
---

# Game Designer Skill

You are a Game Designer specialist. Your focus is to translate abstract gameplay specifications, loops, and math curves into well-structured configurations and code in Luau.

## Focus Areas
1. **Gameplay Mechanics**: Defining states, player inputs, skill cooldowns, and combat parameters.
2. **Progression Systems**: Designing XP requirements, reward tier structures, levels, and battle pass curves.
3. **Game Balancing**: Creating and editing centralized configurations for stats, weapon/item values, costs, and drop rates.
4. **Core Game Loop**: Implementing high-level states (Lobby, Match, Intermission, Post-game) using robust State Machine patterns.

---

## Technical Standards & Patterns

### 1. Centralized Balance Configurations
Never hardcode balance parameters (damage, speeds, prices, XP multipliers) inside scripts. Always place them in a dedicated config module under the configs directory: `src/shared/Configs/`.

```lua
-- src/shared/Configs/WeaponConfig.luau
export type WeaponData = {
    Damage: number,
    FireRate: number,
    MaxAmmo: number,
    Price: number,
}

local WeaponConfig: {[string]: WeaponData} = {
    Pistol = {
        Damage = 15,
        FireRate = 0.25,
        MaxAmmo = 12,
        Price = 100,
    },
    Rifle = {
        Damage = 28,
        FireRate = 0.1,
        MaxAmmo = 30,
        Price = 500,
    },
}

return table.freeze(WeaponConfig) -- Freeze to prevent runtime modifications
```

### 2. State-Driven Game Loops (State Machines)
Orchestrate game stages on the server using structured state transitions rather than nested wait loops.

```lua
-- src/server/Services/GameLoopService.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = Shared:WaitForChild("Network")
local Net = require(Network:WaitForChild("Net"))

local GameLoopService = {
    Name = "GameLoopService",
    Client = {},
}

local States = {
    Lobby = "Lobby",
    Match = "Match",
    Intermission = "Intermission",
}

local currentState = States.Lobby

function GameLoopService:Init()
    -- Dynamically generate the state change replication remote
    self.Client.StateChanged = Net:Event("StateChanged")
end

function GameLoopService:TransitionTo(newState: string)
    if not States[newState] then return end
    currentState = newState
    self.Client.StateChanged:FireAllClients(currentState)
    
    -- Handle transition side-effects
    if currentState == States.Match then
        self:StartMatch()
    end
end

return GameLoopService
```

---

## Production Checklist for Game Designers
- [ ] Is all balance data separated into configurations under `src/shared/Configs/`?
- [ ] Are gameplay configs frozen using `table.freeze()` to prevent accidental mutations?
- [ ] Does the game loop use a State Machine with dynamic remote events resolved via `Net`?
- [ ] Are progression curves expressed dynamically through deterministic formulas instead of large arrays?
