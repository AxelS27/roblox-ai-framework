--!strict
--[=[
    @class ExampleComponent
    @server
    Demonstrates binding behavior to tagged Workspace parts dynamically.
]=]
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
    
    print("[Server] Bound ExampleComponent to: " .. instance.Name)

    -- Simple behavior: change color on touch
    maid:GiveTask(instance.Touched:Connect(function(hit)
        local character = hit.Parent
        if character and character:FindFirstChildOfClass("Humanoid") then
            instance.Color = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
        end
    end))
end

local function onInstanceRemoved(instance: Instance)
    local maid = ExampleComponent.Instances[instance]
    if maid then
        maid:Destroy()
        ExampleComponent.Instances[instance] = nil
        print("[Server] Unbound ExampleComponent from: " .. instance.Name)
    end
end

function ExampleComponent:Init()
    -- Bind existing tagged instances
    for _, instance in CollectionService:GetTagged(self.Tag) do
        task.spawn(onInstanceAdded, instance)
    end

    -- Listen for new tagged instances
    CollectionService:GetInstanceAddedSignal(self.Tag):Connect(onInstanceAdded)
    CollectionService:GetInstanceRemovedSignal(self.Tag):Connect(onInstanceRemoved)
end

return ExampleComponent
