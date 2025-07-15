local types = require("./types")
local components = require("@self/components")
local systems = require("@self/systems")
local entity = require("@self/entitys")

type World = types.World
type Component<T> = types.Component<T>

return function(world: World)
    return {
        entity = entity(world),
        components = components(world),
        systems = systems(world),
    }
end
