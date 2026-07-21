# Animations Asset Registry

---

## 🏃 Animations Registry Table

| Action Name | Animation Priority | Description / Trigger | Config Variable Name | Asset ID |
| :--- | :--- | :--- | :--- | :--- |
| `[e.g., Run]` | `[Movement]` | `[Triggers when player speed exceeds threshold]` | `[RUN_ANIM]` | `[Asset ID]` |
| `[Action Name]` | `[Priority]` | `[Trigger]` | `[Config Name]` | `[Asset ID]` |

---

## 🛠️ Code Configuration Hook Schema
```lua
-- Proposed config hook schema
-- Path: src/shared/Configs/AnimationConfig.luau

export type AnimationData = {
    Priority: Enum.AnimationPriority,
    AssetId: string,
}

local AnimationConfig: {[string]: AnimationData} = {
    Run = {
        Priority = Enum.AnimationPriority.Movement,
        AssetId = "rbxassetid://[AssetID]", -- Replace with ID
    }
}

return table.freeze(AnimationConfig)
```
