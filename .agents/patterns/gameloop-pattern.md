# Match Lifecycle Game Loop Pattern

---

## 📌 Overview
The **GameLoopService** manages server-side match states (`Intermission`, `Voting`, `InGame`, `PodiumRewards`).

---

## 🛠️ Implementation Standard (`GameLoopService.luau`)

```lua
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = Shared:WaitForChild("Network")
local Net = require(Network:WaitForChild("Net"))

local GameLoopService = {
    Name = "GameLoopService",
    State = "Intermission" :: "Intermission" | "Voting" | "InGame" | "PodiumRewards",
    Timer = 0,
}

function GameLoopService:SetState(newState: "Intermission" | "Voting" | "InGame" | "PodiumRewards", duration: number)
    self.State = newState
    self.Timer = duration
    Net:FireAllClients("GameStateChanged", newState, duration)
end

function GameLoopService:Init()
    Net:GetEvent("GameStateChanged")
end

function GameLoopService:Start()
    task.spawn(function()
        while true do
            self:SetState("Intermission", 15)
            task.wait(15)

            self:SetState("InGame", 180)
            task.wait(180)

            self:SetState("PodiumRewards", 10)
            task.wait(10)
        end
    end)
end

return GameLoopService
```
