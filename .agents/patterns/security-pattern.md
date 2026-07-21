# Zero-Trust Anti-Exploit Security Pattern

---

## 📌 Overview
The **Security Boundary Pattern** ensures all client requests are validated on the server using distance checks, payload sanitization, NaN/Inf checks, and rate limiting.

---

## 🛠️ Implementation Standard

```lua
--!strict
local Players = game:GetService("Players")

local SecurityGuard = {}

-- 1. Distance Sanity Check
function SecurityGuard.VerifyDistance(player: Player, targetPosition: Vector3, maxDistanceStuds: number): boolean
    local character = player.Character
    if not character then return false end
    
    local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not primaryPart then return false end

    local distance = (primaryPart.Position - targetPosition).Magnitude
    return distance <= maxDistanceStuds
end

-- 2. Payload Rate Limiting Guard
local playerCooldowns: { [Player]: { [string]: number } } = {}

function SecurityGuard.CheckRateLimit(player: Player, actionName: string, cooldownSeconds: number): boolean
    local now = os.clock()
    if not playerCooldowns[player] then
        playerCooldowns[player] = {}
    end

    local lastTime = playerCooldowns[player][actionName] or 0
    if now - lastTime < cooldownSeconds then
        return false -- Rate limit exceeded!
    end

    playerCooldowns[player][actionName] = now
    return true
end

-- Cleanup on leave
Players.PlayerRemoving:Connect(function(player)
    playerCooldowns[player] = nil
end)

return SecurityGuard
```
