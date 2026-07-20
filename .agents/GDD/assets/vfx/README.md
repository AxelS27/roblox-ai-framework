# Visual Effects (VFX) Asset Registry

---

## ✨ VFX Registry Table

| Effect Name | Spawn Target | Description / Behavior | Config Variable Name | Asset ID / Template Name |
| :--- | :--- | :--- | :--- | :--- |
| `[e.g., Sparks]` | `[Attachment]` | `[Burst of particle sparks when metal collides]` | `[SPARKS_VFX]` | `[VFX Particle Emitter Template]` |
| `[VFX Name]` | `[Target]` | `[Behavior]` | `[Config Name]` | `[Asset ID / Name]` |

---

## 🛠️ Code Configuration Hook Schema
```lua
-- Proposed config hook schema
-- Path: src/shared/Configs/VfxConfig.luau

export type VfxData = {
    Duration: number,
    AssetId: string?,
}

local VfxConfig: {[string]: VfxData} = {
    HitSparks = {
        Duration = 0.5,
        AssetId = "rbxassetid://12345678",
    }
}

return table.freeze(VfxConfig)
```
