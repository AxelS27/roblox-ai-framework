# Visual Effects (VFX) Pattern

---

## 📌 Overview
The **EffectsController** manages client-side particle emissions, hit sparks, and environmental visual effects, incorporating real-world game development optimization patterns like **Distance-Based VFX Culling**.

---

## 🛠️ Implementation Standard (`EffectsController.luau`)

```lua
--!strict
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local MAX_VFX_DISTANCE = 150 -- Maximum culling distance for non-critical visual effects (in studs)

local EffectsController = {
    Name = "EffectsController"
}

-- Check if target position is close enough to the local camera to render
function EffectsController:IsWithinBudget(targetPosition: Vector3, customDistance: number?): boolean
    local camera = Workspace.CurrentCamera
    if not camera then return false end

    local distance = (camera.CFrame.Position - targetPosition).Magnitude
    return distance <= (customDistance or MAX_VFX_DISTANCE)
end

function EffectsController:EmitParticles(emitterTemplate: ParticleEmitter, attachment: Attachment, count: number)
    -- Real-World Dev Optimization: Skip rendering if too far from the camera
    if not self:IsWithinBudget(attachment.WorldPosition) then
        return
    end

    local clone = emitterTemplate:Clone()
    clone.Parent = attachment
    clone:Emit(count)

    Debris:AddItem(clone, clone.Lifetime.Max + 1)
end

function EffectsController:SpawnBurstAt(cframe: CFrame, color: Color3, particleCount: number?)
    -- Real-World Dev Optimization: Skip creating parts and emitting particles if culled
    if not self:IsWithinBudget(cframe.Position) then
        return
    end

    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.CFrame = cframe
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.Parent = Workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(color)
    emitter.Size = NumberSequence.new(0.5, 0)
    emitter.Speed = NumberRange.new(5, 12)
    emitter.Lifetime = NumberRange.new(0.5, 1)
    emitter.Parent = part

    emitter:Emit(particleCount or 20)

    Debris:AddItem(part, 1.5)
end

-- 3. Spawns floating 3D Damage Numbers (Immersive Combat Hit Feedback)
function EffectsController:SpawnDamageNumber(position: Vector3, damage: number, isCritical: boolean?)
    if not self:IsWithinBudget(position) then
        return
    end

    -- Create transient anchoring part
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Position = position + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2))
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.Parent = Workspace

    -- Setup BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(120, 60)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 1.5, 0)
    billboard.Adornee = part
    billboard.Parent = part

    -- Setup TextLabel
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = tostring(math.round(damage))
    label.Font = Enum.Font.MontserratBold
    label.TextSize = isCritical and 24 or 16
    label.TextColor3 = isCritical and Color3.fromRGB(245, 158, 11) or Color3.fromRGB(239, 68, 68) -- Gold for Crit, Red for Normal
    
    -- Outline Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = label
    label.Parent = billboard

    -- Float upward and fade out animation
    local floatDuration = 0.8
    local tweenInfo = TweenInfo.new(floatDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- Tween height offset and fade
    TweenService:Create(billboard, tweenInfo, { ExtentsOffset = Vector3.new(0, 4, 0) }):Play()
    TweenService:Create(label, tweenInfo, { TextTransparency = 1 }):Play()
    TweenService:Create(stroke, tweenInfo, { Transparency = 1 }):Play()

    Debris:AddItem(part, floatDuration)
end

function EffectsController:Init()
    print("[Client] EffectsController initialized with Distance-Culling Budget.")
end

return EffectsController
```
