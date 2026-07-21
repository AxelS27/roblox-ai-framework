# 3D Models & Meshes Asset Registry

---

## 📦 Models Registry Table

| Model Name | Source / Type | Description / Usage | Collision Setting | Asset ID |
| :--- | :--- | :--- | :--- | :--- |
| `[e.g., Tree]` | `[MeshPart]` | `[Static foliage decoration placed in environment]` | `[CanCollide: true]` | `[Asset ID]` |
| `[Model Name]` | `[Type]` | `[Usage]` | `[Collision]` | `[Asset ID]` |

---

## 🛠️ Code Configuration Hook Schema
```lua
-- Proposed config hook schema
-- Path: src/shared/Configs/ModelConfig.luau

export type ModelData = {
    CanCollide: boolean,
    Massless: boolean,
    AssetId: string,
}

local ModelConfig: {[string]: ModelData} = {
    LobbyTree = {
        CanCollide = true,
        Massless = false,
        AssetId = "rbxassetid://[AssetID]",
    }
}

return table.freeze(ModelConfig)
```
