# Luau OOP Coding Pattern

This pattern defines how to structure Object-Oriented Programming (OOP) classes in Luau. Always use composition over inheritance and integrate the Sleitnick `Maid` package for lifecycle tracking.

## OOP Structure Guidelines

1. **Metatable binding**: Set `Class.__index = Class` to enable inheritance of class methods.
2. **Type Safety**: Define public fields using `export type ClassImpl` and a private type helper `type Self = typeof(setmetatable({} :: ClassImpl, Class))`.
3. **Lifecycle tracking**: Declare a private Sleitnick `_maid` instance in the constructor to track connection and asset cleanup.
4. **Destroy method**: Always implement `:Destroy()` to invoke `self._maid:Destroy()`.

---

## Pattern Example

```lua
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Packages = Shared:WaitForChild("Packages")
local Maid = require(Packages:WaitForChild("Maid"))

local Item = {}
Item.__index = Item

-- 1. Public Type Definition
export type ItemImpl = {
    _maid: typeof(Maid.new()),
    Name: string,
    Quantity: number,
}

type Self = typeof(setmetatable({} :: ItemImpl, Item))

-- 2. Constructor
function Item.new(name: string, initialQuantity: number): Self
    local self = setmetatable({
        _maid = Maid.new(),
        Name = name,
        Quantity = initialQuantity,
    }, Item)

    -- Track elements for cleanup
    -- self._maid:GiveTask(...)

    return self
end

-- 3. Methods
function Item:AddQuantity(amount: number)
    self.Quantity = math.max(0, self.Quantity + amount)
end

-- 4. Destructor
function Item:Destroy()
    self._maid:Destroy()
end

return Item
```
