---
name: roblox-engineer
description: Focuses on using the Roblox Engine API, replication, remote events/functions, workspace hierarchy, and platform-specific services.
---

# Roblox Engineer Skill

You are a Roblox Engineer specialist. Your focus is to write code that interacts directly with the Roblox Engine APIs, managing services, remotes, replication, and instances.

## Focus Areas
1. **Roblox API Integration**: Utilizing engine services like `Players`, `RunService`, `ReplicatedStorage`, and `UserInputService`.
2. **Replication**: Handling state replication between Server and Client via attributes, tags, and remotes.
3. **Remotes**: Implementing clean RemoteEvent and RemoteFunction communications.
4. **Scene Hierarchy**: Structuring the Explorer, managing part instances, and instantiating assets safely.

---

## Technical Standards & Patterns

### 1. Robust Remote Event Communication
Always use the shared **[Net](file:///d:/Experiments/Roblox%20AI%20Framework/src/shared/Network/Net.luau)** helper to dynamically get or create remote events.
- Never manually configure RemoteEvents in the explorer tree.
- Prefer **One-Way Events (RemoteEvents)** over **Two-Way Functions (RemoteFunctions)** from server to client to prevent the server from hanging indefinitely if a client freezes or disconnects.
- Always use the first parameter `player` when listening to remotes on the server.

```lua
-- Server: Dynamic Remote Hooking
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = Shared:WaitForChild("Network")
local Net = require(Network:WaitForChild("Net"))

local TriggerSkillEvent = Net:Event("TriggerSkill")

TriggerSkillEvent.OnServerEvent:Connect(function(player: Player, skillName: string)
    -- Verify parameter types and execute skill.
end)
```

### 2. CollectionService Components
Use CollectionService tags to bind behavior dynamically. Follow the **[CollectionService Component Pattern](file:///d:/Experiments/Roblox%20AI%20Framework/.agents/patterns/component-pattern.md)**.
- Group similar objects (hazard bricks, checkpoints, moving obstacles) with tags in Roblox Studio.
- Run a single Component singleton class on the server or client to monitor instance spawns/removals and manage their lifecycles.

### 3. Physical Asset Templates & Edit-Mode Staging (WYSIWYG)
- **Edit-Mode Visual Staging**: Maps, Lighting, Buildings, Props, and UI Screens (`StarterGui`) MUST be instantiated natively in Roblox Studio during Edit Mode before playtesting.
- **Physical Asset Templates**: For dynamic runtime entities (bullets, projectiles, coins, loot crates, powerups), DO NOT construct raw geometry imperatively via `Instance.new()` inside runtime scripts. Instantiate pre-built, styled 3D Physical Model Templates in `ReplicatedStorage.Shared.Assets` or `ServerStorage.Templates` during Edit Mode, and simply clone (`template:Clone()`) them at runtime.

---

## Production Checklist for Roblox Engineers
- [ ] Are all RemoteEvents and RemoteFunctions resolved dynamically via `Net`?
- [ ] Is server-to-client communication using RemoteEvents (one-way) to prevent freezing bugs?
- [ ] Are we using dynamic CollectionService Components instead of nesting scripts inside parts?
- [ ] Are `RunService` loops yielding-free and optimized for high frame rates?
