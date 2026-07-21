# Mock Player Testing System Pattern

---

## 📌 Overview
The **MockPlayerService** is an advanced testing subsystem designed to simulate real player interactions, characters, database profiles, and movement behaviors in Roblox Studio without needing to spin up heavy multi-client local servers.

---

## 🛠️ Implementation Standard (`MockPlayerService.luau`)

```lua
--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared:WaitForChild("Core"):WaitForChild("Registry"))

local MockPlayerService = {
    Name = "MockPlayerService",
    MockPlayers = {} :: { [string]: {
        UserId: number,
        Name: string,
        Character: Model,
        Active: boolean,
    } },
}

-- 1. Create Mock Player Data & Appearance
function MockPlayerService:CreateMockPlayer(name: string, userId: number, spawnLocation: CFrame)
    if not RunService:IsStudio() then return end -- Guard to prevent bots in live production servers
    
    local character = Instance.new("Model")
    character.Name = name
    character.Parent = workspace
    
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = character
    
    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 2, 1)
    rootPart.CFrame = spawnLocation
    rootPart.CanCollide = true
    rootPart.Parent = character
    character.PrimaryPart = rootPart

    -- Inject Mock Character Appearance
    task.spawn(function()
        local success, description = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(userId)
        end)
        if success and description then
            humanoid:ApplyDescription(description)
        end
    end)

    -- Register Mock Player profile in DataService
    local DataService = Registry:GetService("DataService")
    if DataService then
        -- Seed mock profile data for leaderboard & reward systems
        DataService:PlayerAdded({
            UserId = userId,
            Name = name,
            DisplayName = name,
        } :: any)
    end

    self.MockPlayers[name] = {
        UserId = userId,
        Name = name,
        Character = character,
        Active = true,
    }

    -- Start simple automated behavior loop
    self:StartBotAI(name)
end

-- 2. Simulate Bot Autonomous Movement (Testing Cover & Interactions)
function MockPlayerService:StartBotAI(name: string)
    local bot = self.MockPlayers[name]
    if not bot then return end

    task.spawn(function()
        local humanoid = bot.Character:WaitForChild("Humanoid") :: Humanoid
        local rootPart = bot.Character:WaitForChild("HumanoidRootPart") :: BasePart

        while bot.Active and bot.Character.Parent do
            task.wait(math.random(3, 8)) -- Wait random time before shifting position
            
            -- Find a random point within 40 studs to walk to
            local offset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
            local destination = rootPart.Position + offset
            
            -- Pathfind or direct walk to destination
            humanoid:MoveTo(destination)
        end
    end)
end

function MockPlayerService:RemoveAllMocks()
    for name, bot in self.MockPlayers do
        bot.Active = false
        if bot.Character then
            bot.Character:Destroy()
        end
        local DataService = Registry:GetService("DataService")
        if DataService then
            DataService:PlayerRemoving({ Name = name } :: any)
        end
    end
    table.clear(self.MockPlayers)
end

function MockPlayerService:Init()
    if RunService:IsStudio() then
        print("[Testing] MockPlayerService loaded. Use MockPlayerService:CreateMockPlayer() to spawn bots.")
    end
end

return MockPlayerService
```
