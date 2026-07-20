--!strict
--[=[
    @class ExampleClientComponent
    @client
    Demonstrates binding visual effects to tagged client-side parts dynamically.
]=]
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local ExampleClientComponent = {
    Tag = "SpinningObstacle",
    Instances = {} :: { [Instance]: typeof(Maid.new()) },
}

local function onInstanceAdded(instance: Instance)
    if not instance:IsA("BasePart") then return end
    
    local maid = Maid.new()
    ExampleClientComponent.Instances[instance] = maid
    
    print("[Client] Bound ExampleClientComponent to: " .. instance.Name)

    -- Rotate the part continuously on client only
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
    local tween = TweenService:Create(instance, tweenInfo, { Orientation = Vector3.new(0, 360, 0) })
    
    tween:Play()
    maid:GiveTask(function()
        tween:Cancel()
        tween:Destroy()
    end)
end

local function onInstanceRemoved(instance: Instance)
    local maid = ExampleClientComponent.Instances[instance]
    if maid then
        maid:Destroy()
        ExampleClientComponent.Instances[instance] = nil
        print("[Client] Unbound ExampleClientComponent from: " .. instance.Name)
    end
end

function ExampleClientComponent:Init()
    -- Bind existing tagged instances
    for _, instance in CollectionService:GetTagged(self.Tag) do
        task.spawn(onInstanceAdded, instance)
    end

    -- Listen for new tagged instances
    CollectionService:GetInstanceAddedSignal(self.Tag):Connect(onInstanceAdded)
    CollectionService:GetInstanceRemovedSignal(self.Tag):Connect(onInstanceRemoved)
end

return ExampleClientComponent
