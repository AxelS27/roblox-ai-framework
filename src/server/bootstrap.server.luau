--!strict
--[=[
    @server
    Server Bootstrapper Entry Point.
    Uses Core/Loader and Core/Registry to load services and CollectionService components.
]=]
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Core = Shared:WaitForChild("Core")
local Registry = require(Core:WaitForChild("Registry"))
local Loader = require(Core:WaitForChild("Loader"))

local ServerFolder = ServerScriptService:WaitForChild("Server")
local ServicesFolder = ServerFolder:WaitForChild("Services")
local ComponentsFolder = ServerFolder:WaitForChild("Components")

local function bootstrap()
    print("[Server Bootstrapper] Initiating startup sequence...")
    
    -- 1. Load Services
    Loader.Load(ServicesFolder, function(service, name)
        Registry:RegisterService(service)
    end)
    
    -- 2. Load Components
    Loader.Load(ComponentsFolder, function(component, name)
        Registry:RegisterComponent(component, name)
    end)
    
    -- 3. Initialize & Start
    Loader.InitAll():andThen(function()
        print("[Server Bootstrapper] All modules initialized. Starting lifecycle hooks...")
        Loader.StartAll()
        print("[Server Bootstrapper] Startup sequence completed.")
    end):catch(function(err)
        warn("[Server Bootstrapper] Critical crash during startup sequence: " .. tostring(err))
    end)
end

task.spawn(bootstrap)

return nil
