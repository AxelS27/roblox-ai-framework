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
    Centralized Zero-Trust Networking Subsystem.
    Dynamically creates, caches, and sanitizes RemoteEvents and RemoteFunctions
    under `ReplicatedStorage.Shared.Network.Remotes` without manual Explorer setup.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

local isServer = RunService:IsServer()
local remotesFolder: Folder? = nil

local function getRemotesFolder(): Folder
    if remotesFolder then
        return remotesFolder :: Folder
    end

    local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
    if not sharedFolder then
        if isServer then
            sharedFolder = Instance.new("Folder")
            sharedFolder.Name = "Shared"
            sharedFolder.Parent = ReplicatedStorage
        else
            sharedFolder = ReplicatedStorage:WaitForChild("Shared")
        end
    end

    local networkFolder = (sharedFolder :: Instance):FindFirstChild("Network")
    if not networkFolder then
        if isServer then
            networkFolder = Instance.new("Folder")
            networkFolder.Name = "Network"
            networkFolder.Parent = sharedFolder
        else
            networkFolder = (sharedFolder :: Instance):WaitForChild("Network")
        end
    end

    local folder = (networkFolder :: Instance):FindFirstChild("Remotes")
    if not folder then
        if isServer then
            folder = Instance.new("Folder")
            folder.Name = "Remotes"
            folder.Parent = networkFolder
        else
            folder = (networkFolder :: Instance):WaitForChild("Remotes")
        end
    end

    remotesFolder = folder :: Folder
    return remotesFolder :: Folder
end

local function getContainer(containerName: string): Folder
    local remotes = getRemotesFolder()
    local container = remotes:FindFirstChild(containerName)
    if not container then
        if isServer then
            container = Instance.new("Folder")
            container.Name = containerName
            container.Parent = remotes
        else
            container = remotes:WaitForChild(containerName)
        end
    end
    return container :: Folder
end

function Net.SanitizeNumber(value: any): boolean
    if type(value) ~= "number" then return false end
    if value ~= value then return false end
    if value == math.huge or value == -math.huge then return false end
    return true
end

function Net.SanitizeArgs(args: {any}): boolean
    for _, arg in ipairs(args) do
        if type(arg) == "number" then
            if not Net.SanitizeNumber(arg) then return false end
        elseif type(arg) == "table" then
            for k, v in pairs(arg) do
                if type(k) == "number" and not Net.SanitizeNumber(k) then return false end
                if type(v) == "number" and not Net.SanitizeNumber(v) then return false end
            end
        end
    end
    return true
end

function Net:GetEvent(name: string): RemoteEvent
    local container = getContainer("Events")
    local event = container:FindFirstChild(name)
    if not event then
        if isServer then
            event = Instance.new("RemoteEvent")
            event.Name = name
            event.Parent = container
        else
            event = container:WaitForChild(name, 1000) :: RemoteEvent
        end
    end
    return event :: RemoteEvent
end

function Net:Event(name: string): RemoteEvent
    return self:GetEvent(name)
end

function Net:GetFunction(name: string): RemoteFunction
    local container = getContainer("Functions")
    local func = container:FindFirstChild(name)
    if not func then
        if isServer then
            func = Instance.new("RemoteFunction")
            func.Name = name
            func.Parent = container
        else
            func = container:WaitForChild(name, 1000) :: RemoteFunction
        end
    end
    return func :: RemoteFunction
end

function Net:Function(name: string): RemoteFunction
    return self:GetFunction(name)
end

function Net:FireClient(player: Player, eventName: string, ...: any)
    assert(isServer, "Net:FireClient can only be called from the server")
    local event = self:GetEvent(eventName)
    event:FireClient(player, ...)
end

function Net:FireAllClients(eventName: string, ...: any)
    assert(isServer, "Net:FireAllClients can only be called from the server")
    local event = self:GetEvent(eventName)
    event:FireAllClients(...)
end

