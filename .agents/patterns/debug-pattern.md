# Developer Experience & Debugging Pattern (DX)

> **Standards for Developer Sandbox Zones, Test Rigs, and Secure Debug Panels**

---

## 📌 Overview
Developing Roblox games requires rapid testing loops. The **DebugService** (server) and **DebugController** (client) manage developer-only cheat consoles (e.g. adding stats, skipping timers) and physical testing dummies (Samsak) to ensure the Developer Experience (DX) is seamless and highly productive.

---

## 📐 1. Secured Developer Debug Console (HUD)
Never hardcode debug menus that regular players can access. The Debug Console must be strictly restricted:

```
  ┌────────────────────────────────────────────────────────┐
  │  🛠️ DEVELOPER SANDBOX CONSOLE                          │
  ├────────────────────────────────────────────────────────┤
  │  [ TIME ]   Skip Timer (Round)   [ Set Day ]   [ Set Night ]
  │  [ STATS ]  Give 1,000 DNA       [ Level Up ]  [ Toggle GodMode ]
  │  [ SPAWN ]  Spawn Fauna Dummy    [ Spawn Boss ] [ Spawn Nest ]
  └────────────────────────────────────────────────────────┘
```

1. **Security Guard Invariant**:
   * On initialization, `DebugService` must verify player authorization:
     ```luau
     local isOwner = (player.UserId == game.CreatorId)
     local isAdmin = (player:GetRankInGroup(YOUR_GROUP_ID) >= 250) -- Admin Rank
     ```
   * All debug RemoteEvents (e.g., `Net:Event("DebugCmd")`) must run this validation **on the server** before executing any commands to prevent exploiters from triggering debug cheats.
2. **Key Commands to Support**:
   * **Timer Control**: Force-skip active game loops, intermissions, or world event timers.
   * **State Control**: Instantly gain resource pools (e.g. DNA, XP, Coins) or toggle invincibility (God Mode).
   * **Spawner Control**: Trigger dynamic events or spawn rigs/fauna instantly at the cursor position.

---

## 🏗️ 2. In-World Testing Dummy (Samsak)
To test combat hits, animations, damage numbers, and DPS (Damage Per Second) calculations:
1. **Physical Staging**:
   * Stage a themed testing dummy Model (named `TestingDummy`) in `Workspace` or `ServerStorage.Templates`.
   * The dummy must contain a standard `Humanoid` and `Animator` to process combat knockbacks and states.
2. **Auto-Reset & DPS Billboard**:
   * Attach an `OverheadBillboardGui` showing:
     * Current Health (e.g., `100/100 HP`).
     * Last Hit Damage (e.g., `22 DMG`).
     * Calculated DPS (accumulated damage divided by active combat time).
   * **Auto-Reset Script**: When the dummy's HP drops below `20%`, heal it back to `100%` after a `2.0` second delay so it never dies during tests.

---

## 🛠️ Implementation Standard (`DebugService.luau`)

```lua
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Network"):WaitForChild("Net"))

local DebugService = {
    Name = "DebugService",
    AuthorizedUsers = {
        [game.CreatorId] = true, -- The game creator is always authorized
    }
}

-- 1. Security Check
function DebugService:IsAuthorized(player: Player): boolean
    -- In Roblox Studio local test, always authorize player1
    if RunService:IsStudio() then
        return true
    end
    
    return self.AuthorizedUsers[player.UserId] == true
end

function DebugService:Init()
    local debugCmdEvent = Net:Event("DebugCommand")

    -- 2. Secure Server-Side listener
    debugCmdEvent.OnServerEvent:Connect(function(player: Player, commandName: string, ...: any)
        if not self:IsAuthorized(player) then
            warn("[Security] Unauthorized debug attempt by player: " .. player.Name)
            return
        end

        local args = {...}
        print(string.format("[Debug] Dev %s executed: %s", player.Name, commandName))

        -- Execute Developer Actions
        if commandName == "GiveDNA" then
            local amount = args[1] or 100
            -- Code to add DNA to player.leaderstats or active profile goes here
            
        elseif commandName == "SkipTimer" then
            -- Trigger world loop service to skip active match clock
            
        elseif commandName == "ToggleGodMode" then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = math.huge
                    humanoid.Health = math.huge
                end
            end
        end
    end)
end

return DebugService
```
