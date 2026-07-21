# Audio System Pattern

---

## 📌 Overview
The **AudioController** handles BGM cross-fading, UI sound effects, and spatial 3D audio playback on the client.

---

## 🛠️ Implementation Standard (`AudioController.luau`)

```lua
--!strict
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local AudioController = {
    Name = "AudioController",
    CurrentBGM = nil :: Sound?,
}

local bgmGroup: SoundGroup
local sfxGroup: SoundGroup
local maid = Maid.new()

function AudioController:PlaySFX(soundId: string, volume: number?, pitch: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.5
    sound.PlaybackSpeed = pitch or 1.0
    sound.SoundGroup = sfxGroup
    sound.Parent = SoundService

    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

function AudioController:PlayBGM(soundId: string, fadeDuration: number?)
    local fadeTime = fadeDuration or 1.0

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

    TweenService:Create(newBGM, TweenInfo.new(fadeTime), { Volume = 0.4 }):Play()
end

function AudioController:Init()
    bgmGroup = SoundService:FindFirstChild("BGM") or Instance.new("SoundGroup")
    bgmGroup.Name = "BGM"
    bgmGroup.Parent = SoundService

    sfxGroup = SoundService:FindFirstChild("SFX") or Instance.new("SoundGroup")
    sfxGroup.Name = "SFX"
    sfxGroup.Parent = SoundService
end

return AudioController
```
