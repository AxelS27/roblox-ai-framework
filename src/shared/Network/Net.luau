--!strict
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
