# Cross-Platform Input & Mobile UX Pattern

> **Guidelines for Unifying PC, Mobile, and Gamepad Controls with Premium Touch HUD layouts**

---

## 📌 Overview
The **InputController** unifies PC keyboard/mouse binds, Gamepad inputs, and custom Mobile touch buttons. This pattern enforces standard cross-platform bindings and details how to construct a comfortable, premium mobile touch UX that avoids Roblox's default, unstyled ContextActionService buttons.

---

## 📐 1. Premium Mobile Touch HUD & UX Standards
Roblox's default `ContextActionService:BindAction` touch buttons look generic, are poorly sized, and clash with customized ScreenGuis. Always design a custom Touch Action HUD:

```
                                                       [ Jump Button ]
                                                       (Size: 70x70px)
                                                       (Offset: X:-150, Y:-220)
                                                             │
                                                             ▼
                                                           ┌───┐
                                                           │ ▲ │
                                    ┌───┐                  └───┘
                                    │ Q │
                                    └───┘                  ┌───┐
                             ┌───┐                         │ F │
                             │ R │                         └───┘
                             └───┘                  ┌───┐
                                                    │LMB│
                                                    └───┘
                      ┌───┐
                      │Tab│
                      └───┘                  [ Action Buttons Arc ]
                                             (LMB, RMB, Q, E, F, Sprint)
                                             (Natural thumb sweep zone)
```

1. **Natural Thumb Reach (Arc Layout)**:
   * Arrange custom touch buttons in an arc around the bottom-right corner, mirroring console/action-RPG controllers.
   * Place the primary action (LMB/Bite) closest to the thumb's natural rest position (approx. `UDim2.new(1, -120, 1, -120)`).
   * Place mobility/dash and special skills in a radial arc orbiting the primary action button.
   * Place the **Sprint Toggle Button** nearby for easy thumb reach.
2. **Button Dimensions & Spacing**:
   * Primary Button: Size of at least `70x70` pixels (`UDim2.fromOffset(70, 70)`).
   * Secondary/Skill Buttons: Size of at least `50x50` pixels (`UDim2.fromOffset(50, 50)`).
   * Maintain a minimum padding of `10` pixels between touch zones to prevent accidental double-taps or misclicks.
3. **Visual Feedback States**:
   * **Normal**: Semi-transparent backing (e.g. `BackgroundTransparency = 0.4`), clean UIStroke.
   * **Pressed**: Scale down slightly (e.g., using `UIAnimate.bindHoverScale` parameters) and darken the button.
   * **Cooldown (Radial Sweep)**: Overlay a dark semi-transparent frame with a circular fill/sweep mask showing the remaining duration. Disable button interaction until cooldown is 0.

---

## 🛠️ Implementation Standard (`InputController.luau`)

When binding actions, map them cleanly to unify devices. If running on Mobile, programmatic handlers should hook into the custom Touch HUD buttons.

```lua
--!strict
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Utilities = Shared:WaitForChild("Utilities")
local UIAnimate = require(Utilities:WaitForChild("UIAnimate"))

local InputController = {
    Name = "InputController",
    LastDevice = "PC" :: "PC" | "Mobile" | "Console",
    ActiveConnections = {},
}

-- 1. Unify ContextActionService bindings
function InputController:BindAction(
    actionName: string, 
    handler: (actionName: string, state: Enum.UserInputState, input: InputObject) -> Enum.ContextActionResult?, 
    keyCodes: {Enum.KeyCode | Enum.UserInputType}
)
    -- Bind keycodes (PC and Console Gamepad)
    ContextActionService:BindAction(actionName, handler, false, unpack(keyCodes))
end

function InputController:UnbindAction(actionName: string)
    ContextActionService:UnbindAction(actionName)
end

-- 2. Setup custom Mobile Action Button logic (comfortably styled)
function InputController:CreateTouchButton(buttonFrame: ImageButton, actionName: string, mockKey: Enum.KeyCode)
    -- Apply premium visual feedback from UIAnimate
    local cleanup = UIAnimate.bindHoverScale(buttonFrame, 1.1, 0.9)
    table.insert(self.ActiveConnections, cleanup)

    -- Bind Touch events to trigger the same action handler
    local touchStart = buttonFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Trigger action began state
            local mockInput = Instance.new("InputObject") -- mock input object for handler compatibility
            ContextActionService:CallFunction(actionName, Enum.UserInputState.Begin, mockInput)
        end
    end)

    local touchEnd = buttonFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Trigger action ended state
            local mockInput = Instance.new("InputObject")
            ContextActionService:CallFunction(actionName, Enum.UserInputState.End, mockInput)
        end
    end)
    
    table.insert(self.ActiveConnections, touchStart)
    table.insert(self.ActiveConnections, touchEnd)
end

function InputController:Init()
    -- Detect device category dynamically
    UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
        if lastInputType == Enum.UserInputType.Touch then
            self.LastDevice = "Mobile"
        elseif lastInputType == Enum.UserInputType.Gamepad1 then
            self.LastDevice = "Console"
        else
            self.LastDevice = "PC"
        end
    end)
end

return InputController
```
