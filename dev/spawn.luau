local visualSauce = require("../src")()
local world = visualSauce.world
local ecs = visualSauce.physics
local components = ecs.components
local props = components.props
local flags = components.flags

local module = {}
module.world = world
module.ecs = ecs
module.components = components
module.props = props
module.flags = flags

function module.physics(info: {
    position: Vector3?,
	angle: CFrame?,
	size: Vector3?,

	velocity: Vector3?,
	angularVelocity: Vector3?,
})
    local entity = ecs.basic()

    world:set(entity, props.Position, info.position or Vector3.zero)
    world:set(entity, props.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, props.Size, info.size or Vector3.zero)
    
    world:set(entity, props.Velocity, info.velocity or Vector3.zero)
    world:set(entity, props.AngularVelocity, info.angularVelocity or Vector3.zero)

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

    world:set(entity, props.Position, info.position or Vector3.zero)
    world:set(entity, props.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, props.Size, info.size or Vector3.zero)
    
    world:set(entity, props.Velocity, info.velocity or Vector3.zero)
    world:set(entity, props.AngularVelocity, info.angularVelocity or Vector3.zero)

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

    world:set(entity, props.Position, info.position or Vector3.zero)
    world:set(entity, props.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, props.Size, info.size or Vector3.zero)
    
    world:set(entity, props.Velocity, info.velocity or Vector3.zero)
    world:set(entity, props.AngularVelocity, info.angularVelocity or Vector3.zero)

    return entity
end

function module.normal(info: {
    position: Vector3?,
	angle: CFrame?,
	size: Vector3?,

	velocity: Vector3?,
	angularVelocity: Vector3?,
})
    local entity = ecs.common()
    local size = info.size or Vector3.zero

    world:set(entity, props.Position, info.position or Vector3.zero)
    world:set(entity, props.Angle, info.angle or CFrame.Angles(0, 0, 0))
    world:set(entity, props.Size, size or Vector3.zero)
    
    world:set(entity, props.Velocity, info.velocity or Vector3.zero)
    world:set(entity, props.AngularVelocity, info.angularVelocity or Vector3.zero)

    return entity
end

return module
