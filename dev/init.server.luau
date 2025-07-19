local spawn = require("@self/spawn")
local RunService = game:GetService('RunService')

local physics = spawn.physics {
	size = Vector3.one * 2,
	velocity = Vector3.new(100, 100, 100),
}
local physicsPart = Instance.new("Part", workspace)
physicsPart.Anchored = true
physicsPart.Size = Vector3.one * 2
physicsPart.BrickColor = BrickColor.Red()

local grenade = spawn.grenade {
	size = Vector3.one * 2,
	velocity = Vector3.new(100, 100, 100),
	position = Vector3.new(0, 0, 4),
}
local grenadePart = Instance.new("Part", workspace)
grenadePart.Anchored = true
grenadePart.Size = Vector3.one * 2
grenadePart.BrickColor = BrickColor.Yellow()

local tempentity = spawn.tempentity {
	size = Vector3.one * 2,
	velocity = Vector3.new(100, 100, 100),
	position = Vector3.new(0, 0, 8),
}
local tempentityPart = Instance.new("Part", workspace)
tempentityPart.Anchored = true
tempentityPart.Size = Vector3.one * 2
tempentityPart.BrickColor = BrickColor.Green()

local normal = spawn.normal {
	size = Vector3.one * 2,
	velocity = Vector3.new(100, 100, 100),
	position = Vector3.new(0, 0, 12),
}
local normalPart = Instance.new("Part", workspace)
normalPart.Anchored = true
normalPart.Size = Vector3.one * 2
normalPart.BrickColor = BrickColor.Blue()

task.wait(1)

RunService.Heartbeat:Connect(function(dt)
	spawn.ecs.update(dt)
	physicsPart.CFrame = spawn.world:get(physics, spawn.components.CFrame) :: CFrame
	grenadePart.CFrame = spawn.world:get(grenade, spawn.components.CFrame) :: CFrame
	tempentityPart.CFrame = spawn.world:get(tempentity, spawn.components.CFrame) :: CFrame
	normalPart.CFrame = spawn.world:get(normal, spawn.components.CFrame) :: CFrame
end)
