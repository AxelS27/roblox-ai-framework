# Performance & Memory Optimization Pattern

---

## 📌 Overview
The **Performance Optimization Pattern** enforces strict memory management, spatial partitioning queries, and network budget constraints to ensure low-end mobile devices run at 60 FPS without crashing.

---

## 🛠️ Implementation Standards

### 1. Spatial Partitioning Queries (Replacing Legacy Touched)
Always use spatial query APIs instead of legacy `Touched` events for continuous zone monitoring.

```lua
local function getPlayersInZone(zonePart: BasePart): {Player}
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = { workspace:FindFirstChild("Characters") or workspace }

    local parts = workspace:GetPartsInPart(zonePart, overlapParams)
    local foundPlayers = {}

    for _, part in parts do
        local player = game:GetService("Players"):GetPlayerFromCharacter(part.Parent)
        if player and not table.find(foundPlayers, player) then
            table.insert(foundPlayers, player)
        end
    end

    return foundPlayers
end
```

### 2. Event Connection Cleanup via Maid / Trove
Every event connection or instance spawned dynamically on client or server MUST be registered to a `Maid` instance for clean disposal.

```lua
local maid = Maid.new()

-- Bind connection
maid:GiveTask(RunService.Heartbeat:Connect(function(dt)
    -- Frame logic
end))

-- When module or object is destroyed
function Object:Destroy()
    maid:DoCleaning() -- Automatically disconnects all events and destroys instances
end
```

### 3. Client-Side Render Delegation
Do not calculate particles, tweens, or UI animations on the server. Always broadcast state change events via `Net:FireAllClients()` and let each client render visual effects locally.
