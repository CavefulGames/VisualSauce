local types = require("../types")

type World = types.World
type Component<T> = types.Component<T>

export type Componenets = {
    position: Component<Vector3>,
    size: Component<Vector3>,
    velocity: Component<Vector3>,
    angularVelocity: Component<Vector3>,

    fCollideWorld: Component<boolean>,
    fGravity: Component<boolean>,
}

return function(world: World): Componenets
    return {
        position = world:component(),
        size = world:component(),
        velocity = world:component(),
        angularVelocity = world:component(),

        fCollideWorld = world:component(),
        fGravity = world:component(),
    }
end