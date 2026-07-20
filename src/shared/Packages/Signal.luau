--!strict
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
