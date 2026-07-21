# Audio System Pattern

> **Standard for BGM Cross-Fading, Auto-bound UI Sound Effects, and 3D Spatial SFX**

---

## 📌 Overview
The **AudioController** manages BGM cross-fading, automatic UI button sound effects (hover/click), and spatial 3D audio playback on the client to ensure the experience is rich, pleasant, and immersive without being noisy.

---

## 🛠️ Implementation Standard (`AudioController.luau`)

```lua
--!strict
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local AudioController = {
    Name = "AudioController",
    CurrentBGM = nil :: Sound?,
    
    -- Default UI Sound Assets (Pre-curated, pleasant tones)
    Sounds = {
        UI_HOVER = "rbxassetid://9119565538",
        UI_CLICK = "rbxassetid://9119565614",
        EVOLVE = "rbxassetid://9123891039",
        EAT = "rbxassetid://9114223126",
    }
}

local bgmGroup: SoundGroup
local sfxGroup: SoundGroup
local maid = Maid.new()

-- 1. Play 2D Screen Sound Effect (Menus, leveling, popups)
function AudioController:PlaySFX(soundId: string, volume: number?, pitch: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.4
    sound.PlaybackSpeed = pitch or 1.0
    sound.SoundGroup = sfxGroup
    sound.Parent = SoundService

    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- 2. Play 3D Spatial Sound Effect (Claw swipes, bites, footsteps, tree cutting)
function AudioController:PlaySpatialSFX(soundId: string, target: Vector3 | BasePart, maxDistance: number?, volume: number?, pitch: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.5
    sound.PlaybackSpeed = pitch or 1.0
    sound.SoundGroup = sfxGroup
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.MaxDistance = maxDistance or 60

    if typeof(target) == "Vector3" then
        -- Spawn transient attachment at 3D coordinate
        local attachment = Instance.new("Attachment")
        attachment.WorldPosition = target
        attachment.Parent = workspace.Terrain
        
        sound.Parent = attachment
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
            attachment:Destroy()
        end)
    elseif target:IsA("BasePart") then
        sound.Parent = target
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
end

-- 3. Smooth BGM Cross-Fading (swapping biomes, menus, state transitions)
function AudioController:PlayBGM(soundId: string, fadeDuration: number?)
    local fadeTime = fadeDuration or 1.5

    if self.CurrentBGM then
        local oldBGM = self.CurrentBGM
        local fadeOut = TweenService:Create(oldBGM, TweenInfo.new(fadeTime), { Volume = 0 })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            oldBGM:Stop()
            oldBGM:Destroy()
        end)
    end

    local newBGM = Instance.new("Sound")
    newBGM.SoundId = soundId
    newBGM.Volume = 0
    newBGM.Looped = true
    newBGM.SoundGroup = bgmGroup
    newBGM.Parent = SoundService

    self.CurrentBGM = newBGM
    newBGM:Play()

    TweenService:Create(newBGM, TweenInfo.new(fadeTime), { Volume = 0.3 }):Play()
end

-- 4. Auto-Bind pleasant Hover/Click sounds to all buttons in a Gui Screen
function AudioController:BindUISounds(parent: Instance)
    local function applyTo(instance: Instance)
        if instance:IsA("GuiButton") then
            instance.MouseEnter:Connect(function()
                self:PlaySFX(self.Sounds.UI_HOVER, 0.2, 1.1)
            end)
            instance.MouseButton1Click:Connect(function()
                self:PlaySFX(self.Sounds.UI_CLICK, 0.35, 1.0)
            end)
        end
        for _, child in instance:GetChildren() do
            applyTo(child)
        end
    end
    applyTo(parent)
end

function AudioController:Init()
    bgmGroup = SoundService:FindFirstChild("BGM") or Instance.new("SoundGroup")
    bgmGroup.Name = "BGM"
    bgmGroup.Parent = SoundService

    sfxGroup = SoundService:FindFirstChild("SFX") or Instance.new("SoundGroup")
    sfxGroup.Name = "SFX"
    sfxGroup.Parent = SoundService
    
    -- Auto-bind UI sounds to newly added ScreenGuis
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    playerGui.ChildAdded:Connect(function(child)
        self:BindUISounds(child)
    end)
    
    -- Bind existing screens
    for _, child in playerGui:GetChildren() do
        self:BindUISounds(child)
    end
end

return AudioController
```

---

## 🌐 4. Sound Replication Scopes & Audibility Rules
Roblox games require precise control over who hears which audio. Follow these four structural paradigms:

| Scope | Reached Audience | Technical Implementation | Best Practice / Use Case |
| :--- | :--- | :--- | :--- |
| **1. Local-Only (2D)** | Only the Local Player | Played via `AudioController` on the Client, parented directly under `SoundService` or `PlayerGui`. | UI click/hover sounds, personal level-up fanfare, private quest alerts, and background music (BGM). |
| **2. Proximity (3D)** | Nearby players in physical range | **Option A (Replicated)**: Server instantiates a `Sound` inside a Workspace Part/Attachment with `RollOffMode = Linear`. Roblox automatically replicates and spatializes it to all nearby clients.<br>**Option B (Local-Spatial)**: Client plays the sound locally at a coordinate for visual immersion without server lag. | Footsteps, claw swipe hits, eating sounds, animal growls, flowing rivers, rustling leaves. |
| **3. Global Event (2D)**| All players in the server equally | Server instantiates a `Sound` inside `SoundService` (replicates to everyone non-spatially) OR fires a Client remote via `Net` to trigger local SFX. | World disasters (meteor strike alert, volcanic sirens, blood moon rising), server-wide announcements. |
| **4. Targeted / Factional** | Only specific players (e.g. Teams, Species, Area) | Server identifies target players and calls `Net:FireClient()` to run `AudioController:PlaySFX()` on their screens only. | Faction alert (e.g., *"Your Nest is under attack"* - only heard by Ants), low-health heartbeat warning (heard only by the dying player). |

