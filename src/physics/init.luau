local jecs = require("../roblox_packages/jecs")

type Component<T = any> = jecs.Id<T>
type Entity<T = any> = jecs.Entity<T>
type World = jecs.World

--// Entity Props
export type Components = {
	--// Transform Props
	Position: Component<Vector3>,
	Angle: Component<CFrame>,
	CFrame: Component<CFrame>,

	--// Physical Properties
	Elasticity: Component<number>,
	Size: Component<Vector3>,

	--// Velocity Props
	Velocity: Component<Vector3>,
	AngularVelocity: Component<Vector3>,

	--// Collision Props
	Normal: Component<Vector3>,
	IsColliding: Component<boolean>,
}

--// Physics Render Type
export type PhysicsRenderType = {
	Physics: Component,
	Grenade: Component,
	Tempentity: Component,
	Normal: Component,
}

--// Physics Flags
export type Flags = {
	--// Global Props
	Collidable: Component,
	Gravity: Component,

	--// TempEntity Props
	Rotate: Component,

    --// Normal Props
	LastColliding: Component,
}

export type WorldProps = {
    --// World Props
	Gravity: number,
}

return function(world: World)
	local components: Components = {
		Position = world:component(),
		Angle = world:component(),
		Velocity = world:component(),
		AngularVelocity = world:component(),
		CFrame = world:component(),

		Size = world:component(),
		Elasticity = world:component(),

		Normal = world:component(),
		IsColliding = world:component(),
	}

	local flags: Flags = {
		Collidable = world:component(),
		Gravity = world:component(),
		Rotate = world:component(),
        LastColliding = world:component(),
	}

	local physicsRenderType: PhysicsRenderType = {
		Physics = world:component(),
		Grenade = world:component(),
		Tempentity = world:component(),
		Normal = world:component(),
	}

	local worldProps: WorldProps = {
		Gravity = 169,
	}

	local physics = {}

	physics.components = components
	physics.flags = flags
	physics.worldProps = worldProps

	function physics.physics(id: number?): Entity
		local entity = world:entity(id)

		world:set(entity, components.Position, Vector3.zero)
		world:set(entity, components.Size, Vector3.zero)
		world:set(entity, components.Angle, CFrame.Angles(0, 0, 0))
		world:set(entity, components.Velocity, Vector3.zero)
		world:set(entity, components.AngularVelocity, Vector3.zero)
		world:set(entity, components.CFrame, CFrame.new())
		world:set(entity, components.Elasticity, 0.3)

		world:add(entity, flags.Gravity)
		world:add(entity, flags.Collidable)

		world:add(entity, physicsRenderType.Physics)

		return entity
	end

	function physics.grenade(id: number?): Entity
		local entity = physics.physics(id)

		world:remove(entity, physicsRenderType.Physics)
		world:add(entity, physicsRenderType.Grenade)

		world:set(entity, components.Elasticity, 0.5)

		return entity
	end

	function physics.tempentity(id: number?): Entity
		local entity = physics.physics(id)

		world:remove(entity, physicsRenderType.Physics)
		world:add(entity, physicsRenderType.Tempentity)

		return entity
	end

	function physics.normal(id: number?): Entity
		local entity = physics.physics(id)

		world:remove(entity, physicsRenderType.Physics)
		world:add(entity, physicsRenderType.Normal)

		return entity
	end

	function physics.update(deltaTime: number)
		--// Update Physics Position
		for entity: Entity, position: Vector3, velocity: Vector3 in
			world:query(components.Position, components.Velocity, physicsRenderType.Physics)
		do
			--// Apply Props
			world:set(entity, components.Position, position + velocity * deltaTime)
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
		for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3, elasticity: number in
			world:query(
				components.Position,
				components.Velocity,
				components.Size,
				components.Elasticity,
				flags.Collidable,
				physicsRenderType.Physics
			)
		do
			--// Apply Entity Size
			local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

			--// Is not Colliding
			if not result then
				world:remove(entity, components.IsColliding)
				continue
			end

			--// Apply Props
			world:set(entity, components.Normal, result.Normal)
			world:add(entity, components.IsColliding)

			--// Get Reflection Velocity
			local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * elasticity

			--// Apply Reflection Velocity
			world:set(entity, components.Velocity, dampingReflection)

			--// Is Stop Entity
			if dampingReflection:Dot(dampingReflection) < (30 * 30) / 15 then
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
			world:set(entity, components.CFrame, CFrame.new(position) * angle)
		end

		--// Update TempEntity Rotate
		for entity: Entity, velocity: Vector3 in
			world:query(components.Velocity, flags.Rotate, physicsRenderType.Tempentity)
		do
			--// Apply AngularVelocity
			world:set(entity, components.AngularVelocity, velocity * deltaTime)
		end

		--// Update TempEntity Position
		for
			entity: Entity,
			position: Vector3,
			angle: CFrame,
			velocity: Vector3,
			angularVelocity: Vector3,
			cframe: CFrame
		in
			world:query(
				components.Position,
				components.Angle,
				components.Velocity,
				components.AngularVelocity,
				components.CFrame,
				physicsRenderType.Tempentity
			)
		do
			--// Apply Position
			world:set(entity, components.Position, position + (velocity * deltaTime))

			--// Apply CFrame
			world:set(
				entity,
				components.CFrame,
				(CFrame.new(position + (velocity * deltaTime)) * CFrame.Angles(cframe:ToEulerAnglesXYZ()))
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
		for entity: Entity, position: Vector3, cframe: CFrame, velocity: Vector3, size: Vector3 in
			world:query(
				components.Position,
				components.CFrame,
				components.Velocity,
				components.Size,
				flags.Collidable,
				physicsRenderType.Tempentity
			)
		do
			--// Entity Flags Has Gravity
			local hasGravity = world:has(entity, flags.Gravity)

			--// Apply Entity Size
			local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

			--// Is not Colliding
			if not result then
				--// Apply Gravity
				if hasGravity then
					--// Apply Gravity Velocity
					world:set(entity, components.Velocity, velocity - (Vector3.yAxis * worldProps.Gravity * deltaTime))
				end

				--// Apply Colliding Prop
				world:remove(entity, components.IsColliding)
				continue
			end

			--// Apply Collision Props
			world:add(entity, components.IsColliding)
			world:set(entity, components.Normal, result.Normal)

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
						world:set(entity, components.CFrame, CFrame.new(position) * CFrame.Angles(0, y, 0))

						--// Apply Velocity
						world:set(entity, components.Velocity, Vector3.zero)

						--// Apply CFrame
						local x, y, z = cframe:ToEulerAnglesXYZ()
						world:set(
							entity,
							components.CFrame,
							CFrame.new(position) * CFrame.Angles(x * 0.9, y * 0.9, z * 0.9)
						)

						continue
					end
				end
			end

			--// Apply Reflection Velocity
			velocity = velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal
			world:set(entity, components.Velocity, velocity)

			--// Apply Angle CFrame
			local x, y, z = cframe:ToEulerAnglesXYZ()
			world:set(entity, components.CFrame, CFrame.new(cframe.Position) * CFrame.Angles(x, -y, z))

			--// Apply CFrame and Velocity
			if hasGravity then
				--// Apply Velocity
				world:set(entity, components.Velocity, velocity * 0.5)

				--// Apply CFrame
				local x, y, z = cframe:ToEulerAnglesXYZ()
				world:set(
					entity,
					components.CFrame,
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
		for entity: Entity, position: Vector3, velocity: Vector3, size: Vector3, elasticity: number in
			world:query(
				components.Position,
				components.Velocity,
				components.Size,
				components.Elasticity,
				flags.Collidable,
				physicsRenderType.Grenade
			)
		do
			--// Apply Entity Size
			local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))

			--// Is not Colliding
			if not result then
				world:remove(entity, components.IsColliding)
				continue
			end

			--// Apply Props
			world:set(entity, components.Normal, result.Normal)
			world:add(entity, components.IsColliding)

			--// Get Reflection Velocity
			local dampingReflection = (velocity - 2 * (velocity:Dot(result.Normal)) * result.Normal) * elasticity

			--// Is Gravity Colliding
			if result.Normal.Y > 0.7 then
				--// Apply Damping Reflection Velocity
				world:set(entity, components.Velocity, dampingReflection)

				--// Is Stop
				if dampingReflection:Dot(dampingReflection) < (30 * 30) / 15 then
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
				if dampingReflection:Dot(dampingReflection) < (30 * 30) / 15 then
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
			world:set(entity, components.CFrame, CFrame.new(position) * angle)
		end

		--// Update Normal Position
		for entity: Entity, position: Vector3, velocity: Vector3 in
			world:query(components.Position, components.Velocity, physicsRenderType.Normal)
		do
			--// Apply Props
			world:set(entity, components.Position, position + velocity * deltaTime)
		end

		--// Update Normal Gravity
		for entity: Entity, velocity: Vector3 in
			world:query(components.Velocity, flags.Gravity, physicsRenderType.Normal)
		do
			--// Apply Gravity
			world:set(entity, components.Velocity, velocity - (Vector3.yAxis * worldProps.Gravity * deltaTime))
		end

		--// Update Normal Angle
		for entity: Entity, angle: CFrame, angularVelocity: Vector3 in
			world:query(components.Angle, components.AngularVelocity, physicsRenderType.Normal)
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

		--// Update Normal Collision
		for
			entity: Entity,
			position: Vector3,
			angle: CFrame,
			velocity: Vector3,
			angularVelocity: Vector3,
			size: Vector3,
			elasticity: number
		in
			world:query(
				components.Position,
				components.Angle,
				components.Velocity,
				components.AngularVelocity,
				components.Size,
				components.Elasticity,
				physicsRenderType.Normal,
				flags.Collidable
			)
		do
			--// Apply Entity Size
			local result = workspace:Raycast(position, (velocity * deltaTime) + (velocity:Sign() * (size / 2)))
			
			--// Get is last colliding
			local isLastColliding = not world:has(entity, flags.LastColliding)

            --// Add LastColliding flag
            if isLastColliding then
                world:add(entity, flags.LastColliding)
            end

			--// Is not Colliding
			if not result then
				world:remove(entity, components.IsColliding)
				continue
			end

			--// Apply Props
			world:set(entity, components.Normal, result.Normal)
			world:add(entity, components.IsColliding)
           
			--// Get Normal Velocity
            local normalVelocity = result.Normal:Dot(velocity) * result.Normal

			--// Get Tangential Velocity 
            local tangentialVelocity = velocity - normalVelocity

			--// Get Friction Value
            local frictionValue = if isLastColliding then
                1 - 0.08 * deltaTime / tangentialVelocity.Magnitude
            else
                1 - 0.08 * ((1 + elasticity) * normalVelocity.Magnitude) / tangentialVelocity.Magnitude 

			--// Set props
            world:set(
                entity, 
                components.Velocity, 
                tangentialVelocity * math.max(frictionValue, 0) - elasticity * normalVelocity
            )

            world:set(
                entity, 
                components.AngularVelocity, 
                result.Normal:Cross(velocity) / elasticity * angle:ToEulerAnglesYXZ()
            )

            world:set(
                entity,
                components.Position, 
                position + result.Normal * 0.01
            )
		end

		--// Update Normal CFrame
		for entity: Entity, position: Vector3, angle: CFrame in
			world:query(components.Position, components.Angle, physicsRenderType.Normal)
		do
			--// Apply CFrame
			world:set(entity, components.CFrame, CFrame.new(position) * angle)
		end
	end

	return physics
end
