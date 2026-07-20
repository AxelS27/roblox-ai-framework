--!strict
-- Roblox Studio Scaffolder for Vibescoding Framework

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")

-- Helper to safely create folders and ModuleScripts
local function getOrCreateFolder(parent: Instance, name: string): Folder
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder :: Folder
end

local function getOrCreateScript(parent: Instance, name: string, scriptType: "Script" | "LocalScript" | "ModuleScript", source: string): Instance
    local scriptObj = parent:FindFirstChild(name)
    if not scriptObj then
        scriptObj = Instance.new(scriptType)
        scriptObj.Name = name
        scriptObj.Parent = parent
    end
    (scriptObj :: any).Source = source
    return scriptObj
end

-- Create Shared folders
local sharedFolder = getOrCreateFolder(ReplicatedStorage, "Shared")
local coreFolder = getOrCreateFolder(sharedFolder, "Core")
local networkFolder = getOrCreateFolder(sharedFolder, "Network")
local packagesFolder = getOrCreateFolder(sharedFolder, "Packages")
local configsFolder = getOrCreateFolder(sharedFolder, "Configs")
local utilitiesFolder = getOrCreateFolder(sharedFolder, "Utilities")

-- Create Server folders
local serverFolder = getOrCreateFolder(ServerScriptService, "Server")
local servicesFolder = getOrCreateFolder(serverFolder, "Services")
local serverComponentsFolder = getOrCreateFolder(serverFolder, "Components")

-- Create Client folders
local clientFolder = getOrCreateFolder(StarterPlayerScripts, "Client")
local controllersFolder = getOrCreateFolder(clientFolder, "Controllers")
local clientComponentsFolder = getOrCreateFolder(clientFolder, "Components")

-- Populate Core Loader
getOrCreateScript(coreFolder, "Loader", "ModuleScript", [==[--!strict
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
            local moduleName = result.Name or moduleScript.Name
            
            -- Register module in Registry
            registerFn(result, moduleName)
            
            -- Cache for lifecycle initialization
            table.insert(loadedModules, result)
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
]==])

-- Populate Core Registry
getOrCreateScript(coreFolder, "Registry", "ModuleScript", [==[--!strict
--[=[
    @class Registry
    @shared
    Central database for all instantiated Services, Controllers, and Components.
    Enables dynamic runtime resolution of modules without direct requiring,
    avoiding circular dependency lockups.
]=]
local Registry = {}

local _services: { [string]: any } = {}
local _controllers: { [string]: any } = {}
local _components: { [string]: any } = {}

-- Service APIs
function Registry:RegisterService(service: any)
    assert(typeof(service) == "table", "Service must be a table")
    assert(typeof(service.Name) == "string", "Service must have a String Name")
    _services[service.Name] = service
end

function Registry:GetService(name: string): any
    local service = _services[name]
    if not service then
        error(string.format("Service '%s' is not registered", name), 2)
    end
    return service
end

-- Controller APIs
function Registry:RegisterController(controller: any)
    assert(typeof(controller) == "table", "Controller must be a table")
    assert(typeof(controller.Name) == "string", "Controller must have a String Name")
    _controllers[controller.Name] = controller
end

function Registry:GetController(name: string): any
    local controller = _controllers[name]
    if not controller then
        error(string.format("Controller '%s' is not registered", name), 2)
    end
    return controller
end

-- Component APIs
function Registry:RegisterComponent(component: any, componentName: string)
    assert(typeof(component) == "table", "Component must be a table")
    _components[componentName] = component
end

function Registry:GetComponent(name: string): any
    local component = _components[name]
    if not component then
        error(string.format("Component '%s' is not registered", name), 2)
    end
    return component
end

return Registry
]==])

