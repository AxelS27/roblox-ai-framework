--!strict
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
