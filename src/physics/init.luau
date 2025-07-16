local jecs = require("../roblox_packages/jecs")

type Component<T> = jecs.Id<T>
type Entity<T=any> = jecs.Entity<T>
type World = jecs.World

export type Components = {
    --// Entity Props
    Position: Component<Vector3>,
    Size: Component<Vector3>,
    Angle: Component<CFrame>,
    Velocity: Component<Vector3>,
    AngularVelocity: Component<Vector3>,

    --// Physics Flags
    FlagCollidable: Component<boolean>,
    FlagGravity: Component<boolean>,

    --// Physics Render Type
    Physics: Component<boolean>,
    Grenade: Component<boolean>,
    Tempentity: Component<boolean>,
}

export type WorldProps = {
    --// World Props
    Gravity: number,
}

return function(world: World)
    local components: Components = {
        Position = world:component(),
        Size = world:component(),
        Angle = world:component(),
        Velocity = world:component(),
        AngularVelocity = world:component(),

        FlagCollidable = world:component(),
        FlagGravity = world:component(),

        Physics = world:component(),
        Grenade = world:component(),
        Tempentity = world:component(),
    }

    local worldProps: WorldProps = {
        Gravity = 9.8,  
    }

    local physics = {}

    function physics.entity(id: number?): Entity
        local entity = world:entity(id)

        world:set(entity, components.Position, Vector3.zero)
        world:set(entity, components.Size, Vector3.zero)
        world:set(entity, components.Angle, CFrame.Angles(0, 0, 0))
        world:set(entity, components.Velocity, Vector3.zero)
        world:set(entity, components.AngularVelocity, Vector3.zero)

        world:add(entity, components.FlagGravity)
        world:add(entity, components.FlagCollidable)

        world:add(entity, components.Physics)

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

    function physics.update(deltaTime: number)
        --// Update Position
        for entity: Entity, position: Vector3, velocity: Vector3 in world:query(components.Position, components.Velocity) do
            if world:has(entity, components.FlagGravity) then
                --// Apply Gravity
                local gravity = worldProps.Gravity

                velocity = velocity - Vector3.yAxis * gravity * deltaTime
            end

            --// Apply Props
            world:set(entity, components.Position, position + velocity * deltaTime)
            world:set(entity, components.Velocity, velocity)
        end

        --// Update Angle
        for entity: Entity, angle: CFrame, angularVelocity: Vector3 in world:query(components.Angle, components.AngularVelocity) do
            --// Apply AngularVelocity
            local angularVector = angularVelocity * deltaTime * math.pi / 180

            --// Apply Props
            world:set(entity, components.Angle, angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z))
        end
    end

    return physics
end
