# CollectionService Component Coding Pattern

In this framework, **Components** are strictly **CollectionService Components**. They allow you to dynamically bind custom behaviors (like rotating platforms, kill zones, or interactive chests) to objects in the workspace tagged in Roblox Studio.

## Component Guidelines

1. **Explicit Tag Mapping**: Define a static `Tag = "MyTagName"` matching the tag registered in Roblox.
2. **Lifecycle Maid Tracking**: Store an `Instances` cache mapping active instances to custom `Maid` objects to clean up their connections instantly when un-tagged or destroyed.
3. **No Nested Scripts**: Never place Lua scripts inside parts. Group parts under CollectionService tags, and let a single Component monitor them.
4. **Initialization Hook**:
   - `Init()`: Query existing tagged instances and connect added/removed signals.

---

## Pattern Example

```lua
--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local ExampleComponent = {
    Tag = "ExampleTag",
    Instances = {} :: { [Instance]: typeof(Maid.new()) },
}

local function onInstanceAdded(instance: Instance)
    if not instance:IsA("BasePart") then return end
    
    local maid = Maid.new()
    ExampleComponent.Instances[instance] = maid
    
    -- Bind logic (e.g.Touched event)
    maid:GiveTask(instance.Touched:Connect(function(hit)
        -- Process interaction
    end))
    
    -- Bind attribute changes
    maid:GiveTask(instance:GetAttributeChangedSignal("IsEnabled"):Connect(function()
        -- Handle state toggle
    end))
end

local function onInstanceRemoved(instance: Instance)
    local maid = ExampleComponent.Instances[instance]
    if maid then
        maid:Destroy()
        ExampleComponent.Instances[instance] = nil
    end
end

function ExampleComponent:Init()
    -- Bind existing tagged items
    for _, instance in CollectionService:GetTagged(self.Tag) do
        task.spawn(onInstanceAdded, instance)
    end

    -- Hook up dynamic added/removed signals
    CollectionService:GetInstanceAddedSignal(self.Tag):Connect(onInstanceAdded)
    CollectionService:GetInstanceRemovedSignal(self.Tag):Connect(onInstanceRemoved)
end

return ExampleComponent
```