function Net:FireServer(eventName: string, ...: any)
    assert(not isServer, "Net:FireServer can only be called from the client")
    local event = self:GetEvent(eventName)
    event:FireServer(...)
end

function Net:ConnectServer(eventName: string, handler: (player: Player, ...any) -> ()): RBXScriptConnection
    assert(isServer, "Net:ConnectServer can only be called on the server")
    local event = self:GetEvent(eventName)
    return event.OnServerEvent:Connect(function(player: Player, ...: any)
        local args = { ... }
        if not Net.SanitizeArgs(args) then
            warn(string.format("[Net Zero-Trust Guard] Dropped malicious or invalid payload (NaN/Inf) from player '%s' for event '%s'", player.Name, eventName))
            return
        end
        handler(player, ...)
    end)
end

function Net:ConnectClient(eventName: string, handler: (...any) -> ()): RBXScriptConnection
    assert(not isServer, "Net:ConnectClient can only be called on the client")
    local event = self:GetEvent(eventName)
    return event.OnClientEvent:Connect(handler)
end

function Net:SetCallback(functionName: string, callback: (player: Player, ...any) -> ...any)
    assert(isServer, "Net:SetCallback can only be called on the server")
    local func = self:GetFunction(functionName)
    func.OnServerInvoke = function(player: Player, ...: any)
        local args = { ... }
        if not Net.SanitizeArgs(args) then
            warn(string.format("[Net Zero-Trust Guard] Rejected RemoteFunction invocation (NaN/Inf) from player '%s' for function '%s'", player.Name, functionName))
            return nil
        end
        return callback(player, ...)
    end
end

