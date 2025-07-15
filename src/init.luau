--[=[
@api
local physicsEcs = visualSauce.physicsEcs(world)
physicsEcs.components;
physicsEcs.entities;
physicsEcs.systems;

physics
- init.luau (update 함수로 시스템 가동, export etc)
- components.luau (velocity, rotVelocity 그런거 컴포넌트들 만들기)
- system.luau (물리 시스템)
- presets.luau (아니면 helpers.luau? 수류탄/tempentity 조합 그런거)
]=]

local jecs = require("./roblox_packages/jecs")

type World = jecs.World

return function(world: World?)
    local world = world or jecs.world()
    return {
        physics = require("@self/physics")(world),
    }
end
