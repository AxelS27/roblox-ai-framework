# Loading State & Preloading Pattern

---

## 📌 Overview
The **LoadingController** manages full-screen asset preloading screens, map transition curtains, and universe teleport overlays, distinguishing when a loading screen is required vs when seamless transitions should be used.

---

## 🧭 Loading Decision Matrix

| Game Event / Moment | Loading Required? | Recommended UI Overlay | Duration / Transition |
| :--- | :---: | :--- | :--- |
| **Initial Experience Boot** | **YES** | `BootLoadingScreen` (ProgressBar + PreloadAsync) | Until `ContentProvider` finishes preloading key assets |
| **Cross-Place Universe Teleport** | **YES** | `TeleportLoadingOverlay` (Custom Teleport GUI) | Until destination place loads |
| **Match Map Swap / Round Transition** | **YES** | `MapTransitionOverlay` (Fade-to-Black / Curtain Slide) | ~1.5s (during map unstage / stage) |
| **UI Menu Toggle (Shop/Inventory)** | **NO** | Instant `PopInFrame` / `PopOutFrame` | ~0.2s micro-animation |
| **In-Game Item Purchase** | **NO** | Small Button Spinner / Toast Notification | Instant feedback |
| **Character Respawn** | **NO** | Spectator Camera / Immediate Pivot | Instant transition |

---

## 🛠️ Implementation Standard (`LoadingController.luau`)

```lua
--!strict
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadingController = {
    Name = "LoadingController",
    IsLoading = false,
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local loadingGui: ScreenGui? = nil
local curtainFrame: Frame? = nil
local progressBar: Frame? = nil

function LoadingController:PreloadAssets(assetInstances: {Instance}, completionCallback: () -> ())
    self.IsLoading = true
    self:ShowCurtain(true)

    task.spawn(function()
        local total = #assetInstances
        if total == 0 then
            self:ShowCurtain(false)
            completionCallback()
            return
        end

        for index, instance in ipairs(assetInstances) do
            ContentProvider:PreloadAsync({ instance })
            if progressBar then
                progressBar.Size = UDim2.new(index / total, 0, 1, 0)
            end
        end

        self:ShowCurtain(false)
        self.IsLoading = false
        completionCallback()
    end)
end

function LoadingController:ShowCurtain(visible: boolean, duration: number?)
    if not curtainFrame then return end
    local fadeTime = duration or 0.4

    if visible then
        curtainFrame.Visible = true
        TweenService:Create(curtainFrame, TweenInfo.new(fadeTime), { BackgroundTransparency = 0 }):Play()
    else
        local tween = TweenService:Create(curtainFrame, TweenInfo.new(fadeTime), { BackgroundTransparency = 1 })
        tween:Play()
        tween.Completed:Connect(function()
            curtainFrame.Visible = false
        end)
    end
end

function LoadingController:Init()
    local gui = Instance.new("ScreenGui")
    gui.Name = "LoadingOverlayGui"
    gui.DisplayOrder = 999 -- Top priority overlay
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = gui

    curtainFrame = frame
    loadingGui = gui
end

return LoadingController
```
