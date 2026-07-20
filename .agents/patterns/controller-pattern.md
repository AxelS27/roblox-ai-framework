# Client-Side Controller Coding Pattern

Controllers are client-side singletons responsible for handling user inputs, UI updates, client-side animations, and communicating with server-side Services.

## Controller Guidelines

1. **Naming Conventions**: Use `Name = "ControllerName"` for controller registration.
2. **UI & FX Isolation**: All UI drawing, ScreenGui binding, and visual particle tweens must live inside Controllers, never on the Server.
3. **Communication**: Controllers talk to Services using the shared dynamic Net/Remote library.
4. **Lifecycle Hooks**:
   - `Init()`: Preload client assets (UI frames, sounds), register dependencies.
   - `Start()`: Bind inputs (UserInputService/ContextActionService), activate UI listeners.

---

## Pattern Example

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local ExampleController = {
    Name = "ExampleController",
}

local _maid = Maid.new()

-- Resolve local references, setup UI frames
function ExampleController:Init()
    print("[Client] Initializing ExampleController")
end

-- Bind inputs and UI interactions
function ExampleController:Start()
    print("[Client] Starting ExampleController")
end

function ExampleController:Destroy()
    _maid:Destroy()
end

return ExampleController
```
