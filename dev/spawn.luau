local visualSauce = require("../src")()
local world = visualSauce.world
local ecs = visualSauce.physics
local components = ecs.components

local module = {}
module.world = world
module.ecs = ecs
module.components = components

function module.physics(info: {
    position: Vector3?,
	angle: CFrame?,
	size: Vector3?,

	velocity: Vector3?,
	angularVelocity: Vector3?,
})
    local entity = ecs.physics()

    world:set(entity, components.Position, info.position or Vector3.zero)
    world:set(entity, components.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, components.Size, info.size or Vector3.zero)
    
    world:set(entity, components.Velocity, info.velocity or Vector3.zero)
    world:set(entity, components.AngularVelocity, info.angularVelocity or Vector3.zero)

    return entity
end

function module.tempentity(info: {
    position: Vector3?,
	angle: CFrame?,
	size: Vector3?,

	velocity: Vector3?,
	angularVelocity: Vector3?,
})
    local entity = ecs.tempentity()

    world:set(entity, components.Position, info.position or Vector3.zero)
    world:set(entity, components.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, components.Size, info.size or Vector3.zero)
    
    world:set(entity, components.Velocity, info.velocity or Vector3.zero)
    world:set(entity, components.AngularVelocity, info.angularVelocity or Vector3.zero)

    return entity
end

function module.grenade(info: {
    position: Vector3?,
	angle: CFrame?,
	size: Vector3?,

	velocity: Vector3?,
	angularVelocity: Vector3?,
})
    local entity = ecs.grenade()

    world:set(entity, components.Position, info.position or Vector3.zero)
    world:set(entity, components.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, components.Size, info.size or Vector3.zero)
    
    world:set(entity, components.Velocity, info.velocity or Vector3.zero)
    world:set(entity, components.AngularVelocity, info.angularVelocity or Vector3.zero)

    return entity
end

function module.normal(info: {
    position: Vector3?,
	angle: CFrame?,
	size: Vector3?,

	velocity: Vector3?,
	angularVelocity: Vector3?,
})
    local entity = ecs.normal()
    local size = info.size or Vector3.zero

    world:set(entity, components.Position, info.position or Vector3.zero)
    world:set(entity, components.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, components.Size, size or Vector3.zero)
    
    world:set(entity, components.Velocity, info.velocity or Vector3.zero)
    world:set(entity, components.AngularVelocity, info.angularVelocity or Vector3.zero)

    return entity
end

return module
