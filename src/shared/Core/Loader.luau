--!strict
--[=[
    @class Loader
    @shared
    Responsible for recursively requiring game modules (Services, Controllers, Components),
    registering them, and executing their initialization and start lifecycles.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Promise = require(Packages:WaitForChild("Promise"))

local Loader = {}

type ModuleLifecycle = {
    Name: string?,
    Init: ((any) -> ())?,
    Start: ((any) -> ())?,
}

local loadedModules: { ModuleLifecycle } = {}

-- Helper to recursively search folders for ModuleScripts
local function gatherModules(folder: Instance): {ModuleScript}
    local modules = {}
    for _, child in folder:GetChildren() do
        if child:IsA("ModuleScript") then
            table.insert(modules, child)
        elseif child:IsA("Folder") then
            local subModules = gatherModules(child)
            for _, subModule in subModules do
                table.insert(modules, subModule)
            end
        end
    end
    return modules
end

--[=[
    Recursively loads all modules inside the specified folder and registers them.
    @param folder Instance -- The directory folder containing modules
    @param registerFn (module: any, moduleName: string) -> () -- Callback to register module
]=]
function Loader.Load(folder: Instance, registerFn: (module: any, name: string) -> ())
    local modules = gatherModules(folder)
    
    for _, moduleScript in modules do
        local success, result = pcall(require, moduleScript)
        if success and typeof(result) == "table" then
            local moduleName = result.Name
            if typeof(moduleName) == "string" then
                -- Register module in Registry
                registerFn(result, moduleName)
                
                -- Cache for lifecycle initialization
                table.insert(loadedModules, result)
            end
        else
            warn(string.format("[Core Loader] Failed to load module: %s. Error: %s", moduleScript:GetFullName(), tostring(result)))
        end
    end
end

--[=[
    Executes the Init() stage for all loaded modules in parallel, returning a Promise.
    @return Promise
]=]
function Loader.InitAll(): any
    local promises = {}
    
    for _, module in loadedModules do
        if typeof(module.Init) == "function" then
            table.insert(promises, Promise.new(function(resolve)
                module:Init()
                resolve()
            end))
        end
    end
    
    return Promise.all(promises)
end

--[=[
    Executes the Start() stage for all loaded modules in separate spawned threads.
]=]
function Loader.StartAll()
    for _, module in loadedModules do
        if typeof(module.Start) == "function" then
            task.spawn(function()
                local success, err = pcall(module.Start, module)
                if not success then
                    local name = module.Name or "UnknownModule"
                    warn(string.format("[Core Loader] Error starting module %s: %s", name, tostring(err)))
                end
            end)
        end
    end
end

return Loader
