local jecs = require("../roblox_packages/jecs")

type World = jecs.World
type Component<T> = jecs.Entity<T>

export type Componenets = {
    Position: Component<Vector3>,
    Size: Component<Vector3>,
    Velocity: Component<Vector3>,
    AngularVelocity: Component<Vector3>,

    Collidable: Component<boolean>,
    Gravity: Component<boolean>,
}

return function(world: World)
    local components: Componenets = {
        Position = world:component(),
        Size = world:component(),
        Velocity = world:component(),
        AngularVelocity = world:component(),

        Collidable = world:component(),
        Gravity = world:component(),
    }

    local physics = {}


    return physics
end
