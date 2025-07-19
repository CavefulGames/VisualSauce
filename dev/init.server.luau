local packages = script:WaitForChild("Packages")

local visualSauce = require(packages:WaitForChild('VisualSauce'))()
local physicsEcs = visualSauce.physics

local entity = physicsEcs.normal()

visualSauce.world:set(entity, physicsEcs.components.Velocity, Vector3.new(100, 100, 100))
visualSauce.world:set(entity, physicsEcs.components.Size, Vector3.one * 2)
visualSauce.world:set(entity, physicsEcs.components.Inertia, (Vector3.one * 2):Dot((Vector3.one * 2)) / 12)
visualSauce.world:add(entity, physicsEcs.flags.Rotate)

local RunService = game:GetService('RunService')

local part = Instance.new("Part", workspace)
part.Anchored = true
part.Size = Vector3.one * 2

task.wait(1)

RunService.Heartbeat:Connect(function(dt)
	physicsEcs.update(dt)
	part.CFrame = visualSauce.world:get(entity, physicsEcs.components.CFrame) :: CFrame
end)