function Net:InvokeServer(functionName: string, ...: any): ...any
    assert(not isServer, "Net:InvokeServer can only be called on the client")
    local func = self:GetFunction(functionName)
    return func:InvokeServer(...)
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
    local args = { ... }
    return Promise.new(function(resolve)
        resolve(table.unpack(args))
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

-- Populate Utilities UIAnimate
getOrCreateScript(utilitiesFolder, "UIAnimate", "ModuleScript", [==[--!strict
--[=[
    @class UIAnimate
    @shared
    Elite UI Animation utility refactored and expanded from JakeDev's UI Animation Pack.
    Provides reusable, performant, and clean TweenService bindings for buttons and frames.
]=]

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local UIAnimate = {}

local DEFAULT_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local DEFAULT_BOUNCE_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local DEFAULT_SHINE_INFO = TweenInfo.new(1.0, Enum.EasingStyle.Circular, Enum.EasingDirection.In, -1, false)

-- Helper to scale UDim2
local function scaleUDim2(orig: UDim2, scl: number): UDim2
	return UDim2.new(
		orig.X.Scale * scl,
		orig.X.Offset * scl,
		orig.Y.Scale * scl,
		orig.Y.Offset * scl
	)
end

-- Helper to offset UDim2 Position on Y axis
local function offsetYUDim2(orig: UDim2, offsetScale: number): UDim2
	return UDim2.new(
		orig.X.Scale,
		orig.X.Offset,
		orig.Y.Scale + offsetScale,
		orig.Y.Offset
	)
end

-- 1. Bind Hover & Click Scale (Bounce Effect)
function UIAnimate.bindHoverScale(button: GuiButton, hoverScl: number?, clickScl: number?, tInfo: TweenInfo?): () -> ()
	local origSize = button.Size
	local hScl = hoverScl or 1.1
	local cScl = clickScl or 0.9
	local info = tInfo or DEFAULT_TWEEN_INFO

	local function playTween(scl: number)
		local newSize = scaleUDim2(origSize, scl)
		TweenService:Create(button, info, {Size = newSize}):Play()
	end

	local enterConn = button.MouseEnter:Connect(function()
		playTween(hScl)
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		playTween(1)
	end)

	local isClicking = false
	local clickConn = button.MouseButton1Click:Connect(function()
		if isClicking then return end
		isClicking = true
		
		local shrink = TweenService:Create(button, info, {Size = scaleUDim2(origSize, cScl)})
		local reset = TweenService:Create(button, info, {Size = origSize})
		
		shrink:Play()
		local conn
		conn = shrink.Completed:Connect(function()
			conn:Disconnect()
			reset:Play()
			local connReset
			connReset = reset.Completed:Connect(function()
				connReset:Disconnect()
				isClicking = false
			end)
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		clickConn:Disconnect()
	end
end

-- 2. Bind Color Shift on Hover (Supports Background, Image, and Text Colors)
function UIAnimate.bindHoverColor(button: GuiButton, hoverColor: Color3, originalColor: Color3, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO

	-- Determine target property
	local targetProperty = "BackgroundColor3"
	if button:IsA("ImageButton") then
		targetProperty = "ImageColor3"
	elseif button:IsA("TextButton") and not button.BackgroundTransparency == 1 then
		targetProperty = "BackgroundColor3"
	elseif button:IsA("TextButton") then
		targetProperty = "TextColor3"
	end

	local enterConn = button.MouseEnter:Connect(function()
		TweenService:Create(button, info, {[targetProperty] = hoverColor}):Play()
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		TweenService:Create(button, info, {[targetProperty] = originalColor}):Play()
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 3. Bind UIStroke Thickness Scale on Hover
function UIAnimate.bindStrokeScale(button: GuiButton, stroke: UIStroke, hoverThickOffset: number?, tInfo: TweenInfo?): () -> ()
	local origThick = stroke.Thickness
	local hoverThick = origThick + (hoverThickOffset or 2)
	local info = tInfo or DEFAULT_TWEEN_INFO

	local enterConn = button.MouseEnter:Connect(function()
		TweenService:Create(stroke, info, {Thickness = hoverThick}):Play()
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		TweenService:Create(stroke, info, {Thickness = origThick}):Play()
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 4. Bind UIStroke Visibility Toggle on Hover
function UIAnimate.bindStrokeVisibility(button: GuiButton, stroke: UIStroke, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO

	stroke.Enabled = false

	local enterConn = button.MouseEnter:Connect(function()
		stroke.Enabled = true
		stroke.Transparency = 1
		TweenService:Create(stroke, info, {Transparency = 0}):Play()
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		local tween = TweenService:Create(stroke, info, {Transparency = 1})
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			if not stroke.Enabled then return end
			stroke.Enabled = false
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 5. Bind Icon Wiggle Rotation on Hover
function UIAnimate.bindIconWiggle(button: GuiButton, icon: ImageLabel, wiggleRotOffset: number?, tInfo: TweenInfo?): () -> ()
	local origRot = icon.Rotation
	local wiggleRot = wiggleRotOffset or 10
	local info = tInfo or DEFAULT_TWEEN_INFO
	local isClicking = false

	local enterConn = button.MouseEnter:Connect(function()
		if isClicking then return end
		local tweens = {
			TweenService:Create(icon, info, {Rotation = wiggleRot}),
			TweenService:Create(icon, info, {Rotation = -wiggleRot}),
			TweenService:Create(icon, info, {Rotation = wiggleRot}),
			TweenService:Create(icon, info, {Rotation = origRot})
		}
		
		tweens[1]:Play()
		for i = 1, #tweens - 1 do
			local conn
			conn = tweens[i].Completed:Connect(function()
				conn:Disconnect()
				tweens[i + 1]:Play()
			end)
		end
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		if isClicking then return end
		TweenService:Create(icon, info, {Rotation = origRot}):Play()
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
	end
end

-- 6. Bind Rotate & Scale Hover (Simulator Button Effect)
function UIAnimate.bindRotateHoverScale(button: GuiButton, hoverScl: number?, hoverRot: number?, clickScl: number?, tInfo: TweenInfo?): () -> ()
	local origSize = button.Size
	local hScl = hoverScl or 1.1
	local hRot = hoverRot or 10
	local cScl = clickScl or 0.9
	local info = tInfo or DEFAULT_TWEEN_INFO

	local function playTween(scl: number, rot: number)
		local newSize = scaleUDim2(origSize, scl)
		TweenService:Create(button, info, {Size = newSize, Rotation = rot}):Play()
	end

	local enterConn = button.MouseEnter:Connect(function()
		playTween(hScl, hRot)
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		playTween(1, 0)
	end)

	local isClicking = false
	local clickConn = button.MouseButton1Click:Connect(function()
		if isClicking then return end
		isClicking = true
		
		local shrink = TweenService:Create(button, info, {Size = scaleUDim2(origSize, cScl), Rotation = 0})
		local reset = TweenService:Create(button, info, {Size = origSize, Rotation = 0})
		
		shrink:Play()
		local conn
		conn = shrink.Completed:Connect(function()
			conn:Disconnect()
			reset:Play()
			local connReset
			connReset = reset.Completed:Connect(function()
				connReset:Disconnect()
				isClicking = false
			end)
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		clickConn:Disconnect()
	end
end

-- 7. Bind Position Bounce on Click
function UIAnimate.bindClickBouncePos(button: GuiButton, hoverScl: number?, bounceUpScale: number?, bounceDownScale: number?, tInfo: TweenInfo?): () -> ()
	local origSize = button.Size
	local origPos = button.Position
	local hScl = hoverScl or 1.1
	local bUp = bounceUpScale or -0.02
	local bDown = bounceDownScale or 0.02
	local info = tInfo or DEFAULT_TWEEN_INFO
	local isClicking = false

	local function sizeTween(scl: number)
		return TweenService:Create(button, info, {Size = scaleUDim2(origSize, scl)})
	end

	local function posTween(offsetY: number)
		return TweenService:Create(button, info, {Position = offsetYUDim2(origPos, offsetY)})
	end

	local enterConn = button.MouseEnter:Connect(function()
		if not isClicking then
			sizeTween(hScl):Play()
		end
	end)

	local leaveConn = button.MouseLeave:Connect(function()
		if not isClicking then
			sizeTween(1):Play()
		end
	end)

	local clickConn = button.MouseButton1Click:Connect(function()
		if isClicking then return end
		isClicking = true

		local tweens = {
			sizeTween(1),
			posTween(bUp),
			posTween(bDown),
			posTween(0)
		}

		tweens[1]:Play()
		for i = 1, #tweens - 1 do
			local conn
			conn = tweens[i].Completed:Connect(function()
				conn:Disconnect()
				tweens[i + 1]:Play()
			end)
		end

		local connEnd
		connEnd = tweens[#tweens].Completed:Connect(function()
			connEnd:Disconnect()
			isClicking = false
		end)
	end)

	return function()
		enterConn:Disconnect()
		leaveConn:Disconnect()
		clickConn:Disconnect()
	end
end

-- 8. Bind RileyBytes Shiny Button Effect
function UIAnimate.bindShineEffect(button: GuiButton, shineFrame: Frame, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_SHINE_INFO
	
	shineFrame.Position = UDim2.fromScale(-0.5, 0.5)
	local tween = TweenService:Create(shineFrame, info, {Position = UDim2.fromScale(1.5, 0.5)})
	tween:Play()

	return function()
		tween:Cancel()
	end
end

-- 9. Toggle Scale Pop Frame Transition (Using UIScale & EasingStyle.Back)
function UIAnimate.toggleScalePop(frame: GuiObject, isOpen: boolean, tInfoIn: TweenInfo?, tInfoOut: TweenInfo?): () -> ()
	local scale = frame:FindFirstChildOfClass("UIScale") :: UIScale?
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = frame
	end
	
	local uiScale = scale :: UIScale
	local infoIn = tInfoIn or TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local infoOut = tInfoOut or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	if isOpen then
		frame.Visible = true
		uiScale.Scale = 0
		TweenService:Create(uiScale, infoIn, {Scale = 1}):Play()
	else
		local shrink = TweenService:Create(uiScale, infoOut, {Scale = 0})
		shrink:Play()
		local conn
		conn = shrink.Completed:Connect(function()
			conn:Disconnect()
			if uiScale.Scale == 0 then
				frame.Visible = false
			end
		end)
	end

	return function() end
end

-- 10. Standalone Popup Frame Transition (Size & Transparency)
function UIAnimate.popup(frame: GuiObject, origSize: UDim2, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO

	if isOpen then
		frame.Visible = true
		TweenService:Create(frame, info, {
			Size = origSize,
			BackgroundTransparency = 0
		}):Play()
	else
		local tween = TweenService:Create(frame, info, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

-- 11. Standalone Bouncing Frame Transition (Elastic Bouncy Zoom)
function UIAnimate.bounce(frame: GuiObject, origSize: UDim2, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_BOUNCE_INFO

	local function makeSizeTween(scl: number, alpha: number)
		return TweenService:Create(frame, info, {
			Size = scaleUDim2(origSize, scl),
			BackgroundTransparency = alpha
		})
	end

	if isOpen then
		frame.Visible = true
		local tweens = {
			makeSizeTween(1.2, 0),
			makeSizeTween(0.8, 0),
			makeSizeTween(1.0, 0)
		}
		
		tweens[1]:Play()
		for i = 1, #tweens - 1 do
			local conn
			conn = tweens[i].Completed:Connect(function()
				conn:Disconnect()
				tweens[i + 1]:Play()
			end)
		end
	else
		local tween = makeSizeTween(0, 1)
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

-- 12. Standalone Rotate In Frame Transition
function UIAnimate.rotateIn(frame: GuiObject, origSize: UDim2, startRot: number?, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO
	local rotVal = startRot or 15

	if isOpen then
		frame.Visible = true
		frame.Rotation = rotVal
		TweenService:Create(frame, info, {
			Size = origSize,
			BackgroundTransparency = 0,
			Rotation = 0
		}):Play()
	else
		local tween = TweenService:Create(frame, info, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Rotation = rotVal
		})
		tween:Play()
		local conn
		conn = tween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

-- 13. Standalone FOV & Screen Blur Camera Transition
function UIAnimate.fovTransition(frame: GuiObject, origSize: UDim2, isOpen: boolean, tInfo: TweenInfo?): () -> ()
	local info = tInfo or DEFAULT_TWEEN_INFO
	local camera = workspace.CurrentCamera
	
	local blur = Lighting:FindFirstChild("UIBlurEffect") :: BlurEffect?
	if not blur then
		local newBlur = Instance.new("BlurEffect")
		newBlur.Name = "UIBlurEffect"
		newBlur.Size = 0
		newBlur.Parent = Lighting
		blur = newBlur
	end

	if isOpen then
		frame.Visible = true
		TweenService:Create(frame, info, {Size = origSize, BackgroundTransparency = 0}):Play()
		TweenService:Create(camera, info, {FieldOfView = 80}):Play()
		TweenService:Create(blur, info, {Size = 20}):Play()
	else
		local frameTween = TweenService:Create(frame, info, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
		frameTween:Play()
		TweenService:Create(camera, info, {FieldOfView = 70}):Play()
		TweenService:Create(blur, info, {Size = 0}):Play()
		
		local conn
		conn = frameTween.Completed:Connect(function()
			conn:Disconnect()
			frame.Visible = false
		end)
	end

	return function() end
end

return UIAnimate
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

-- Populate Server DebugService
getOrCreateScript(servicesFolder, "DebugService", "ModuleScript", [==[--!strict
--[=[
    @class DebugService
    @server
    Secured developer-only console execution backend.
]=]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Network"):WaitForChild("Net"))

local DebugService = {
    Name = "DebugService",
    AuthorizedUsers = {
        [game.CreatorId] = true,
    }
}

function DebugService:IsAuthorized(player: Player): boolean
    if RunService:IsStudio() then
        return true
    end
    return self.AuthorizedUsers[player.UserId] == true
end

function DebugService:Init()
    local debugCmdEvent = Net:Event("DebugCommand")

    debugCmdEvent.OnServerEvent:Connect(function(player: Player, commandName: string, ...: any)
        if not self:IsAuthorized(player) then
            warn("[Security] Unauthorized debug command by player: " .. player.Name)
            return
        end

        local args = {...}
        print(string.format("[Debug] Admin %s ran command: %s", player.Name, commandName))

        if commandName == "AddDNA" then
            local stats = player:FindFirstChild("leaderstats")
            if stats then
                local dnaVal = stats:FindFirstChild("DNA") or stats:FindFirstChild("Dna")
                if dnaVal and dnaVal:IsA("ValueObject") then
                    (dnaVal :: any).Value = ((dnaVal :: any).Value or 0) + (args[1] or 1000)
                end
            end
        elseif commandName == "SkipTimer" then
            -- Custom match/timer skip callbacks can be triggered here
        elseif commandName == "ToggleGodMode" then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                end
            end
        end
    end)
end

return DebugService
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

-- Populate Client AudioController
getOrCreateScript(controllersFolder, "AudioController", "ModuleScript", [==[--!strict
--[=[
    @class AudioController
    @client
    Manages client-side BGM cross-fading, automatic UI sound effects, and spatial 3D audio.
]=]
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local AudioController = {
    Name = "AudioController",
    CurrentBGM = nil :: Sound?,
    
    Sounds = {
        UI_HOVER = "rbxassetid://9119565538",
        UI_CLICK = "rbxassetid://9119565614",
        EVOLVE = "rbxassetid://9123891039",
        EAT = "rbxassetid://9114223126",
    }
}

local bgmGroup: SoundGroup
local sfxGroup: SoundGroup
local maid = Maid.new()

function AudioController:PlaySFX(soundId: string, volume: number?, pitch: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.4
    sound.PlaybackSpeed = pitch or 1.0
    sound.SoundGroup = sfxGroup
    sound.Parent = SoundService

    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

function AudioController:PlaySpatialSFX(soundId: string, target: Vector3 | BasePart, maxDistance: number?, volume: number?, pitch: number?)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or 0.5
    sound.PlaybackSpeed = pitch or 1.0
    sound.SoundGroup = sfxGroup
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.MaxDistance = maxDistance or 60

    if typeof(target) == "Vector3" then
        local attachment = Instance.new("Attachment")
        attachment.WorldPosition = target
        attachment.Parent = workspace.Terrain
        
        sound.Parent = attachment
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
            attachment:Destroy()
        end)
    elseif target:IsA("BasePart") then
        sound.Parent = target
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
end

function AudioController:PlayBGM(soundId: string, fadeDuration: number?)
    local fadeTime = fadeDuration or 1.5

    if self.CurrentBGM then
        local oldBGM = self.CurrentBGM
        local fadeOut = TweenService:Create(oldBGM, TweenInfo.new(fadeTime), { Volume = 0 })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            oldBGM:Stop()
            oldBGM:Destroy()
        end)
    end

    local newBGM = Instance.new("Sound")
    newBGM.SoundId = soundId
    newBGM.Volume = 0
    newBGM.Looped = true
    newBGM.SoundGroup = bgmGroup
    newBGM.Parent = SoundService

    self.CurrentBGM = newBGM
    newBGM:Play()

    TweenService:Create(newBGM, TweenInfo.new(fadeTime), { Volume = 0.3 }):Play()
end

function AudioController:BindUISounds(parent: Instance)
    local function applyTo(instance: Instance)
        if instance:IsA("GuiButton") then
            instance.MouseEnter:Connect(function()
                self:PlaySFX(self.Sounds.UI_HOVER, 0.2, 1.1)
            end)
            instance.MouseButton1Click:Connect(function()
                self:PlaySFX(self.Sounds.UI_CLICK, 0.35, 1.0)
            end)
        end
        for _, child in instance:GetChildren() do
            applyTo(child)
        end
    end
    applyTo(parent)
end

function AudioController:Init()
    bgmGroup = SoundService:FindFirstChild("BGM") or Instance.new("SoundGroup")
    bgmGroup.Name = "BGM"
    bgmGroup.Parent = SoundService

    sfxGroup = SoundService:FindFirstChild("SFX") or Instance.new("SoundGroup")
    sfxGroup.Name = "SFX"
    sfxGroup.Parent = SoundService
    
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    playerGui.ChildAdded:Connect(function(child)
        self:BindUISounds(child)
    end)
    
    for _, child in playerGui:GetChildren() do
        self:BindUISounds(child)
    end
end

return AudioController
]==])

-- Populate Client EffectsController
getOrCreateScript(controllersFolder, "EffectsController", "ModuleScript", [==[--!strict
--[=[
    @class EffectsController
    @client
    Manages client-side particle emissions, distance culling, and floating 3D damage numbers.
]=]
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local MAX_VFX_DISTANCE = 150

local EffectsController = {
    Name = "EffectsController"
}

function EffectsController:IsWithinBudget(targetPosition: Vector3, customDistance: number?): boolean
    local camera = Workspace.CurrentCamera
    if not camera then return false end

    local distance = (camera.CFrame.Position - targetPosition).Magnitude
    return distance <= (customDistance or MAX_VFX_DISTANCE)
end

function EffectsController:EmitParticles(emitterTemplate: ParticleEmitter, attachment: Attachment, count: number)
    if not self:IsWithinBudget(attachment.WorldPosition) then
        return
    end

    local clone = emitterTemplate:Clone()
    clone.Parent = attachment
    clone:Emit(count)

    Debris:AddItem(clone, clone.Lifetime.Max + 1)
end

function EffectsController:SpawnBurstAt(cframe: CFrame, color: Color3, particleCount: number?)
    if not self:IsWithinBudget(cframe.Position) then
        return
    end

    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.CFrame = cframe
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.Parent = Workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(color)
    emitter.Size = NumberSequence.new(0.5, 0)
    emitter.Speed = NumberRange.new(5, 12)
    emitter.Lifetime = NumberRange.new(0.5, 1)
    emitter.Parent = part

    emitter:Emit(particleCount or 20)
    Debris:AddItem(part, 1.5)
end

function EffectsController:SpawnDamageNumber(position: Vector3, damage: number, isCritical: boolean?)
    if not self:IsWithinBudget(position) then
        return
    end

    local part = Instance.new("Part")
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Position = position + Vector3.new(math.random(-2, 2), 2, math.random(-2, 2))
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.fromOffset(120, 60)
    billboard.AlwaysOnTop = true
    billboard.ExtentsOffset = Vector3.new(0, 1.5, 0)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = tostring(math.round(damage))
    label.Font = Enum.Font.MontserratBold
    label.TextSize = isCritical and 24 or 16
    label.TextColor3 = isCritical and Color3.fromRGB(245, 158, 11) or Color3.fromRGB(239, 68, 68)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = label
    label.Parent = billboard

    local floatDuration = 0.8
    local tweenInfo = TweenInfo.new(floatDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    TweenService:Create(billboard, tweenInfo, { ExtentsOffset = Vector3.new(0, 4, 0) }):Play()
    TweenService:Create(label, tweenInfo, { TextTransparency = 1 }):Play()
    TweenService:Create(stroke, tweenInfo, { Transparency = 1 }):Play()

    Debris:AddItem(part, floatDuration)
end

function EffectsController:Init()
    print("[Client] EffectsController initialized with Distance-Culling.")
end

return EffectsController
]==])

-- Populate Client DebugController
getOrCreateScript(controllersFolder, "DebugController", "ModuleScript", [==[--!strict
--[=[
    @class DebugController
    @client
    Manages developer debug UI panel overlays and debug inputs.
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared:WaitForChild("Network"):WaitForChild("Net"))

local DebugController = {
    Name = "DebugController"
}

function DebugController:ExecuteCommand(commandName: string, ...: any)
    Net:Event("DebugCommand"):FireServer(commandName, ...)
end

function DebugController:Init()
    -- Open Debug menu on pressing semicolon (;) in Studio or if authorized
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Semicolon then
            print("[Debug] Semicolon key pressed. Toggling Developer Debug UI Panel...")
            -- Trigger dev panel UI toggle here
        end
    end)
end

return DebugController
]==])

-- Populate Client CameraController
getOrCreateScript(controllersFolder, "CameraController", "ModuleScript", [==[--!strict
--[=[
    @class CameraController
    @client
    Manages client-side camera state machine and line-of-sight transparency occlusion.
]=]
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local CameraController = {
    Name = "CameraController",
    CurrentState = "ThirdPerson",
}

local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer
local maid = Maid.new()
local occludedParts: { [BasePart]: number } = {}

export type CameraMode = "ThirdPerson" | "FirstPerson" | "ViewportFocus" | "DroneCinematic" | "Cutscene"

local function updateOcclusion()
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not head or (humanoid and humanoid.Health <= 0) then return end
    
    local rayOrigin = camera.CFrame.Position
    local rayDirection = (head.Position - rayOrigin)
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    
    local result = workspace:Raycast(rayOrigin, rayDirection, params)
    
    for part, originalTrans in pairs(occludedParts) do
        if not part or not part.Parent or not result or result.Instance ~= part then
            part.Transparency = originalTrans
            occludedParts[part] = nil
        end
    end
    
    if result and result.Instance:IsA("BasePart") and not result.Instance.CanCollide then
        local part = result.Instance
        if not occludedParts[part] then
            occludedParts[part] = part.Transparency
            part.Transparency = 0.5
        end
    end
end

function CameraController:SetState(mode: CameraMode, focusTarget: (BasePart | CFrame)?, duration: number?)
    maid:DoCleaning()
    self.CurrentState = mode

    local transitionTime = duration or 0.5

    if mode == "ThirdPerson" then
        camera.CameraType = Enum.CameraType.Custom
        player.CameraMinZoomDistance = 5
        player.CameraMaxZoomDistance = 25
        camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

    elseif mode == "FirstPerson" then
        camera.CameraType = Enum.CameraType.Custom
        player.CameraMinZoomDistance = 0.5
        player.CameraMaxZoomDistance = 0.5
        camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

    elseif mode == "ViewportFocus" then
        assert(focusTarget, "ViewportFocus state requires a target BasePart or CFrame")
        camera.CameraType = Enum.CameraType.Scriptable

        local targetCFrame: CFrame
        if typeof(focusTarget) == "Instance" and (focusTarget :: Instance):IsA("BasePart") then
            targetCFrame = (focusTarget :: BasePart).CFrame * CFrame.new(0, 1.5, 6)
        else
            targetCFrame = focusTarget :: CFrame
        end

        TweenService:Create(camera, TweenInfo.new(transitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = targetCFrame,
            FieldOfView = 60
        }):Play()

    elseif mode == "DroneCinematic" then
        camera.CameraType = Enum.CameraType.Scriptable
        local centerPoint = (typeof(focusTarget) == "CFrame" and focusTarget) or (player.Character and player.Character:GetPivot()) or CFrame.new(0, 10, 0)
        local radius = 35
        local speed = 0.3
        local angle = 0

        maid:GiveTask(RunService.RenderStepped:Connect(function(dt)
            angle += dt * speed
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            local camPos = centerPoint.Position + Vector3.new(x, 18, z)
            camera.CFrame = CFrame.lookAt(camPos, centerPoint.Position)
        end))
    end
end

function CameraController:Init()
    print("[Client] CameraController initialized.")
    RunService.RenderStepped:Connect(updateOcclusion)
end

function CameraController:Start()
    self:SetState("ThirdPerson")
end

return CameraController
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
