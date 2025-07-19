local spawn = require("@self/spawn")
local RunService = game:GetService('RunService')

local grenade = spawn.tempentity {
	position = Vector3.new(0, 100, 0),
	size = Vector3.new(0.5, 1, 0.5),
	velocity = Vector3.new(50, 50, 50),
	angularVelocity = Vector3.new(math.random(1, 360), math.random(1, 360), math.random(1, 360))
}
local grenadePart = Instance.new("Part", workspace)
grenadePart.Anchored = true
grenadePart.Size = Vector3.new(0.5, 1, 0.5)
grenadePart.BrickColor = BrickColor.Red()


task.wait(1)

RunService.Heartbeat:Connect(function(dt)
	spawn.ecs.update(dt)
	grenadePart.CFrame = spawn.world:get(grenade, spawn.components.CFrame) :: CFrame
end)
