--!strict
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
