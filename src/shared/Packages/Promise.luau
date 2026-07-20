--!strict
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
