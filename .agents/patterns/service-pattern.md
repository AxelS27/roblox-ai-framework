# Server-Side Service Coding Pattern

Services are server-side singletons responsible for managing core game logic, data persistence, and exposing safe remote endpoints to clients.

## Service Guidelines

1. **Naming Conventions**: Use `Name = "ServiceName"` for service registration in the Core Registry.
2. **Client Interface**: Expose only necessary methods/signals to the client via the `Client` table.
3. **No Direct Requires**: Do not directly require other Services inside the main body of the script to prevent circular dependency lockups. Resolve them dynamically at initialization, or hook to them via signals.
4. **Lifecycle Hooks**:
   - `Init()`: Preparation stage. Resolve dependencies, connect databases.
   - `Start()`: Execution stage. Run game loops, listen to networking events.

---

## Pattern Example

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local ExampleService = {
    Name = "ExampleService",
    Client = {},
}

local _maid = Maid.new()

-- Initialize service dependencies and configuration
function ExampleService:Init()
    print("[Server] Initializing ExampleService")
    
    -- Expose a remote event/signal to the client if needed
    -- self.Client.MyEvent = Net:Event("MyEvent")
end

-- Begin game loops and event listeners
function ExampleService:Start()
    print("[Server] Starting ExampleService")
    
    -- Start loops or character listeners
    -- task.spawn(function() ... end)
end

function ExampleService:Destroy()
    _maid:Destroy()
end

return ExampleService
```
