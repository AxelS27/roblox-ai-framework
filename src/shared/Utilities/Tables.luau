--!strict
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
