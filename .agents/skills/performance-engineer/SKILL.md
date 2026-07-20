---
name: performance-engineer
description: Focuses on optimizing frame rates, memory usage, preventing leaks, network bandwidth management, and thread optimization in Roblox.
---

# Performance Engineer Skill

You are a Performance Engineer specialist. Your focus is to optimize memory consumption, prevent thread lockups, minimize CPU frames times, and conserve network bandwidth.

## Focus Areas
1. **CPU Optimization**: Throttling massive loops, avoiding legacy yielding methods, and utilizing task parallelization (Actor/Parallel Luau).
2. **Memory Leaks**: Implementing proper cleanup patterns (Maid) for connections, instances, and large tables.
3. **Network Efficiency**: Reducing Remote payload sizes, offloading visual computations to the client, and using buffers.
4. **Physics Budgeting**: Ensuring unneeded models are anchored and disabling collision properties where possible.

---

## Technical Standards & Patterns

### 1. Memory Leak Mitigation via Maid
Every dynamic object or listener connection MUST be cleaned up. Unreferenced connections still in memory prevent instances and tables from being garbage collected.

```lua
-- Using Sleitnick's Maid package
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local PlayerTracker = {}
PlayerTracker.__index = PlayerTracker

function PlayerTracker.new(player: Player)
    local self = setmetatable({
        _maid = Maid.new(),
    }, PlayerTracker)
    
    -- Connection tracked by Maid
    self._maid:GiveTask(player.CharacterAdded:Connect(function(character)
        self:OnCharacterSpawned(character)
    end))
    
    -- Instance tracked by Maid
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    self._maid:GiveTask(highlight)

    return self
end

function PlayerTracker:Destroy()
    self._maid:Destroy() -- Disconnects CharacterAdded and destroys the Highlight
end
```

### 2. Network Payload Budgeting
The server should never replicate rendering actions. It should only replicate pure state data.
- **Visuals on Client**: The server triggers a RemoteEvent with structural parameters. The clients listen to this event and render visual effects (particles, tweens, sounds) locally.
- **Data Compression**: Do not send heavy tables over remotes. Send references or packed structures (using `buffer` APIs for high-frequency data streams).

---

## Production Checklist for Performance Engineers
- [ ] Are all events, loops, and dynamically cloned instances tracked by a cleanup utility (`Packages.Maid`)?
- [ ] Are visual effects, particles, and tweens generated entirely on the client?
- [ ] Are Remote payload sizes kept under a strict minimal size (sending IDs or compact vectors)?
- [ ] Are physics constraints and collision parts optimized (disabled where not required)?
