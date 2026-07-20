--!strict
--[=[
    @class SharedTypes
    @shared
    Centralized Luau type definitions for structures shared between server and client.
]=]

export type ItemData = {
    Id: string,
    Name: string,
    Rarity: "Common" | "Rare" | "Epic" | "Legendary",
    Quantity: number,
}

export type PlayerDataSchema = {
    Coins: number,
    Gems: number,
    Level: number,
    XP: number,
    Inventory: { ItemData },
}

return nil
