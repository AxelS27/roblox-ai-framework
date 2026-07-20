--!strict
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

--[=[
    Safely resolves or creates the central Remotes folder under ReplicatedStorage.Shared.Network.Remotes.
    @return Folder
]=]
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

--[=[
    Resolves or creates sub-containers ("Events" or "Functions") inside the Remotes directory.
]=]
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

--[=[
    Validates whether a number is a valid finite real number (not NaN or Inf).
    @param value number
    @return boolean
]=]
function Net.SanitizeNumber(value: any): boolean
    if type(value) ~= "number" then
        return false
    end
    -- In Luau, NaN != NaN evaluates to true.
    if value ~= value then
        return false
    end
    if value == math.huge or value == -math.huge then
        return false
    end
    return true
end

--[=[
    Recursively scans input arguments to ensure no NaN or infinite floating point numbers are passed.
    @param args {any}
    @return boolean
]=]
function Net.SanitizeArgs(args: {any}): boolean
    for _, arg in ipairs(args) do
        if type(arg) == "number" then
            if not Net.SanitizeNumber(arg) then
                return false
            end
        elseif type(arg) == "table" then
            for k, v in pairs(arg) do
                if type(k) == "number" and not Net.SanitizeNumber(k) then
                    return false
                end
                if type(v) == "number" and not Net.SanitizeNumber(v) then
                    return false
                end
            end
        end
    end
    return true
end

--[=[
    Gets or creates a RemoteEvent by name.
    @param name string
    @return RemoteEvent
]=]
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

-- Alias for backwards compatibility
function Net:Event(name: string): RemoteEvent
    return self:GetEvent(name)
end

--[=[
    Gets or creates a RemoteFunction by name.
    @param name string
    @return RemoteFunction
]=]
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

-- Alias for backwards compatibility
function Net:Function(name: string): RemoteFunction
    return self:GetFunction(name)
end

--[=[
    Fires a RemoteEvent to a specific client player. (Server-side)
    @param player Player
    @param eventName string
    @param ... any
]=]
function Net:FireClient(player: Player, eventName: string, ...: any)
    assert(isServer, "Net:FireClient can only be called from the server")
    local event = self:GetEvent(eventName)
    event:FireClient(player, ...)
end

--[=[
    Fires a RemoteEvent to all connected clients. (Server-side)
    @param eventName string
    @param ... any
]=]
function Net:FireAllClients(eventName: string, ...: any)
    assert(isServer, "Net:FireAllClients can only be called from the server")
    local event = self:GetEvent(eventName)
    event:FireAllClients(...)
end

--[=[
    Fires a RemoteEvent to the server. (Client-side)
    @param eventName string
    @param ... any
]=]
function Net:FireServer(eventName: string, ...: any)
    assert(not isServer, "Net:FireServer can only be called from the client")
    local event = self:GetEvent(eventName)
    event:FireServer(...)
end

--[=[
    Connects a Zero-Trust server handler to a RemoteEvent. Automatically sanitizes inbound payload arguments.
    @param eventName string
    @param handler (player: Player, ...any) -> ()
    @return RBXScriptConnection
]=]
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

--[=[
    Connects a client handler to a RemoteEvent.
    @param eventName string
    @param handler (...any) -> ()
    @return RBXScriptConnection
]=]
function Net:ConnectClient(eventName: string, handler: (...any) -> ()): RBXScriptConnection
    assert(not isServer, "Net:ConnectClient can only be called on the client")
    local event = self:GetEvent(eventName)
    return event.OnClientEvent:Connect(handler)
end

--[=[
    Sets a Zero-Trust callback for a RemoteFunction on the server.
    @param functionName string
    @param callback (player: Player, ...any) -> ...any
]=]
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

--[=[
    Invokes a RemoteFunction on the server. (Client-side)
    @param functionName string
    @param ... any
    @return ...any
]=]
function Net:InvokeServer(functionName: string, ...: any): ...any
    assert(not isServer, "Net:InvokeServer can only be called on the client")
    local func = self:GetFunction(functionName)
    return func:InvokeServer(...)
end

return Net
