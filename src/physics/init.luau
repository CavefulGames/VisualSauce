local jecs = require("../roblox_packages/jecs")

type Entity<T = any> = jecs.Entity<T>
type World = jecs.World

type WorldProps = {
	gravity: number,
}

return function(world: World, worldProps: WorldProps?)
	local props = {
		--// Modifiable props
		Position = world:component(),
		Angle = world:component(),
		Velocity = world:component(),
		AngularVelocity = world:component(),
		CFrame = world:component(),

		Size = world:component(),
		Elasticity = world:component(),

		--// Read only props
		IsLastCollision = world:component(),
	}

	local flags = {
		--// Rendering Options
		Static = world:component(),
		Dynamic = world:component(),

		--// Simulation Options
		Gravity = world:component(),
		Collision = world:component(),

		--// Tempentity Simulation Options
		Rotate = world:component(),
	}

	local render = {
		Basic = world:component(),
		Grenade = world:component(),
		Tempentity = world:component(),
		Common = world:component(),
	}

	local basicQurey = {
		position = world:query(props.Position, props.Velocity):with(flags.Dynamic, render.Basic):without(flags.Static):cached(),
		angle = world:query(props.Angle, props.AngularVelocity):with(flags.Dynamic, render.Basic):without(flags.Static):cached(),
		cframe = world:query(props.Position, props.Angle):with(flags.Dynamic, render.Basic):without(flags.Static):cached(),
		gravity = world:query(props.Velocity):with(flags.Dynamic, flags.Gravity, render.Basic):without(flags.Static):cached(),
		collision = world:query(props.Position, props.Velocity, props.Size, props.Elasticity):with(flags.Dynamic, flags.Collision, render.Basic):without(flags.Static):cached(),
	}

	local grenadeQurey = {
		position = world:query(props.Position, props.Velocity):with(flags.Dynamic, render.Grenade):without(flags.Static):cached(),
		angle = world:query(props.Angle, props.AngularVelocity):with(flags.Dynamic, render.Grenade):without(flags.Static):cached(),
		cframe = world:query(props.Position, props.Angle):with(flags.Dynamic, render.Grenade):without(flags.Static):cached(),
		gravity = world:query(props.Velocity):with(flags.Dynamic, flags.Gravity, render.Grenade):without(flags.Static):cached(),
		collision = world:query(props.Position, props.Velocity, props.Size, props.Elasticity):with(flags.Dynamic, flags.Collision, render.Grenade):without(flags.Static):cached(),
	}
	
	local tempentityQurey = {
		position = world:query(props.Position, props.Velocity):with(flags.Dynamic, render.Tempentity):without(flags.Static):cached(),
		angle = world:query(props.Angle, props.AngularVelocity):with(flags.Dynamic, render.Tempentity):without(flags.Static):cached(),
		cframe = world:query(props.Position, props.Angle):with(flags.Dynamic, render.Tempentity):without(flags.Static):cached(),
		gravity = world:query(props.Velocity):with(flags.Dynamic, flags.Gravity, render.Tempentity):without(flags.Static):cached(),
		collision = world:query(props.Position, props.Velocity, props.Size, props.Elasticity):with(flags.Dynamic, flags.Collision, render.Tempentity):without(flags.Static):cached(),
	}

	local commonQurey = {
		position = world:query(props.Position, props.Velocity):with(flags.Dynamic, render.Common):without(flags.Static):cached(),
		angle = world:query(props.Angle, props.AngularVelocity):with(flags.Dynamic, render.Common):without(flags.Static):cached(),
		cframe = world:query(props.Position, props.Angle):with(flags.Dynamic, render.Common):without(flags.Static):cached(),
		gravity = world:query(props.Velocity):with(flags.Dynamic, flags.Gravity, render.Common):without(flags.Static):cached(),
		collision = world:query(props.Position, props.Velocity, props.Size, props.Elasticity):with(flags.Dynamic, flags.Collision, render.Common):without(flags.Static):cached(),
	}

	local worldProps: WorldProps = worldProps or { gravity = 169 }
	
	local engine = {}

	engine.worldProps = worldProps

	engine.components = {
		props = props,
		flags = flags,
		render = render,
	}

	function engine.default(id: number?)
		local entity = world:entity(id)

		world:set(entity, props.Position, Vector3.zero)
		world:set(entity, props.Angle, CFrame.new())

		world:set(entity, props.Velocity, Vector3.zero)
		world:set(entity, props.AngularVelocity, Vector3.zero)

		world:set(entity, props.CFrame, CFrame.new())

		world:set(entity, props.Size, Vector3.zero)
		world:set(entity, props.Elasticity, 0.3)
		
		return entity
	end

	function engine.basic(id: number?)
		local entity = engine.default(id)
		
		world:add(entity, flags.Dynamic)
		world:add(entity, flags.Collision)
		world:add(entity, flags.Gravity)
		world:add(entity, render.Basic)

		return entity
	end

	function engine.grenade(id: number?)
		local entity = engine.default(id)
		
		world:add(entity, flags.Dynamic)
		world:add(entity, flags.Collision)
		world:add(entity, flags.Gravity)
		world:add(entity, render.Grenade)
	
		return entity
	end

	function engine.tempentity(id: number?)
		local entity = engine.default(id)
		
		world:add(entity, flags.Dynamic)
		world:add(entity, flags.Collision)
		world:add(entity, flags.Rotate)
		world:add(entity, flags.Gravity)
		world:add(entity, render.Tempentity)
	
		return entity
	end

	function engine.common(id: number?)
		local entity = engine.default(id)
		
		world:add(entity, flags.Dynamic)
		world:add(entity, flags.Collision)
		world:add(entity, flags.Gravity)
		world:add(entity, render.Common)
	
		return entity
	end

	function engine.frame(deltaTime: number) 
		do
			for entity: Entity, velocity: Vector3 in basicQurey.gravity do
				world:set(entity, props.Velocity, velocity - (Vector3.yAxis * worldProps.gravity * deltaTime))
			end

			for entity: Entity, velocity: Vector3 in grenadeQurey.gravity do
				world:set(entity, props.Velocity, velocity - (Vector3.yAxis * worldProps.gravity * deltaTime))
			end

			for entity: Entity, velocity: Vector3 in tempentityQurey.gravity do
				world:set(entity, props.Velocity, velocity - (Vector3.yAxis * worldProps.gravity * deltaTime))
			end

			for entity: Entity, velocity: Vector3 in commonQurey.gravity do
				world:set(entity, props.Velocity, velocity - (Vector3.yAxis * worldProps.gravity * deltaTime))
			end
		end

		do
			for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3, elasticity: number in basicQurey.collision do
				--// Apply Entity Size
				local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

				--// Is not Colliding
				if not result then
					continue
				end

				--// Get Reflection Velocity
				local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * elasticity

				--// Apply Reflection Velocity
				world:set(entity, props.Velocity, dampingReflection)

				--// Is Stop Entity
				if dampingReflection:Dot(dampingReflection) < (30 * 30) / 15 then
					--// Apply Props
					world:set(entity, props.Velocity, Vector3.zero)

					--// Is Gravity Colliding
					if result.Normal.Y > 0.7 then
						--// Apply Stop Flags
						world:remove(entity, flags.Gravity)
						world:remove(entity, flags.Collision)
					end
				end
			end

			for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3, elasticity: number in grenadeQurey.collision do
				local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

				--// Is not Colliding
				if not result then
					continue
				end

				--// Get Reflection Velocity
				local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * elasticity

				--// Is Gravity Colliding
				if result.Normal.Y > 0.7 then
					--// Apply Damping Reflection Velocity
					world:set(entity, props.Velocity, dampingReflection)

					--// Is Stop
					if dampingReflection:Dot(dampingReflection) < (30 * 30) / 15 then
						--// Stop Entity
						world:set(entity, props.Velocity, Vector3.zero)

						--// Angular Velocity
						local angularVelocity = result.Normal

						--// Get Angular Velocity
						do
							local yaw: number, pitch: number

							if not (angularVelocity.X == 0 and angularVelocity.Z == 0) then
								yaw = 0
								pitch = angularVelocity.Y > 0 and 270 or 90
							else
								yaw = math.atan2(angularVelocity.Z, angularVelocity.X) * 180 / math.pi

								if yaw < 0 then
									yaw += 360
								end

								pitch = math.atan2(
									-angularVelocity.Y,
									(angularVelocity.X * angularVelocity.X + angularVelocity.Z * angularVelocity.Z) ^ 0.5
								) * 180 / math.pi

								if pitch < 0 then
									pitch += 360
								end
							end

							angularVelocity = Vector3.new(yaw, math.random(1, 360), pitch)
						end

						--// Apply Angular Velocity
						world:set(entity, props.AngularVelocity, angularVelocity)

						--// Apply Flags
						world:remove(entity, flags.Gravity)
						world:remove(entity, flags.Collision)
					end
				else
					--// Is Stop
					if dampingReflection:Dot(dampingReflection) < (30 * 30) / 15 then
						--// Apply Stop Velocity
						world:set(entity, props.Velocity, Vector3.zero)
						world:set(entity, props.AngularVelocity, Vector3.zero)
					else
						--// Apply Velocity
						world:set(entity, props.Velocity, dampingReflection)
					end
				end
			end

			for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3, elasticity: number in tempentityQurey.collision do
				local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

				if not result then
					continue
				end

				local hasGravity = world:has(entity, flags.Gravity)

				if hasGravity then
					--// Check Hits the floor
					if result.Normal.Y > 0.9 then
						--// If falling
						if velocity.Y <= 0 and velocity.Y >= -(worldProps.gravity * deltaTime) * 3 then
							--// Apply Flags
							world:remove(entity, flags.Collision)
							world:remove(entity, flags.Gravity)
							world:remove(entity, flags.Rotate)

							--// Apply Velocity
							world:set(entity, props.Velocity, Vector3.zero)
							world:set(entity, props.AngularVelocity, Vector3.zero)

							continue
						end
					end
				end

				--// Apply Reflection Velocity
				local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * elasticity
				
				world:set(entity, props.Velocity, dampingReflection)

				--// Apply CFrame and Velocity
				if hasGravity then
					world:set(entity, props.Velocity, dampingReflection * 0.5)
				end
			end

			for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3, elasticity: number in commonQurey.collision do
				local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

				--// Get is last colliding
				local isLastColliding = not world:has(entity, props.IsLastCollision)

				--// Add LastColliding flag
				if isLastColliding then
					world:add(entity, props.IsLastCollision)
				end

				--// Is not Colliding
				if not result then
					continue
				end

				--// Get Normal Velocity
				local normalVelocity = result.Normal:Dot(velocity) * result.Normal

				--// Get Tangential Velocity
				local tangentialVelocity = velocity - normalVelocity

				--// Get Friction Value
				local frictionValue = isLastColliding and 1 - 0.08 * deltaTime / tangentialVelocity.Magnitude
					or 1 - 0.08 * ((1 + elasticity) * normalVelocity.Magnitude) / tangentialVelocity.Magnitude

				--// Get Damping Reflection
				local dampingReflection = tangentialVelocity * math.max(frictionValue, 0) - elasticity * normalVelocity

				world:set(entity, props.Position, position + result.Normal * 0.01)

				--// Stopped
				if dampingReflection:Dot(dampingReflection) < (10 * 10) / 15 then
					--// Apply Stop Velocity
					world:set(entity, props.Velocity, Vector3.zero)
					world:set(entity, props.AngularVelocity, Vector3.zero)

					--// Apply flags
					world:remove(entity, flags.Gravity)
					world:remove(entity, flags.Collision)
				else
					--// Apply Velocity
					world:set(entity, props.Velocity, dampingReflection)
					world:set(entity, props.AngularVelocity, result.Normal:Cross(velocity) / elasticity)
				end
			end
		end

		do
			for entity: Entity, position: Vector3, velocity: Vector3 in basicQurey.position do
				world:set(entity, props.Position, position + velocity * deltaTime)
			end

			for entity: Entity, position: Vector3, velocity: Vector3 in grenadeQurey.position do
				world:set(entity, props.Position, position + velocity * deltaTime)
			end

			for entity: Entity, position: Vector3, velocity: Vector3 in tempentityQurey.position do
				world:set(entity, props.Position, position + velocity * deltaTime)
			end

			for entity: Entity, position: Vector3, velocity: Vector3 in commonQurey.position do
				world:set(entity, props.Position, position + velocity * deltaTime)
			end
		end

		do
			for entity: Entity, angle: CFrame, angularVelocity: Vector3 in basicQurey.angle do
				local angularVector = angularVelocity * deltaTime * math.pi / 180

				world:set(
					entity,
					props.Angle,
					angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z)
				)
			end

			for entity: Entity, angle: CFrame, angularVelocity: Vector3 in grenadeQurey.angle do
				local angularVector = angularVelocity * deltaTime * math.pi / 180

				world:set(
					entity,
					props.Angle,
					angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z)
				)
			end

			for entity: Entity, angle: CFrame, angularVelocity: Vector3 in tempentityQurey.angle do
				local angularVector = angularVelocity * deltaTime * math.pi / 180

				world:set(
					entity,
					props.Angle,
					angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z)
				)
			end

			for entity: Entity, angle: CFrame, angularVelocity: Vector3 in commonQurey.angle do
				local angularVector = angularVelocity * deltaTime * math.pi / 180

				world:set(
					entity,
					props.Angle,
					angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z)
				)
			end
		end

		do
			for entity: Entity, position: Vector3, angle: CFrame in basicQurey.cframe do
				world:set(entity, props.CFrame, CFrame.new(position) * angle)
			end

			for entity: Entity, position: Vector3, angle: CFrame in grenadeQurey.cframe do
				world:set(entity, props.CFrame, CFrame.new(position) * angle)
			end

			for entity: Entity, position: Vector3, angle: CFrame in tempentityQurey.cframe do
				world:set(entity, props.CFrame, CFrame.new(position) * angle)
			end

			for entity: Entity, position: Vector3, angle: CFrame in commonQurey.cframe do
				world:set(entity, props.CFrame, CFrame.new(position) * angle)
			end
		end
	end

	return engine
end
