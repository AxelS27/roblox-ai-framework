--!strict
--[=[
    @class ExampleService
    @server
    Example game service demonstrating framework registration.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Network = Shared:WaitForChild("Network")
local Net = require(Network:WaitForChild("Net"))

local ExampleService = {
    Name = "ExampleService",
    Client = {},
}

function ExampleService:Init()
    print("[Server] ExampleService initialized.")
    
    -- Dynamically declare a remote event
    self.Client.ExampleSignal = Net:Event("ExampleSignal")
end

function ExampleService:Start()
    print("[Server] ExampleService started.")
    
    -- Periodic event fire demo
    task.spawn(function()
        while true do
            task.wait(5)
            self.Client.ExampleSignal:FireAllClients("Hello from server!")
        end
    end)
end

return ExampleService
