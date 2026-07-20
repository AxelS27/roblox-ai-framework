--!strict
--[=[
    @client
    Client Bootstrapper Entry Point.
    Uses Core/Loader and Core/Registry to load controllers and client CollectionService components.
]=]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Core = Shared:WaitForChild("Core")
local Registry = require(Core:WaitForChild("Registry"))
local Loader = require(Core:WaitForChild("Loader"))

local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local ClientFolder = PlayerScripts:WaitForChild("Client")
local ControllersFolder = ClientFolder:WaitForChild("Controllers")
local ComponentsFolder = ClientFolder:WaitForChild("Components")

local function bootstrap()
    print("[Client Bootstrapper] Initiating startup sequence...")
    
    -- 1. Load Controllers
    Loader.Load(ControllersFolder, function(controller, name)
        Registry:RegisterController(controller)
    end)
    
    -- 2. Load Components
    Loader.Load(ComponentsFolder, function(component, name)
        Registry:RegisterComponent(component, name)
    end)
    
    -- 3. Initialize & Start
    Loader.InitAll():andThen(function()
        print("[Client Bootstrapper] All modules initialized. Starting lifecycle hooks...")
        Loader.StartAll()
        print("[Client Bootstrapper] Startup sequence completed.")
    end):catch(function(err)
        warn("[Client Bootstrapper] Critical crash during startup sequence: " .. tostring(err))
    end)
end

task.spawn(bootstrap)

return nil
