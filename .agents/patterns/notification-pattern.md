# Toast Notification Pattern

---

## 📌 Overview
The **NotificationController** manages client-side banner alerts, reward popups, and toast notifications.

---

## 🛠️ Implementation Standard (`NotificationController.luau`)

```lua
--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationController = {
    Name = "NotificationController"
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local toastContainer: Frame? = nil

function NotificationController:Notify(message: string, duration: number?, color: Color3?)
    if not toastContainer then return end

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 40)
    toast.BackgroundColor3 = color or Color3.fromRGB(30, 20, 50)
    toast.BackgroundTransparency = 0.2

    local uiCorner = Instance.new("UICorner", toast)
    uiCorner.CornerRadius = UDim.new(0, 8)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, 0)
    text.Position = UDim2.new(0, 10, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 14
    text.Parent = toast

    toast.Parent = toastContainer

    -- Slide in animation
    toast.Position = UDim2.new(1, 100, 0, 0)
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(duration or 3.0, function()
        local fade = TweenService:Create(toast, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
        fade:Play()
        fade.Completed:Connect(function()
            toast:Destroy()
        end)
    end)
end

function NotificationController:Init()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotificationsGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 100 -- Enforce high render ordering to overlay center menus
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0.4, 0)
    frame.Position = UDim2.new(0, 20, 0.3, 0) -- Positioned at middle-left to prevent clashing with native top-right leaderstats
    frame.BackgroundTransparency = 1
    frame.Parent = gui

    local list = Instance.new("UIListLayout", frame)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)

    toastContainer = frame
end

return NotificationController
```
