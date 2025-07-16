local jecs = require("../roblox_packages/jecs")

type Component<T> = jecs.Entity<T>
type Entity = jecs.Entity
type World = jecs.World

export type Componenets = {
    --// Entity Props
    Position: Component<Vector3>,
    Size: Component<Vector3>,
    Velocity: Component<Vector3>,
    AngularVelocity: Component<Vector3>,

    --// Physics Flags
    Collidable: Component<boolean>,
    Gravity: Component<boolean>,
    CollisionReflection: Component<boolean>,

    --// Physics Render Type
    Physics: Component<boolean>,
    Grenade: Component<boolean>,
    Tempentity: Component<boolean>,

    --// World Props
    GravityAcceleration: Component<number>,
}

return function(world: World)
    local components: Componenets = {
        Position = world:component(),
        Size = world:component(),
        Velocity = world:component(),
        AngularVelocity = world:component(),

        Collidable = world:component(),
        Gravity = world:component(),
        CollisionReflection = world:component(),

        Physics = world:component(),
        Grenade = world:component(),
        Tempentity = world:component(),

        GravityAcceleration = world:component(),
    }

    local physics = {}

    function physics.entity(id: number?): Entity
        local entity = world:entity(id)

        world:set(entity, components.Position, Vector3.zero)
        world:set(entity, components.Size, Vector3.zero)
        world:set(entity, components.Velocity, Vector3.zero)
        world:set(entity, components.AngularVelocity, Vector3.zero)

        world:add(entity, components.Gravity)
        world:add(entity, components.Collidable)
        world:add(entity, components.CollisionReflection)

        world:add(entity, components.Physics)

        if not world:has(entity, components.GravityAcceleration) then
            world:set(entity, components.GravityAcceleration, 169)
        end

        return entity
    end
    
    function physics.grenade(id: number?): Entity
        local entity = physics.entity(id)

        world:remove(entity, components.Physics)
        world:add(entity, components.Grenade)

        return entity
    end
    
    function physics.tempentity(id: number?): Entity
        local entity = physics.entity(id)

        world:remove(entity, components.Physics)
        world:add(entity, components.Tempentity)

        return entity
    end

    function physics.getPhysicsRenderType(entity: Entity): "Physics" | "Grenade" | "Tempentity"
        local is_physics = world:has(entity, components.Physics)
        local is_grenade = world:has(entity, components.Grenade)
        local is_tempentity = world:has(entity, components.Tempentity)
    
        if is_physics then
            if is_grenade or is_tempentity then
                return error("Invalid Physics Render Type: Only one of [Physics, Grenade, Tempentity is allowed.")
            end

            return "Physics"
        end

        if is_grenade then
            if is_physics or is_tempentity then
                return error("Invalid Physics Render Type: Only one of [Physics, Grenade, Tempentity is allowed.")
            end

            return "Grenade"
        end
        
        if is_tempentity then
            if is_physics or is_grenade then
                return error("Invalid Physics Render Type: Only one of [Physics, Grenade, Tempentity is allowed.")
            end

            return "Tempentity"
        end

        return error("Physics render type is required. Exactly one must be specified.")
    end

    function physics.frame(entity: Entity)
        local physicsRenderType = physics.getPhysicsRenderType(entity)

        
    end

    return physics
end
