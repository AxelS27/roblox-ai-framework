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
local CollectionService = game:GetService("CollectionService")

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

-- 1. Create Mock Player Character & Bind Standard Animations
function MockPlayerService:CreateMockPlayer(name: string, userId: number, spawnLocation: CFrame)
    if not RunService:IsStudio() then return end
    
    -- Spawn a standard character model structure (or clone a pre-rigged R15 character template)
    local characterTemplate = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):FindFirstChild("CharacterTemplate")
    local character: Model
    
    if characterTemplate then
        character = characterTemplate:Clone() :: Model
    else
        character = Instance.new("Model")
        local humanoid = Instance.new("Humanoid")
        humanoid.Parent = character
        
        local rootPart = Instance.new("Part")
        rootPart.Name = "HumanoidRootPart"
        rootPart.Size = Vector3.new(2, 2, 1)
        rootPart.Parent = character
        character.PrimaryPart = rootPart
    end

    character.Name = name
    character.PrimaryPart.CFrame = spawnLocation
    character.Parent = workspace
    
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid

    -- Load Character Outfit/Appearance from Roblox Web API
    task.spawn(function()
        local success, description = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(userId)
        end)
        if success and description then
            humanoid:ApplyDescription(description)
        end
    end)

    -- Inject Standard Player Animate Script (Replicates normal running, idle, and jump motions)
    local animateScript = character:FindFirstChild("Animate") or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):FindFirstChild("AnimateScript")
    if animateScript then
        local clone = animateScript:Clone()
        clone.Disabled = false
        clone.Parent = character
    end

    -- Register Mock Player profile in DataStore / DataService
    local DataService = Registry:GetService("DataService")
    if DataService then
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

    -- Start Goal-Driven Cover-Seeking Bot AI
    self:StartBotAI(name)
end

-- 2. Simulate Bot Autonomous Hiding & Chasing (Pathfinding to Cover Tags)
function MockPlayerService:StartBotAI(name: string)
    local bot = self.MockPlayers[name]
    if not bot then return end

    task.spawn(function()
        local humanoid = bot.Character:WaitForChild("Humanoid") :: Humanoid
        local rootPart = bot.Character:WaitForChild("HumanoidRootPart") :: BasePart

        while bot.Active and bot.Character.Parent do
            task.wait(math.random(4, 10)) -- Delay before moving to new cover

            -- Query environment for parts tagged with "CoverProp" or "HidingSpot"
            local coverSpots = CollectionService:GetTagged("CoverProp")
            local targetDestination: Vector3? = nil

            if #coverSpots > 0 then
                -- Choose a random cover spot near the bot to pathfind to
                local randomSpot = coverSpots[math.random(1, #coverSpots)] :: BasePart
                targetDestination = randomSpot.Position
            else
                -- Fallback to random wander within 50 studs
                local offset = Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
                targetDestination = rootPart.Position + offset
            end

            if targetDestination then
                -- Generate path using PathfindingService to navigate around solid walls
                local path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true,
                })
                
                local success, errorMessage = pcall(function()
                    path:ComputeAsync(rootPart.Position, targetDestination)
                end)

                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    for _, waypoint in ipairs(waypoints) do
                        if not bot.Active or not bot.Character.Parent then break end
                        
                        -- Handle Jumping through obstacles
                        if waypoint.Action == Enum.PathWaypointAction.Jump then
                            humanoid.Jump = true
                        end
                        
                        humanoid:MoveTo(waypoint.Position)
                        humanoid.MoveToFinished:Wait()
                    end
                else
                    -- Direct line walk if pathfinding fails
                    humanoid:MoveTo(targetDestination)
                    humanoid.MoveToFinished:Wait()
                end
            end
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
        print("[Testing] MockPlayerService loaded with Pathfinding cover search & Animate controllers.")
    end
end

return MockPlayerService
```
