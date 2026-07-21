# Audio & Sound Effects Asset Registry

---

## 🔊 Audios Registry Table

| Sound Name | Category | Playback / Behavior | Volume / Pitch | Asset ID |
| :--- | :--- | :--- | :--- | :--- |
| `[e.g., Click]` | `[UI SFX]` | `[One-shot play on button click]` | `[Volume: 0.5, Pitch: 1.0]` | `[Asset ID]` |
| `[Sound Name]` | `[Category]` | `[Behavior]` | `[Settings]` | `[Asset ID]` |

---

## 🛠️ Code Configuration Hook Schema
```lua
-- Proposed config hook schema
-- Path: src/shared/Configs/AudioConfig.luau

export type AudioData = {
    Volume: number,
    Pitch: number,
    Looped: boolean,
    AssetId: string,
}

local AudioConfig: {[string]: AudioData} = {
    ButtonClick = {
        Volume = 0.5,
        Pitch = 1.0,
        Looped = false,
        AssetId = "rbxassetid://[AssetID]",
    }
}

return table.freeze(AudioConfig)
```
