local types = require("../types")

type World = types.World

return function(world: World)
    local components = require("./components")(world)

    return function(id: number?)        
        local entity = world:entity(id)
    
        world:set(entity, components.position, Vector3.zero)
        world:set(entity, components.size, Vector3.zero)
        world:set(entity, components.velocity, Vector3.zero)
        world:set(entity, components.angularVelocity, Vector3.zero)
    
        world:set(entity, components.fCollideWorld, true)
        world:set(entity, components.fGravity, true)
    
        return entity
    end
end