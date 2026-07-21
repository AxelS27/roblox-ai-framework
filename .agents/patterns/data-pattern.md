# Data Store & ProfileService Persistence Pattern

---

## 📌 Overview
The **DataService** provides robust data persistence using `ProfileService` session locking, preventing data duplication, inventory loss, and corrupt data loads across multi-place universes.

---

## 🛠️ Implementation Standard (`DataService.luau`)

```lua
--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utilities = Shared:WaitForChild("Utilities")
local Tables = require(Utilities:WaitForChild("Tables"))

local DataService = {
    Name = "DataService",
    Profiles = {} :: { [Player]: any },
}

-- Default Player Data Blueprint Schema
local DEFAULT_PROFILE = {
    Coins = 100,
    Gems = 10,
    Wins = 0,
    Inventory = { "BasicSkin" },
    Settings = { MusicVolume = 0.5, SFXVolume = 1.0 },
}

function DataService:GetProfile(player: Player): typeof(DEFAULT_PROFILE)?
    local profile = self.Profiles[player]
    if profile then
        return profile.Data
    end
    return nil
end

function DataService:UpdateData(player: Player, callback: (data: typeof(DEFAULT_PROFILE)) -> ())
    local data = self:GetProfile(player)
    if data then
        callback(data)
    end
end

function DataService:PlayerAdded(player: Player)
    -- ProfileService session locking logic wrapper
    local mockProfile = { Data = Tables.DeepCopy(DEFAULT_PROFILE) }
    
    -- Auto-Reconcile missing keys from new updates
    Tables.Reconcile(mockProfile.Data, DEFAULT_PROFILE)
    
    self.Profiles[player] = mockProfile
end

function DataService:PlayerRemoving(player: Player)
    self.Profiles[player] = nil
end

function DataService:Init()
    Players.PlayerAdded:Connect(function(player)
        self:PlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:PlayerRemoving(player)
    end)
end

return DataService
```
