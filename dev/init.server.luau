local spawn = require("@self/spawn")
local entity = spawn.normal {
	size = Vector3.one * 2,
	velocity = Vector3.new(100, 100, 100)
}

local RunService = game:GetService('RunService')

local part = Instance.new("Part", workspace)
part.Anchored = true
part.Size = Vector3.one * 2

task.wait(1)

RunService.Heartbeat:Connect(function(dt)
	spawn.ecs.update(dt)
	part.CFrame = spawn.world:get(entity, spawn.components.CFrame) :: CFrame
end)
