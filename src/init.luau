local jecs = require("./roblox_packages/jecs")
local physics = require("@self/physics")

type World = jecs.World

return function(world: World?)
	local world = world or jecs.world()
	return {
		world = world,
		physics = physics(world),
	}
end
