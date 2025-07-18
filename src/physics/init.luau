local jecs = require("../roblox_packages/jecs")

type Component<T> = jecs.Id<T>
type Entity<T = any> = jecs.Entity<T>
type World = jecs.World

--// Entity Props
export type Components = {
	--// Transform Props
	Position: Component<Vector3>,
	Size: Component<Vector3>,
	Angle: Component<CFrame>,
	cframe: Component<CFrame>,

	--// Velocity Props
	Velocity: Component<Vector3>,
	AngularVelocity: Component<Vector3>,

	--// Collision Props
	normal: Component<Vector3>,
	isColliding: Component<boolean>,
}

--// Physics Render Type
export type PhysicsRenderType = {
	Physics: Component<boolean>,
	Grenade: Component<boolean>,
	Tempentity: Component<boolean>,
}

--// Physics Flags
export type Flags = {
	--// Global Props
	Collidable: Component<boolean>,
	Gravity: Component<boolean>,

	--// TempEntity Props
	Rotate: Component<boolean>,
}

export type WorldProps = {
	--// World Props
	Gravity: number,
}

return function(world: World)
	local components: Components = {
		Position = world:component(),
		Size = world:component(),
		Angle = world:component(),
		Velocity = world:component(),
		AngularVelocity = world:component(),
		cframe = world:component(),

		normal = world:component(),
		isColliding = world:component(),

		Physics = world:component(),
		Grenade = world:component(),
		Tempentity = world:component(),
	}

	local flags: Flags = {
		Collidable = world:component(),
		Gravity = world:component(),

		Rotate = world:component(),
	}

	local physicsRenderType: PhysicsRenderType = {
		Physics = world:component(),
		Grenade = world:component(),
		Tempentity = world:component(),
	}

	local worldProps: WorldProps = {
		Gravity = 169,
	}

	local physics = {}

	physics.components = components
	physics.flags = flags
	physics.worldProps = worldProps

	function physics.entity(id: number?): Entity
		local entity = world:entity(id)

		world:set(entity, components.Position, Vector3.zero)
		world:set(entity, components.Size, Vector3.zero)
		world:set(entity, components.Angle, CFrame.Angles(0, 0, 0))
		world:set(entity, components.Velocity, Vector3.zero)
		world:set(entity, components.AngularVelocity, Vector3.zero)
		world:set(entity, components.cframe, CFrame.new())

		world:add(entity, flags.Gravity)
		world:add(entity, flags.Collidable)

		world:add(entity, physicsRenderType.Physics)

		return entity
	end

	function physics.grenade(id: number?): Entity
		local entity = physics.entity(id)

		world:remove(entity, physicsRenderType.Physics)
		world:add(entity, physicsRenderType.Grenade)

		return entity
	end

	function physics.tempentity(id: number?): Entity
		local entity = physics.entity(id)

		world:remove(entity, physicsRenderType.Physics)
		world:add(entity, physicsRenderType.Tempentity)

		return entity
	end

	function physics.update(deltaTime: number)
		--// Update Physics Position
		for entity: Entity, position: Vector3, velocity: Vector3 in
			world:query(components.Position, components.Velocity, physicsRenderType.Physics)
		do
			--// Apply Props
			world:set(entity, components.Position, position + velocity * deltaTime)
			world:set(entity, components.Velocity, velocity)
		end

		--// Update Physics Gravity
		for entity: Entity, velocity: Vector3 in
			world:query(components.Velocity, flags.Gravity, physicsRenderType.Physics)
		do
			--// Apply Gravity
			world:set(entity, components.Velocity, velocity - (Vector3.yAxis * worldProps.Gravity * deltaTime))
		end

		--// Update Physics Angle
		for entity: Entity, angle: CFrame, angularVelocity: Vector3 in
			world:query(components.Angle, components.AngularVelocity, physicsRenderType.Physics)
		do
			--// Apply AngularVelocity
			local angularVector = angularVelocity * deltaTime * math.pi / 180

			--// Apply Props
			world:set(
				entity,
				components.Angle,
				angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z)
			)
		end

		--// Update Physics Collision
		for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3 in
			world:query(
				components.Position,
				components.Velocity,
				components.Size,
				flags.Collidable,
				physicsRenderType.Physics
			)
		do
			--// Apply Entity Size
			local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

			--// Is not Colliding
			if not result then
				world:remove(entity, components.isColliding)
				continue
			end

			--// Apply Props
			world:set(entity, components.normal, result.Normal)
			world:add(entity, components.isColliding)

			--// Get Reflection Velocity
			local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * 0.3

			--// Apply Reflection Velocity
			world:set(entity, components.Velocity, dampingReflection)

			--// Is Stop Entity
			if dampingReflection:Dot(dampingReflection) < (30 * 30) then
				--// Apply Props
				world:set(entity, components.Velocity, Vector3.zero)

				--// Is Gravity Colliding
				if result.Normal.Y > 0.7 then
					--// Apply Stop Flags
					world:remove(entity, flags.Gravity)
				end
			end
		end

		--// Update Physics CFrame
		for entity: Entity, position: Vector3, angle: CFrame in
			world:query(components.Position, components.Angle, physicsRenderType.Physics)
		do
			--// Apply CFrame
			world:set(entity, components.cframe, CFrame.new(position) * angle)
		end

		--// Update TempEntity Rotate
		for entity: Entity, velocity: Vector3 in
			world:query(components.Velocity, flags.Rotate, physicsRenderType.Tempentity)
		do
			--// Apply AngularVelocity
			world:set(entity, components.AngularVelocity, velocity * deltaTime)
		end

		--// Update TempEntity Position
		for entity: Entity, velocity: Vector3, angularVelocity: Vector3, angle: CFrame, cframe: CFrame in
			world:query(
				components.Velocity,
				components.AngularVelocity,
				components.Angle,
				components.cframe,
				physicsRenderType.Tempentity
			)
		do
			--// Apply CFrame
			world:set(
				entity,
				components.cframe,
				(CFrame.new(cframe.Position + (velocity * deltaTime)) * CFrame.Angles(cframe:ToEulerAnglesXYZ()))
					* CFrame.Angles(
						math.rad(angularVelocity.X),
						math.rad(angularVelocity.Y),
						math.rad(angularVelocity.Z)
					)
			)

			--// Apply Angle
			world:set(
				entity,
				components.Angle,
				(CFrame.Angles(cframe:ToEulerAnglesXYZ()))
					* CFrame.Angles(
						math.rad(angularVelocity.X),
						math.rad(angularVelocity.Y),
						math.rad(angularVelocity.Z)
					)
			)
		end

		--// Update TempEntity Collision
		for entity: Entity, cframe: CFrame, velocity: Vector3, size: Vector3 in
			world:query(
				components.cframe,
				components.Velocity,
				components.Size,
				flags.Collidable,
				physicsRenderType.Tempentity
			)
		do
			--// Entity Flags Has Gravity
			local hasGravity = world:has(entity, flags.Gravity)

			--// Apply Entity Size
			local result = workspace:Raycast(cframe.Position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

			--// Is not Colliding
			if not result then
				--// Apply Gravity
				if hasGravity then
					--// Apply Gravity Velocity
					world:set(entity, components.Velocity, velocity - (Vector3.yAxis * worldProps.Gravity * deltaTime))
				end

				--// Apply Colliding Prop
				world:remove(entity, components.isColliding)
				continue
			end

			--// Apply Collision Props
			world:add(entity, components.isColliding)
			world:set(entity, components.normal, result.Normal)

			--// If has Gravity then, apply Velocity
			if hasGravity then
				--// Check Hits the floor
				if result.Normal.Y > 0.9 then
					--// If falling
					if velocity.Y <= 0 and velocity.Y >= -(worldProps.Gravity * deltaTime) * 3 then
						--// Apply Flags
						world:remove(entity, flags.Collidable)
						world:remove(entity, flags.Gravity)
						world:remove(entity, flags.Rotate)

						--// Apply CFrame
						local _, y, _ = cframe:ToEulerAnglesYXZ()
						world:set(entity, components.cframe, CFrame.new(cframe.Position) * CFrame.Angles(0, y, 0))

						--// Apply Velocity
						world:set(entity, components.Velocity, Vector3.zero)

						--// Apply CFrame
						local x, y, z = cframe:ToEulerAnglesXYZ()
						world:set(
							entity,
							components.cframe,
							CFrame.new(cframe.Position) * CFrame.Angles(x * 0.9, y * 0.9, z * 0.9)
						)

						continue
					end
				end
			end

			--// Apply Reflection Velocity
			world:set(entity, components.Velocity, velocity - (2 * velocity:Dot(result.Normal) * result.Normal))

			--// Apply Angle CFrame
			local x, y, z = cframe:ToEulerAnglesXYZ()
			world:set(entity, components.cframe, CFrame.new(cframe.Position) * CFrame.Angles(x, -y, z))

			--// Apply CFrame and Velocity
			if hasGravity then
				--// Apply Velocity
				world:set(entity, components.Velocity, velocity * 0.5)

				--// Apply CFrame
				local x, y, z = cframe:ToEulerAnglesXYZ()
				world:set(
					entity,
					components.cframe,
					CFrame.new(cframe.Position) * CFrame.Angles(x * 0.9, y * 0.9, z * 0.9)
				)
			end
		end

		--// Update Grenade Position
		for entity: Entity, position: Vector3, velocity: Vector3 in
			world:query(components.Position, components.Velocity, physicsRenderType.Grenade)
		do
			--// Apply Props
			world:set(entity, components.Position, position + velocity * deltaTime)
			world:set(entity, components.Velocity, velocity)
		end

		--// Update Grenade Gravity
		for entity: Entity, velocity: Vector3 in
			world:query(components.Velocity, flags.Gravity, physicsRenderType.Grenade)
		do
			--// Apply Gravity
			world:set(entity, components.Velocity, velocity - (Vector3.yAxis * worldProps.Gravity * deltaTime))
		end

		--// Update Grenade Angle
		for entity: Entity, angle: CFrame, angularVelocity: Vector3 in
			world:query(components.Angle, components.AngularVelocity, physicsRenderType.Grenade)
		do
			--// Apply AngularVelocity
			local angularVector = angularVelocity * deltaTime * math.pi / 180

			--// Apply Props
			world:set(
				entity,
				components.Angle,
				angle * CFrame.Angles(angularVector.X, angularVector.Y, angularVector.Z)
			)
		end

		--// Update Grenade Collision
		for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3 in
			world:query(
				components.Position,
				components.Velocity,
				components.Size,
				flags.Collidable,
				physicsRenderType.Grenade
			)
		do
			--// Apply Entity Size
			local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

			--// Is not Colliding
			if not result then
				world:remove(entity, components.isColliding)
				continue
			end

			--// Apply Props
			world:set(entity, components.normal, result.Normal)
			world:add(entity, components.isColliding)

			--// Get Reflection Velocity
			local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * 0.3

			--// Is Gravity Colliding
			if result.Normal.Y > 0.7 then
				--// Apply Damping Reflection Velocity
				world:set(entity, components.Velocity, dampingReflection)

				--// Is Stop
				if dampingReflection:Dot(dampingReflection) < (30 * 30) then
					--// Stop Entity
					world:set(entity, components.Velocity, Vector3.zero)

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
					world:set(entity, components.AngularVelocity, angularVelocity)

					--// Apply Flags
					world:remove(entity, flags.Gravity)
					world:remove(entity, flags.Collidable)
				end
			else
				--// Is Stop
				if dampingReflection:Dot(dampingReflection) < (30 * 30) then
					--// Apply Stop Velocity
					world:set(entity, components.Velocity, Vector3.zero)
					world:set(entity, components.AngularVelocity, Vector3.zero)
				else
					--// Apply Velocity
					world:set(entity, components.Velocity, dampingReflection)
				end
			end
		end

		--// Update Grenade CFrame
		for entity: Entity, position: Vector3, angle: CFrame in
			world:query(components.Position, components.Angle, physicsRenderType.Grenade)
		do
			--// Apply CFrame
			world:set(entity, components.cframe, CFrame.new(position) * angle)
		end
	end

	return physics
end
