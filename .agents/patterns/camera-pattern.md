# Camera State Machine Pattern

---

## 📌 Overview
The **CameraController** manages client-side perspective transitions, camera modes, and cinematic droning without messing up player controls or leaving orphaned camera tweens.

---

## 📷 Camera States

| Camera State | CameraType | Zoom / Control Behavior | Use Cases |
| :--- | :--- | :--- | :--- |
| **`ThirdPerson`** | `Enum.CameraType.Custom` | Standard Orbit (`MinZoom = 5`, `MaxZoom = 25`) | Standard lobby, exploration, running |
| **`FirstPerson`** | `Enum.CameraType.Custom` | Lock to Head (`MinZoom = 0.5`, `MaxZoom = 0.5`) | Stealth hiding, precision aiming, immersion |
| **`ViewportFocus`** | `Enum.CameraType.Scriptable` | Smooth CFrame Interpolation to Target Part | Character customization, Shop preview, Dialogue |
| **`DroneCinematic`**| `Enum.CameraType.Scriptable` | Free-floating orbit / path interpolation | Match intro, Spectator mode, Map overview |
| **`Cutscene`** | `Enum.CameraType.Scriptable` | Multi-keypoint curve tween with FOV easing | Game start transition, Victory podium flyby |

---

## 🛠️ Implementation Standard (`CameraController.luau`)

```lua
--!strict
--[=[
    @class CameraController
    @client
    Centralized Client Camera State Machine.
    Handles transitions between 1st Person, 3rd Person, Viewport Focus, and Drone Cinematic modes.
]=]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local CameraController = {
    Name = "CameraController",
    CurrentState = "ThirdPerson",
}

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local maid = Maid.new()
local occludedParts: { [BasePart]: number } = {}

export type CameraMode = "ThirdPerson" | "FirstPerson" | "ViewportFocus" | "DroneCinematic" | "Cutscene"

-- 1. Updates line-of-sight transparency occlusion (prevents visual blocks)
local function updateOcclusion()
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not head or (humanoid and humanoid.Health <= 0) then return end
    
    local rayOrigin = camera.CFrame.Position
    local rayDirection = (head.Position - rayOrigin)
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    
    local result = workspace:Raycast(rayOrigin, rayDirection, params)
    
    -- Restore transparency for parts no longer blocking the view
    for part, originalTrans in pairs(occludedParts) do
        if not part or not part.Parent or not result or result.Instance ~= part then
            part.Transparency = originalTrans
            occludedParts[part] = nil
        end
    end
    
    -- Fade blocking part to 0.5 transparency
    if result and result.Instance:IsA("BasePart") and not result.Instance.CanCollide then
        local part = result.Instance
        -- Check if it's a foliage prop, tree leaf, or thin canopy
        if not occludedParts[part] then
            occludedParts[part] = part.Transparency
            part.Transparency = 0.5
        end
    end
end

--[=[
    Sets the active camera mode and handles smooth transitions.
    @param mode CameraMode
    @param focusTarget BasePart | CFrame?
    @param duration number?
]=]
function CameraController:SetState(mode: CameraMode, focusTarget: (BasePart | CFrame)?, duration: number?)
    maid:DoCleaning() -- Clean up active drone loops or camera tweens
    self.CurrentState = mode

    local transitionTime = duration or 0.5

    if mode == "ThirdPerson" then
        camera.CameraType = Enum.CameraType.Custom
        player.CameraMinZoomDistance = 5
        player.CameraMaxZoomDistance = 25
        camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

    elseif mode == "FirstPerson" then
        camera.CameraType = Enum.CameraType.Custom
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 0.5
        camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

    elseif mode == "ViewportFocus" then
        assert(focusTarget, "ViewportFocus state requires a target BasePart or CFrame")
        camera.CameraType = Enum.CameraType.Scriptable

        local targetCFrame: CFrame
        if typeof(focusTarget) == "Instance" and (focusTarget :: Instance):IsA("BasePart") then
            targetCFrame = (focusTarget :: BasePart).CFrame * CFrame.new(0, 1.5, 6)
        else
            targetCFrame = focusTarget :: CFrame
        end

        TweenService:Create(camera, TweenInfo.new(transitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = targetCFrame,
            FieldOfView = 60
        }):Play()

    elseif mode == "DroneCinematic" then
        camera.CameraType = Enum.CameraType.Scriptable
        local centerPoint = (typeof(focusTarget) == "CFrame" and focusTarget) or (player.Character and player.Character:GetPivot()) or CFrame.new(0, 10, 0)
        local radius = 35
        local speed = 0.3
        local angle = 0

        -- Continuous Orbit Loop
        maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
            angle += dt * speed
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            local camPos = centerPoint.Position + Vector3.new(x, 18, z)
            camera.CFrame = CFrame.lookAt(camPos, centerPoint.Position)
        end))
    end
end

function CameraController:Init()
    print("[Client] CameraController initialized.")
    
    -- Bind rendering frame update for line-of-sight occlusion fading
    RunService.RenderStepped:Connect(updateOcclusion)
end

function CameraController:Start()
    self:SetState("ThirdPerson")
end

return CameraController

```
