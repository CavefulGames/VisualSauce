local packages = script:WaitForChild("Packages")

local visualSauce = require(packages:WaitForChild('VisualSauce'))()
local physicsEcs = visualSauce.physics

local entity = physicsEcs.entity()

visualSauce.world:set(entity, physicsEcs.components.Velocity, Vector3.new(0, 100, 0))
visualSauce.world:set(entity, physicsEcs.components.Size, Vector3.one * 2)

local RunService = game:GetService('RunService')

local part = Instance.new("Part", workspace)
part.Anchored = true
part.Size = Vector3.one * 2

task.wait(1)

RunService.Heartbeat:Connect(function(dt)
    physicsEcs.update(dt)
    part.Position = visualSauce.world:get(entity, physicsEcs.components.Position) :: Vector3
end)
