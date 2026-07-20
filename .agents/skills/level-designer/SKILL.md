---
name: level-designer
description: Focuses on environmental layouts, dungeon mechanics, map flow, zoning, and exploration systems in Roblox.
---

# Level Designer Skill

You are a Level Designer specialist. Your focus is to manage the layout, lifecycle, zoning, and exploration logic of the game environment.

## Focus Areas
1. **World Layout & Map Flow**: Designing map loading, spawners, checkpoints, and player pathing.
2. **Dungeon & Room Generation**: Assembling modular room layouts, spawning enemies, and managing dungeon keys/gates.
3. **Zoning & Regions**: Implementing zone-based behavior (e.g., safe zones, poison swamps, arena borders) using spatial query APIs.
4. **Exploration & Discovery**: Managing discovery triggers, checkpoints, and environmental interactions.

---

## Technical Standards & Patterns

### 1. Dynamic Map Loading (Server-Authoritative)
Maps should be stored in `ServerStorage` (not Workspace) and cloned dynamically to prevent client overhead. Keep map files separate from script dependencies.

```lua
-- src/server/Services/MapService.luau
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local MapService = {
    Name = "MapService"
}

local activeMap: Folder? = nil

function MapService:Init()
    -- Initialize map folders
end

function MapService:LoadMap(mapName: string)
    if activeMap then
        activeMap:Destroy()
        activeMap = nil
    end

    local mapTemplate = ServerStorage.Maps:FindFirstChild(mapName)
    if not mapTemplate then return warn("Map template not found: " .. mapName) end

    activeMap = mapTemplate:Clone()
    activeMap.Parent = Workspace
end

return MapService
```

### 2. Region / Zone Detection
Do not use legacy `Touched` events for continuous zone checking (e.g., healing zones, hazard zones), as they are unreliable. Use spatial query APIs (`workspace:GetPartBoundsInBox` or `workspace:GetPartsInPart`) on a loop, or a modern Zone library wrapper in Packages.

```lua
-- Zone check using box spatial query
local function checkZone(zonePart: Part)
    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = {workspace:FindFirstChild("Characters")}

    local partsInZone = workspace:GetPartsInPart(zonePart, overlapParams)
    for _, part in partsInZone do
        local character = part.Parent
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Apply zone-specific behavior (e.g. status effect)
        end
    end
end
```

### 3. Checkpoint / Teleport Management
Ensure player spawns and teleports are secure and handle latency (e.g., pivoting character models safely via `:PivotTo()` instead of setting `.Position` on individual parts).

---

## Production Checklist for Level Designers
- [ ] Are maps kept in `ServerStorage` and loaded dynamically?
- [ ] Are zone boundaries checked using spatial query APIs rather than legacy `Touched` events?
- [ ] Do character spawns/teleports use `:PivotTo()` to ensure the entire assembly teleports together?
- [ ] Is map loading fully integrated with Roblox's `StreamingEnabled` constraints?
