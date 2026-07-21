# Native Roblox Specification: Leaderstats (Top-Right System)

> [!NOTE]
> Specification for using Roblox's built-in native `leaderstats` folder system on the top-right of the player screen instead of a custom UI panel.

---

## 🛠️ Server Folder Structure (`Player.leaderstats`)

Roblox automatically renders the top-right leaderboard when a `Folder` named `leaderstats` is parented to a `Player` instance on the server.

```luau
-- Server script creation pattern:
local leaderstats = Instance.new("Folder")
leaderstats.Name = "leaderstats"
leaderstats.Parent = player

local dnaValue = Instance.new("IntValue")
dnaValue.Name = "DNA"
dnaValue.Value = 0
dnaValue.Parent = leaderstats

local killsValue = Instance.new("IntValue")
killsValue.Name = "Kills"
killsValue.Value = 0
killsValue.Parent = leaderstats

local speciesValue = Instance.new("StringValue")
speciesValue.Name = "Species"
speciesValue.Value = "Ant"
speciesValue.Parent = leaderstats
```

---

## 📋 Stat Columns & Display Specs

| Stat Column Name | Value Type | Description / Value Source |
| :--- | :--- | :--- |
| **`DNA`** | `IntValue` | Total active Evolution DNA points accumulated |
| **`Kills`** | `IntValue` | Total rival players & apex fauna slain |
| **`Species`** | `StringValue` | Current active creature species (Ant, Spider, Wolf, Bear, Dragon) |

---

## 🎨 Benefits & Design Rules
1. **Zero UI Performance Overhead**: Uses native C++ engine rendering at the top-right corner of the screen.
2. **Native Roblox UX Compatibility**: Mobile, PC, and Console players receive the familiar Roblox top-right player list automatically.
3. **No Custom GUI Staging Needed**: Eliminates the need for custom `StarterGui.Leaderboard` ScreenGui staging.
