# Cross-Platform Input Pattern

---

## 📌 Overview
The **InputController** unifies PC, Mobile, and Console controls via `ContextActionService` and handles input mode switching.

---

## 🛠️ Implementation Standard (`InputController.luau`)

```lua
--!strict
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local InputController = {
    Name = "InputController",
    LastDevice = "PC" :: "PC" | "Mobile" | "Console",
}

function InputController:BindAction(actionName: string, handler: (actionName: string, state: Enum.UserInputState, input: InputObject) -> Enum.ContextActionResult?, createTouchButton: boolean, ...: Enum.KeyCode | Enum.UserInputType)
    ContextActionService:BindAction(actionName, handler, createTouchButton, ...)
end

function InputController:UnbindAction(actionName: string)
    ContextActionService:UnbindAction(actionName)
end

function InputController:Init()
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
