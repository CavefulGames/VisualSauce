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

    --// Collision Props
    normal: Component<Vector3>,
    isColliding: Component<boolean>,    

    --// Physics Render Type
    Physics: Component<boolean>,
    Grenade: Component<boolean>,
    Tempentity: Component<boolean>,
}

--// Physics Flags
export type Flags = {
    Collidable: Component<boolean>,
    Gravity: Component<boolean>,
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

        normal = world:component(),
        isColliding = world:component(),

        Physics = world:component(),
        Grenade = world:component(),
        Tempentity = world:component(),
    }

    local flags: Flags = {
        Collidable = world:component(),
        Gravity = world:component(),
    }

    local worldProps: WorldProps = {
        Gravity = 169,
    }

    local physics = {}

    physics.components = components
    physics.flags = flags
    physics.worldProps = worldProps

    function physics.entity(id: number?): Entity
        local entity = world:entity(id)

        world:set(entity, components.Position, Vector3.zero)
        world:set(entity, components.Size, Vector3.zero)
        world:set(entity, components.Angle, CFrame.Angles(0, 0, 0))
        world:set(entity, components.Velocity, Vector3.zero)
        world:set(entity, components.AngularVelocity, Vector3.zero)

        world:add(entity, flags.Gravity)
        world:add(entity, flags.Collidable)

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
        for entity: Entity, position: Vector3, velocity: Vector3 in world:query(components.Position, components.Velocity, components.Physics) do
            --// Apply Props
            world:set(entity, components.Position, position + velocity * deltaTime)
            world:set(entity, components.Velocity, velocity)
        end

        --// Update Apply Gravity
        for entity: Entity, velocity: Vector3 in world:query(components.Velocity, flags.Gravity) do
            --// Apply Gravity
            world:set(entity, components.Velocity, velocity - Vector3.yAxis * worldProps.Gravity * deltaTime)
        end

        --// Update Angle
        for entity: Entity, angle: CFrame, angularVelocity: Vector3 in world:query(components.Angle, components.AngularVelocity, components.Physics) do
            --// Apply AngularVelocity
            local angularVector = angularVelocity * deltaTime * math.pi / 180

            --// Apply Props
            world:set(entity, components.Angle, angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z))
        end

        --// Update Collision
        for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3 in world:query(components.Position, components.Velocity, components.Size, flags.Collidable, components.Physics) do
            --// Apply Entity Size
            local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))
        
            --// Is not Colliding
            if not result then
                world:remove(entity, components.isColliding)
                continue
            end

            --// Apply Props
            world:set(entity, components.normal, result.Normal)
            world:add(entity, components.isColliding)
        end

        --// Update Physics
        for entity: Entity, velocity: Vector3, normal: Vector3 in world:query(components.Velocity, components.normal, components.isColliding, components.Physics) do
            --// Get Reflection Velocity
            local dampingReflection = (velocity - 2 * (velocity:Dot(normal)) * normal) * 0.3

            --// Apply Reflection Velocity
            world:set(entity, components.Velocity, dampingReflection)

            --// Is Stop Entity
            if dampingReflection:Dot(dampingReflection) < (30 * 30) then
                --// Apply Props
                world:set(entity, components.Velocity, Vector3.zero)
                
                --// Is Gravity Colliding
                if normal.Y > 0.7 then
                    --// Apply Stop Flags
                    world:remove(entity, flags.Gravity)
                end
            end
        end

        --// Update Temp Entity

    end

    return physics
end
