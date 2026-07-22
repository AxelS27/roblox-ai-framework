# Roblox Starter Tutorial & Player Onboarding Pattern

> **Standards for Step-by-Step Interactive Tutorial Sequences, Objective Markers, and Onboarding Persistence**

---

## 📌 Overview
This pattern defines the architectural standard for first-time player onboarding in every Roblox game built with this framework. Every experience MUST include a 3 to 5 step interactive starter tutorial sequence to introduce players to core mechanics, movement, and key UI windows.

---

## 🎯 1. Tutorial Engine Declarative Architecture
Client controllers must use `TutorialEngine.luau` to define tutorial steps declaratively rather than writing ad-hoc tutorial code:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialEngine = require(ReplicatedStorage.Shared.Utilities.TutorialEngine)
local Net = require(ReplicatedStorage.Shared.Network.Net)

local tutorial = TutorialEngine.new({
    {
        Id = "Step1_Movement",
        Title = "Welcome! Explore the World",
        Instruction = "Walk to the highlighted Training Station.",
        TargetPart = workspace.CurrentMap.TutorialZone.Station,
        ActionSignal = Net.getEvent("TutorialZoneReached").OnClientEvent,
    },
    {
        Id = "Step2_CoreMechanic",
        Title = "Try Your First Action",
        Instruction = "Click the Action Button to interact.",
        TargetUI = mainScreenGui.ActionButton,
        ActionSignal = Net.getEvent("FirstActionCompleted").OnClientEvent,
    },
    {
        Id = "Step3_OpenShop",
        Title = "Open the Shop Menu",
        Instruction = "Click the Shop Icon on your sidebar.",
        TargetUI = sidebarGui.ShopButton,
        ActionSignal = Net.getEvent("ShopMenuOpened").OnClientEvent,
    },
})

-- Start Tutorial for First-Time Players
tutorial:start(function()
    print("Tutorial Completed! Granting Starter Reward...")
    Net.getFunction("ClaimTutorialReward"):InvokeServer()
end)
```

---

## 💾 2. Tutorial Data Persistence (ProfileService Integration)
To ensure returning players skip the tutorial while new players are guided:

1. **Server Profile Template**:
   ```luau
   local ProfileTemplate = {
       TutorialCompleted = false,
       Coins = 100,
   }
   ```
2. **Server Tutorial Verification**:
   ```luau
   local function claimTutorialReward(player: Player)
       local profile = ProfileService:GetProfile(player)
       if not profile or profile.Data.TutorialCompleted then
           return false, "Tutorial already completed!"
       end
       
       profile.Data.TutorialCompleted = true
       profile.Data.Coins += 250 -- Bonus reward for finishing tutorial!
       return true, "Tutorial completed!"
   end
   ```

---

## 🎨 3. UX & Aesthetic Guidelines
1. **Colorful HUD Overlay Widget**: Use `ThemeManager` glassmorphic styling at top-center (`UDim2.new(0.5, 0, 0.08, 0)`) with HSL accent bar gradients, step progress badge (`STEP 1 OF 3`), and `UIAnimate.bounce` step transitions.
2. **3D Directional Arrows & Waypoints**: Attach floating 3D bobbing directional arrows (`BillboardGui` hovering above target parts) and vibrant `Highlight` beacons (Emerald, Pink, Gold, Electric Blue per step) so players never get lost.
3. **Sensory Audio Feedback**: Play distinct click/chime audio roles (`UIAutoBinder.decorateButton(button, scale, scale, "Primary")`) for each interaction step.
4. **Non-Blocking Skipping**: Provide a clean "Skip Tutorial" button in the corner for veteran players.