-- Populate Network Net
getOrCreateScript(networkFolder, "Net", "ModuleScript", [==[--!strict
--[=[
    @class Net
    @shared
    Centralized Networking module that dynamically creates and resolves
    RemoteEvents and RemoteFunctions, preventing manual work in the Roblox Explorer.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

local isServer = RunService:IsServer()
local remotesFolder: Folder

-- Helper to safely get or create the remotes container
local function getRemotesFolder(): Folder
    if remotesFolder then return remotesFolder end
    
    if isServer then
        local folder = ReplicatedStorage:FindFirstChild("Remotes")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "Remotes"
            folder.Parent = ReplicatedStorage
        end
        remotesFolder = folder :: Folder
    else
        remotesFolder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
    end
    
    return remotesFolder
end

-- Helper to get or create Event/Function sub-containers
local function getContainer(name: string): Folder
    local remotes = getRemotesFolder()
    if isServer then
        local container = remotes:FindFirstChild(name)
        if not container then
            container = Instance.new("Folder")
            container.Name = name
            container.Parent = remotes
        end
        return container :: Folder
    else
        return remotes:WaitForChild(name) :: Folder
    end
end

--[=[
    Gets or creates a RemoteEvent by name.
    @param name string -- The name of the event
    @return RemoteEvent
]=]
function Net:Event(name: string): RemoteEvent
    local container = getContainer("Events")
    if isServer then
        local event = container:FindFirstChild(name)
        if not event then
            event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = container
        end
        return event :: RemoteEvent
    else
        return container:WaitForChild(name) :: RemoteEvent
    end
end

--[=[
    Gets or creates a RemoteFunction by name.
    @param name string -- The name of the function
    @return RemoteFunction
]=]
function Net:Function(name: string): RemoteFunction
    local container = getContainer("Functions")
    if isServer then
        local func = container:FindFirstChild(name)
        if not func then
            func = Instance.new("RemoteFunction")
            func.Name = name
            func.Parent = container
        end
        return func :: RemoteFunction
    else
        return container:WaitForChild(name) :: RemoteFunction
    end
end

return Net
]==])

-- Populate Packages Maid
getOrCreateScript(packagesFolder, "Maid", "ModuleScript", [==[--strict
--[=[
    @class Maid
    Manages the lifecycle of event connections, instances, and functions,
    ensuring they are properly cleaned up to prevent memory leaks.
]=]
local Maid = {}
Maid.__index = Maid

export type MaidTask = 
    RBXScriptConnection 
    | Instance 
    | () -> () 
    | { Destroy: (any) -> () } 
    | { disconnect: (any) -> () }
    | { Destroy: () -> () }
    | { disconnect: () -> () }

export type MaidImpl = {
    _tasks: { [any]: MaidTask },
}

type Self = typeof(setmetatable({} :: MaidImpl, Maid))

--[=[
    Constructs a new Maid object.
    @return Maid
]=]
function Maid.new(): Self
    local self = setmetatable({
        _tasks = {},
    }, Maid)
    return self
end

--[=[
    Adds a task to the Maid for cleanup.
    @param task MaidTask -- The task to track (connection, instance, function, or destroyable object)
    @return any -- Returns the key the task was stored under
]=]
function Maid:GiveTask(task: MaidTask): any
    if not task then
        error("Task cannot be nil", 2)
    end

    local taskId = #self._tasks + 1
    self[taskId] = task
    return taskId
end

--[=[
    Cleans up all tracked tasks and resets the Maid.
]=]
function Maid:DoCleaning()
    local tasks = self._tasks

    -- Clear normal properties first to prevent re-entry issues
    for key, value in self do
        if typeof(key) == "number" or (key ~= "_tasks" and self[key] ~= nil) then
            self[key] = nil
            tasks[key] = value
        end
    end

    for key, task in tasks do
        if typeof(task) == "function" then
            task()
        elseif typeof(task) == "RBXScriptConnection" or (typeof(task) == "userdata" and typeof((task :: any).Disconnect) == "function") then
            (task :: any):Disconnect()
        elseif typeof(task) == "Instance" or (typeof(task) == "table" and typeof((task :: any).Destroy) == "function") then
            (task :: any):Destroy()
        elseif typeof(task) == "table" and typeof((task :: any).disconnect) == "function" then
            (task :: any):disconnect()
        end
        tasks[key] = nil
    end
end

--[=[
    Alias for DoCleaning.
]=]
function Maid:Destroy()
    self:DoCleaning()
end

-- Allow dictionary-like indexing to manage tasks by named key
function Maid:__index(key)
    return Maid[key] or self._tasks[key]
end

function Maid:__newindex(key, value)
    if Maid[key] ~= nil then
        error(string.format("Cannot overwrite Maid method '%s'", tostring(key)), 2)
    end

    local tasks = self._tasks
    local oldTask = tasks[key]
    
    if value == nil then
        tasks[key] = nil
    else
        tasks[key] = value
    end

    -- Clean up old task if overwritten
    if oldTask then
        if typeof(oldTask) == "function" then
            oldTask()
        elseif typeof(oldTask) == "RBXScriptConnection" or (typeof(oldTask) == "userdata" and typeof((oldTask :: any).Disconnect) == "function") then
            (oldTask :: any):Disconnect()
        elseif typeof(oldTask) == "Instance" or (typeof(oldTask) == "table" and typeof((oldTask :: any).Destroy) == "function") then
            (oldTask :: any):Destroy()
        elseif typeof(oldTask) == "table" and typeof((oldTask :: any).disconnect) == "function" then
            (oldTask :: any):disconnect()
        end
    end
end

return Maid
]==])

-- Populate Packages Signal
getOrCreateScript(packagesFolder, "Signal", "ModuleScript", [==[--!strict
--[=[
    @class Signal
    A lightweight, pure-Luau implementation of an event emitter.
    Provides connection and firing mechanics that run in separate threads to prevent errors
    from propagation.
]=]

local Signal = {}
Signal.__index = Signal

type ConnectionImpl = {
    _listener: (...any) -> (),
    _signal: SignalImpl,
    Connected: boolean,
}

local Connection = {}
Connection.__index = Connection

function Connection.new(signal: SignalImpl, listener: (...any) -> ()): typeof(setmetatable({} :: ConnectionImpl, Connection))
    return setmetatable({
        _listener = listener,
        _signal = signal,
        Connected = true,
    }, Connection)
end

function Connection:Disconnect()
    if not self.Connected then return end
    self.Connected = false
    
    local index = table.find(self._signal._connections, self)
    if index then
        table.remove(self._signal._connections, index)
    end
end

export type Connection = typeof(setmetatable({} :: ConnectionImpl, Connection))

export type SignalImpl = {
    _connections: { Connection },
}

type Self = typeof(setmetatable({} :: SignalImpl, Signal))

--[=[
    Constructs a new Signal.
    @return Signal
]=]
function Signal.new(): Self
    return setmetatable({
        _connections = {},
    }, Signal)
end

--[=[
    Connects a listener callback to the signal.
    @param listener (...any) -> () -- Callback function
    @return Connection
]=]
function Signal:Connect(listener: (...any) -> ()): Connection
    local connection = Connection.new(self, listener)
    table.insert(self._connections, connection)
    return connection
end

--[=[
    Fires the signal, calling all listeners in separate deferred threads.
    @param ... any -- Arguments to pass to listeners
]=]
function Signal:Fire(...: any)
    for _, connection in self._connections do
        if connection.Connected then
            task.spawn(connection._listener, ...)
        end
    end
end

--[=[
    Yields the current thread until the signal is fired next, returning arguments.
    @return ... any
]=]
function Signal:Wait(): ...any
    local runningThread = coroutine.running()
    local connection: Connection
    
    connection = self:Connect(function(...: any)
        connection:Disconnect()
        task.spawn(runningThread, ...)
    end)
    
    return coroutine.yield()
end

--[=[
    Disconnects all connections.
]=]
function Signal:Destroy()
    for _, connection in self._connections do
        connection.Connected = false
    end
    table.clear(self._connections)
end

return Signal
]==])

-- Populate Packages Promise
getOrCreateScript(packagesFolder, "Promise", "ModuleScript", [==[--!strict
--[=[
    @class Promise
    A lightweight, simplified pure-Luau implementation of Promises.
    Allows managing asynchronous computations and avoiding callback nesting.
]=]

local Promise = {}
Promise.__index = Promise

export type PromiseState = "Pending" | "Fulfilled" | "Rejected"

type ResolveFn = (...any) -> ()
type RejectFn = (any) -> ()

export type PromiseImpl = {
    _state: PromiseState,
    _values: {any},
    _error: any,
    _onFulfilled: { (...any) -> () },
    _onRejected: { (any) -> () },
}

type Self = typeof(setmetatable({} :: PromiseImpl, Promise))

--[=[
    Creates a new Promise.
    @param executor (resolve: (...any) -> (), reject: (any) -> ()) -> ()
    @return Promise
]=]
function Promise.new(executor: (resolve: ResolveFn, reject: RejectFn) -> ()): Self
    local self = setmetatable({
        _state = "Pending" :: PromiseState,
        _values = {},
        _error = nil,
        _onFulfilled = {},
        _onRejected = {},
    }, Promise)

    local function resolve(...: any)
        if self._state ~= "Pending" then return end
        self._state = "Fulfilled"
        self._values = {...}
        
        for _, callback in self._onFulfilled do
            task.spawn(callback, ...)
        end
        table.clear(self._onFulfilled)
        table.clear(self._onRejected)
    end

    local function reject(err: any)
        if self._state ~= "Pending" then return end
        self._state = "Rejected"
        self._error = err
        
        for _, callback in self._onRejected do
            task.spawn(callback, err)
        end
        table.clear(self._onFulfilled)
        table.clear(self._onRejected)
    end

    task.spawn(function()
        local success, err = pcall(executor, resolve, reject)
        if not success then
            reject(err)
        end
    end)

    return self
end

--[=[
    Creates a Promise that is already resolved with the given values.
]=]
function Promise.resolve(...: any): Self
    return Promise.new(function(resolve)
        resolve(...)
    end)
end

--[=[
    Creates a Promise that is already rejected with the given error.
]=]
function Promise.reject(err: any): Self
    return Promise.new(function(_, reject)
        reject(err)
    end)
end

--[=[
    Attaches callbacks for resolution and/or rejection.
]=]
function Promise:andThen(onFulfilled: (...any) -> (), onRejected: ((any) -> ())?): Self
    return Promise.new(function(resolve, reject)
        local function handleFulfill(...: any)
            local success, result = pcall(onFulfilled, ...)
            if success then
                resolve(result)
            else
                reject(result)
            end
        end

        local function handleReject(err: any)
            if onRejected then
                local success, result = pcall(onRejected, err)
                if success then
                    resolve(result)
                else
                    reject(result)
                end
            else
                reject(err)
            end
        end

        if self._state == "Pending" then
            table.insert(self._onFulfilled, handleFulfill)
            table.insert(self._onRejected, handleReject)
        elseif self._state == "Fulfilled" then
            task.spawn(handleFulfill, unpack(self._values))
        elseif self._state == "Rejected" then
            task.spawn(handleReject, self._error)
        end
    end)
end

--[=[
    Attaches a callback for rejection only.
]=]
function Promise:catch(onRejected: (any) -> ()): Self
    return self:andThen(function(...) return ... end, onRejected)
end

--[=[
    Yields the running thread until the Promise resolves or rejects.
    @return boolean -- Returns true if fulfilled, false if rejected
    @return ... any -- Resolved values or rejection error
]=]
function Promise:await(): (boolean, ...any)
    if self._state == "Fulfilled" then
        return true, unpack(self._values)
    elseif self._state == "Rejected" then
        return false, self._error
    end

    local runningThread = coroutine.running()
    
    self:andThen(function(...: any)
        task.spawn(runningThread, true, ...)
    end, function(err: any)
        task.spawn(runningThread, false, err)
    end)
    
    return coroutine.yield()
end

--[=[
    Returns a Promise that resolves when all of the promises in the given list have resolved,
    or rejects if any of them reject.
    @param promises table -- List of promises
    @return Promise
]=]
function Promise.all(promises: {Self}): Self
    return Promise.new(function(resolve, reject)
        local count = #promises
        if count == 0 then
            resolve({})
            return
        end
        
        local resolvedValues = table.create(count)
        local completed = 0
        
        for i, promise in promises do
            promise:andThen(function(...: any)
                resolvedValues[i] = {...}
                completed += 1
                if completed == count then
                    resolve(resolvedValues)
                end
            end, function(err)
                reject(err)
            end)
        end
    end)
end

return Promise
]==])

-- Populate Configs GameConstants
getOrCreateScript(configsFolder, "GameConstants", "ModuleScript", [==[--!strict
--[=[
    @class GameConstants
    @shared
    Centralized game constants and configuration parameters.
]=]
local GameConstants = {
    -- Player Configs
    MAX_LEVEL = 100,
    BASE_SPEED = 16,
    
    -- Network settings
    PING_BUFFER_STUDS = 5,
    
    -- Collision Tags (for CollectionService Components)
    Tags = {
        INTERACTABLE = "Interactable",
        KILL_BRICK = "KillBrick",
        SPAWN_POINT = "SpawnPoint",
    }
}

return table.freeze(GameConstants)
]==])

-- Populate Utilities Tables
getOrCreateScript(utilitiesFolder, "Tables", "ModuleScript", [==[--!strict
--[=[
    @class Tables
    A collection of utility functions for table manipulation, copying, and freezing in Luau.
]=]
local Tables = {}

--[=[
    Creates a shallow copy of the table.
    @param tbl table -- The source table
    @return table
]=]
function Tables.Copy<T>(tbl: T): T
    local copy = {}
    for k, v in pairs(tbl :: any) do
        copy[k] = v
    end
    return copy :: any
end

--[=[
    Creates a deep copy of the table, copying all nested tables recursively.
    @param tbl table -- The source table
    @return table
]=]
function Tables.DeepCopy<T>(tbl: T): T
    if typeof(tbl) ~= "table" then
        return tbl
    end
    
    local copy = {}
    for k, v in pairs(tbl :: any) do
        copy[Tables.DeepCopy(k)] = Tables.DeepCopy(v)
    end
    return copy :: any
end

--[=[
    Performs a deep freeze on the table, preventing any modifications to this table or its nested tables.
    @param tbl table -- The table to freeze
    @return table -- Returns the frozen table
]=]
function Tables.Freeze<T>(tbl: T): T
    if typeof(tbl) ~= "table" then
        return tbl
    end
    
    if not table.isfrozen(tbl :: any) then
        table.freeze(tbl :: any)
    end
    
    for _, v in pairs(tbl :: any) do
        if typeof(v) == "table" then
            Tables.Freeze(v)
        end
    end
    
    return tbl
end

--[=[
    Fills in missing keys in a target table from a template table.
    Useful for reconciling player data with updated default schemas.
    @param target table -- The table to update
    @param template table -- The source blueprint schema
]=]
function Tables.Reconcile(target: table, template: table)
    for key, value in pairs(template) do
        if target[key] == nil then
            if typeof(value) == "table" then
                target[key] = Tables.DeepCopy(value)
            else
                target[key] = value
            end
        elseif typeof(target[key]) == "table" and typeof(value) == "table" then
            Tables.Reconcile(target[key], value)
        end
    end
end

--[=[
    Gets a list of all keys in a dictionary.
    @param tbl table
    @return array
]=]
function Tables.Keys<K, V>(tbl: {[K]: V}): {K}
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

--[=[
    Gets a list of all values in a dictionary.
    @param tbl table
    @return array
]=]
function Tables.Values<K, V>(tbl: {[K]: V}): {V}
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

return Tables
]==])

-- Populate Server Bootstrap
getOrCreateScript(serverFolder, "Bootstrap", "Script", [==[--!strict
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
]==])

-- Populate Client Bootstrap
getOrCreateScript(clientFolder, "Bootstrap", "LocalScript", [==[--!strict
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
]==])

-- Populate Server ExampleService
getOrCreateScript(servicesFolder, "ExampleService", "ModuleScript", [==[--!strict
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
]==])

-- Populate Client ExampleController
getOrCreateScript(controllersFolder, "ExampleController", "ModuleScript", [==[--strict
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
]==])

-- Populate Server ExampleComponent
getOrCreateScript(serverComponentsFolder, "ExampleComponent", "ModuleScript", [==[--!strict
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
]==])

-- Populate Client ExampleClientComponent
getOrCreateScript(clientComponentsFolder, "ExampleClientComponent", "ModuleScript", [==[--!strict
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
]==])

return "Framework initialized successfully inside Roblox Studio!"
