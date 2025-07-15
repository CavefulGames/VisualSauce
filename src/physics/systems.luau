local types = require("../types")

type World = types.World

return function(world: World)
    local components = require("./components")(world)

    local systems = {}

    

    return systems
end