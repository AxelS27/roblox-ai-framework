--strict
--[=[
    @class ExampleController
    @client
    Example game controller demonstrating client-side network listening.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = Shared:WaitForChild("Network")
local Net = require(Network:WaitForChild("Net"))

local ExampleController = {
    Name = "ExampleController",
}

function ExampleController:Init()
    print("[Client] ExampleController initialized.")
end

function ExampleController:Start()
    print("[Client] ExampleController started.")
    
    -- Listen to the dynamically generated server remote event
    local exampleSignal = Net:Event("ExampleSignal")
    exampleSignal.OnClientEvent:Connect(function(message: string)
        print("[Client] Received server signal message: " .. message)
    end)
end

return ExampleController
