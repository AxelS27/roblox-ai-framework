# Visual Effects (VFX) Pattern

---

## 📌 Overview
The **EffectsController** manages client-side particle emissions, hit sparks, and environmental visual effects.

---

## 🛠️ Implementation Standard (`EffectsController.luau`)

```lua
--!strict
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local EffectsController = {
    Name = "EffectsController"
}

function EffectsController:EmitParticles(emitterTemplate: ParticleEmitter, attachment: Attachment, count: number)
    local clone = emitterTemplate:Clone()
    clone.Parent = attachment
    clone:Emit(count)

    Debris:AddItem(clone, clone.Lifetime.Max + 1)
end

function EffectsController:SpawnBurstAt(cframe: CFrame, color: Color3, particleCount: number?)
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

function EffectsController:Init()
    print("[Client] EffectsController initialized.")
end

return EffectsController
```
