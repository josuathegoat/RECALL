-- FastCastRedux - Combined single-file version
-- Originally by EtiTheSpirit (Xan_TheDragon)
-- This is a combined/redux version sourced from github.com/rutheniumm/roblox

local TestService = game:GetService("TestService")

local SignalStatic = {}
SignalStatic.__index = SignalStatic
SignalStatic.__type = "Signal"
local ConnectionStatic = {}
ConnectionStatic.__index = ConnectionStatic
ConnectionStatic.__type = "SignalConnection"

export type Signal = {
	Name: string,
	Connections: {[number]: Connection},
	YieldingThreads: {[number]: BindableEvent}
}

export type Connection = {
	Signal: Signal?,
	Delegate: any,
	Index: number
}

local ERR_NOT_INSTANCE = "Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"

function SignalStatic.new(signalName: string): Signal
	local signalObj: Signal = {
		Name = signalName,
		Connections = {},
		YieldingThreads = {}
	}
	return setmetatable(signalObj, SignalStatic)
end

local function NewConnection(sig: Signal, func: any): Connection
	local connectionObj: Connection = {
		Signal = sig,
		Delegate = func,
		Index = -1
	}
	return setmetatable(connectionObj, ConnectionStatic)
end

local function ThreadAndReportError(delegate: any, args, handlerName: string)
	local thread = coroutine.create(function ()
		delegate(unpack(args))
	end)
	local success, msg = coroutine.resume(thread)
	if not success then
		TestService:Error(string.format("Exception thrown in your %s event handler: %s", handlerName, msg))
		TestService:Checkpoint(debug.traceback(thread))
	end
end

function SignalStatic:Connect(func)
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Connect", "Signal.new()"))
	local connection = NewConnection(self, func)
	connection.Index = #self.Connections + 1
	table.insert(self.Connections, connection.Index, connection)
	return connection
end

function SignalStatic:Fire(...)
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Fire", "Signal.new()"))
	local args = table.pack(...)
	local allCons = self.Connections
	local yieldingThreads = self.YieldingThreads
	for index = 1, #allCons do
		local connection = allCons[index]
		if connection.Delegate ~= nil then
			ThreadAndReportError(connection.Delegate, args, connection.Signal.Name)
		end
	end
	for index = 1, #yieldingThreads do
		local thread = yieldingThreads[index]
		if thread ~= nil then
			coroutine.resume(thread, ...)
		end
	end
end

function SignalStatic:FireSync(...)
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("FireSync", "Signal.new()"))
	local args = table.pack(...)
	local allCons = self.Connections
	local yieldingThreads = self.YieldingThreads
	for index = 1, #allCons do
		local connection = allCons[index]
		if connection.Delegate ~= nil then
			connection.Delegate(unpack(args))
		end
	end
	for index = 1, #yieldingThreads do
		local thread = yieldingThreads[index]
		if thread ~= nil then
			coroutine.resume(thread, ...)
		end
	end
end

function SignalStatic:Wait()
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Wait", "Signal.new()"))
	local args = {}
	local thread = coroutine.running()
	table.insert(self.YieldingThreads, thread)
	args = { coroutine.yield() }
	table.removeObject(self.YieldingThreads, thread)
	return unpack(args)
end

function SignalStatic:Dispose()
	assert(getmetatable(self) == SignalStatic, ERR_NOT_INSTANCE:format("Dispose", "Signal.new()"))
	local allCons = self.Connections
	for index = 1, #allCons do
		allCons[index]:Disconnect()
	end
	self.Connections = {}
	setmetatable(self, nil)
end

function ConnectionStatic:Disconnect()
	assert(getmetatable(self) == ConnectionStatic, ERR_NOT_INSTANCE:format("Disconnect", "private function NewConnection()"))
	table.remove(self.Signal.Connections, self.Index)
	self.SignalStatic = nil
	self.Delegate = nil
	self.YieldingThreads = {}
	self.Index = -1
	setmetatable(self, nil)
end

local oldtypeof = typeof
local function typeof(objIn: any): string
	local objType = oldtypeof(objIn)
	if objType ~= "table" then return objType end
	local meta = getmetatable(objIn)
	if oldtypeof(meta) ~= "table" then return objType end
	local customType: string? = meta["__type"]
	if customType == nil then return objType end
	return customType
end

-----------------------------------------------------------
-------------------- MODULE DEFINITION --------------------
-----------------------------------------------------------

local ActiveCastStatic = {}
ActiveCastStatic.__index = ActiveCastStatic
ActiveCastStatic.__type = "ActiveCast"

-----------------------------------------------------------
----------------------- STATIC DATA -----------------------
-----------------------------------------------------------
local RunService = game:GetService("RunService")
local RNG = Random.new()
local RobloxTable = table
local Table = {}

Table.contains = function (tbl, value)
	return Table.indexOf(tbl, value) ~= nil
end

Table.indexOf = function (tbl, value)
	local fromFind = table.find(tbl, value)
	if fromFind then return fromFind end
	return Table.keyOf(tbl, value)
end

Table.keyOf = function (tbl, value)
	for index, obj in pairs(tbl) do
		if obj == value then
			return index
		end
	end
	return nil
end

Table.insertAndGetIndexOf = function (tbl, value)
	tbl[#tbl + 1] = value
	return #tbl
end

Table.skip = function (tbl, n)
	return table.move(tbl, n+1, #tbl, 1, table.create(#tbl-n))
end

Table.take = function (tbl, n)
	return table.move(tbl, 1, n, 1, table.create(n))
end

Table.range = function (tbl, start, finish)
	return table.move(tbl, start, finish, 1, table.create(finish - start + 1))
end

Table.skipAndTake = function (tbl, skip, take)
	return table.move(tbl, skip + 1, skip + take, 1, table.create(take))
end

Table.random = function (tbl)
	return tbl[RNG:NextInteger(1, #tbl)]
end

Table.join = function (tbl0, tbl1)
	local nt = table.create(#tbl0 + #tbl1)
	local t2 = table.move(tbl0, 1, #tbl0, 1, nt)
	return table.move(tbl1, 1, #tbl1, #tbl0 + 1, nt)
end

Table.removeObject = function (tbl, obj)
	local index = Table.indexOf(tbl, obj)
	if index then
		table.remove(tbl, index)
	end
end

local table = setmetatable({}, {
	__index = function(tbl, index)
		if Table[index] ~= nil then
			return Table[index]
		else
			return RobloxTable[index]
		end
	end;

	__newindex = function(tbl, index, value)
		error("Add new table entries by editing the Module itself.")
	end;
})

local FastCast = nil -- Static reference to the FastCast static module.

local ERR_NOT_INSTANCE = "Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"
local ERR_INVALID_TYPE = "Invalid type for parameter '%s' (Expected %s, got %s)"
local FC_VIS_OBJ_NAME = "FastCastVisualizationObjects"
local ERR_OBJECT_DISPOSED = "This ActiveCast has been terminated. It can no longer be used."
local MAX_PIERCE_TEST_COUNT = 100

-----------------------------------------------------------
------------------------ UTILITIES ------------------------
-----------------------------------------------------------

local function GetFastCastVisualizationContainer(): Instance
	local fcVisualizationObjects = workspace.Terrain:FindFirstChild(FC_VIS_OBJ_NAME)
	if fcVisualizationObjects ~= nil then
		return fcVisualizationObjects
	end
	fcVisualizationObjects = Instance.new("Folder")
	fcVisualizationObjects.Name = FC_VIS_OBJ_NAME
	fcVisualizationObjects.Archivable = false
	fcVisualizationObjects.Parent = workspace.Terrain
	return fcVisualizationObjects
end

-----------------------------------------------------------
------------------------ DEBUGGING ------------------------
-----------------------------------------------------------

local function PrintDebug(message: string)
	if FastCast.DebugLogging == true then
		print(message)
	end
end

function DbgVisualizeSegment(castStartCFrame: CFrame, castLength: number): ConeHandleAdornment?
	if FastCast.VisualizeCasts ~= true then return nil end
	local adornment = Instance.new("ConeHandleAdornment")
	adornment.Adornee = workspace.Terrain
	adornment.CFrame = castStartCFrame
	adornment.Height = castLength
	adornment.Color3 = Color3.new()
	adornment.Radius = 0.25
	adornment.Transparency = 0.5
	adornment.Parent = GetFastCastVisualizationContainer()
	return adornment
end

function DbgVisualizeHit(atCF: CFrame, wasPierce: boolean): SphereHandleAdornment?
	if FastCast.VisualizeCasts ~= true then return nil end
	local adornment = Instance.new("SphereHandleAdornment")
	adornment.Adornee = workspace.Terrain
	adornment.CFrame = atCF
	adornment.Radius = 0.4
	adornment.Transparency = 0.25
	adornment.Color3 = (wasPierce == false) and Color3.new(0.2, 1, 0.5) or Color3.new(1, 0.2, 0.2)
	adornment.Parent = GetFastCastVisualizationContainer()
	return adornment
end

-----------------------------------------------------------
------------------------ CORE CODE ------------------------
-----------------------------------------------------------

local function GetPositionAtTime(time: number, origin: Vector3, initialVelocity: Vector3, acceleration: Vector3): Vector3
	local force = Vector3.new((acceleration.X * time^2) / 2,(acceleration.Y * time^2) / 2, (acceleration.Z * time^2) / 2)
	return origin + (initialVelocity * time) + force
end

local function GetVelocityAtTime(time: number, initialVelocity: Vector3, acceleration: Vector3): Vector3
	return initialVelocity + acceleration * time
end

local function GetTrajectoryInfo(cast, index: number)
	assert(cast.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	local trajectories = cast.StateInfo.Trajectories
	local trajectory = trajectories[index]
	local duration = trajectory.EndTime - trajectory.StartTime
	local origin = trajectory.Origin
	local vel = trajectory.InitialVelocity
	local accel = trajectory.Acceleration
	return {GetPositionAtTime(duration, origin, vel, accel), GetVelocityAtTime(duration, vel, accel)}
end

local function GetLatestTrajectoryEndInfo(cast)
	assert(cast.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	return GetTrajectoryInfo(cast, #cast.StateInfo.Trajectories)
end

local function CloneCastParams(params: RaycastParams): RaycastParams
	local clone = RaycastParams.new()
	clone.CollisionGroup = params.CollisionGroup
	clone.FilterType = params.FilterType
	clone.FilterDescendantsInstances = params.FilterDescendantsInstances
	clone.IgnoreWater = params.IgnoreWater
	return clone
end

local function SendRayHit(cast, resultOfCast, segmentVelocity, cosmeticBulletObject)
	cast.Caster.RayHit:Fire(cast, resultOfCast, segmentVelocity, cosmeticBulletObject)
end

local function SendRayPierced(cast, resultOfCast, segmentVelocity, cosmeticBulletObject)
	cast.Caster.RayPierced:Fire(cast, resultOfCast, segmentVelocity, cosmeticBulletObject)
end

local function SendLengthChanged(cast, lastPoint, rayDir, rayDisplacement, segmentVelocity, cosmeticBulletObject)
	cast.Caster.LengthChanged:Fire(cast, lastPoint, rayDir, rayDisplacement, segmentVelocity, cosmeticBulletObject)
end

-----------------------------------------------------------
----------------------- SIMULATION ------------------------
-----------------------------------------------------------

local function SimulateCast(cast, delta: number, expectingShortCall: boolean)
	assert(cast.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	PrintDebug("Casting for frame.")
	local latestTrajectory = cast.StateInfo.Trajectories[#cast.StateInfo.Trajectories]

	local origin = latestTrajectory.Origin
	local totalDelta = cast.StateInfo.TotalRuntime - latestTrajectory.StartTime
	local initialVelocity = latestTrajectory.InitialVelocity
	local acceleration = latestTrajectory.Acceleration

	local lastPoint = GetPositionAtTime(totalDelta, origin, initialVelocity, acceleration)
	local lastVelocity = GetVelocityAtTime(totalDelta, initialVelocity, acceleration)
	local lastDelta = cast.StateInfo.TotalRuntime - latestTrajectory.StartTime

	cast.StateInfo.TotalRuntime += delta

	totalDelta = cast.StateInfo.TotalRuntime - latestTrajectory.StartTime

	local currentTarget = GetPositionAtTime(totalDelta, origin, initialVelocity, acceleration)
	local segmentVelocity = GetVelocityAtTime(totalDelta, initialVelocity, acceleration)
	local totalDisplacement = currentTarget - lastPoint

	local rayDir = totalDisplacement.Unit * segmentVelocity.Magnitude * delta
	local targetWorldRoot = cast.RayInfo.WorldRoot
	local resultOfCast = targetWorldRoot:Raycast(lastPoint, rayDir, cast.RayInfo.Parameters)

	local point = currentTarget
	local part: Instance? = nil
	local material = Enum.Material.Air
	local normal = Vector3.new()

	if (resultOfCast ~= nil) then
		point = resultOfCast.Position
		part = resultOfCast.Instance
		material = resultOfCast.Material
		normal = resultOfCast.Normal
	end

	local rayDisplacement = (point - lastPoint).Magnitude

	SendLengthChanged(cast, lastPoint, rayDir.Unit, rayDisplacement, segmentVelocity, cast.RayInfo.CosmeticBulletObject)
	cast.StateInfo.DistanceCovered += rayDisplacement

	local rayVisualization: ConeHandleAdornment? = nil
	if (delta > 0) then
		rayVisualization = DbgVisualizeSegment(CFrame.new(lastPoint, lastPoint + rayDir), rayDisplacement)
	end

	if part and part ~= cast.RayInfo.CosmeticBulletObject then
		local start = tick()
		PrintDebug("Hit something, testing now.")

		if (cast.RayInfo.CanPierceCallback ~= nil) then
			if expectingShortCall == false then
				if (cast.StateInfo.IsActivelySimulatingPierce) then
					cast:Terminate()
					error("ERROR: The latest call to CanPierceCallback took too long to complete! This cast is going to suffer desyncs which WILL cause unexpected behavior and errors. Please fix your performance problems, or remove statements that yield (e.g. wait() calls)")
				end
			end
			cast.StateInfo.IsActivelySimulatingPierce = true
		end

		if cast.RayInfo.CanPierceCallback == nil or (cast.RayInfo.CanPierceCallback ~= nil and cast.RayInfo.CanPierceCallback(cast, resultOfCast, segmentVelocity, cast.RayInfo.CosmeticBulletObject) == false) then
			PrintDebug("Piercing function is nil or it returned FALSE to not pierce this hit.")
			cast.StateInfo.IsActivelySimulatingPierce = false

			if (cast.StateInfo.HighFidelityBehavior == 2 and latestTrajectory.Acceleration ~= Vector3.new() and cast.StateInfo.HighFidelitySegmentSize ~= 0) then
				cast.StateInfo.CancelHighResCast = false

				if cast.StateInfo.IsActivelyResimulating then
					cast:Terminate()
					error("Cascading cast lag encountered! The caster attempted to perform a high fidelity cast before the previous one completed, resulting in exponential cast lag. Consider increasing HighFidelitySegmentSize.")
				end

				cast.StateInfo.IsActivelyResimulating = true

				PrintDebug("Hit was registered, but recalculation is on for physics based casts. Recalculating to verify a real hit...")

				local numSegmentsDecimal = rayDisplacement / cast.StateInfo.HighFidelitySegmentSize
				local numSegmentsReal = math.floor(numSegmentsDecimal)
				local realSegmentLength = rayDisplacement / numSegmentsReal

				local timeIncrement = delta / numSegmentsReal
				for segmentIndex = 1, numSegmentsReal do
					if cast.StateInfo.CancelHighResCast then
						cast.StateInfo.CancelHighResCast = false
						break
					end

					local subPosition = GetPositionAtTime(lastDelta + (timeIncrement * segmentIndex), origin, initialVelocity, acceleration)
					local subVelocity = GetVelocityAtTime(lastDelta + (timeIncrement * segmentIndex), initialVelocity, acceleration)
					local subRayDir = subVelocity * delta
					local subResult = targetWorldRoot:Raycast(subPosition, subRayDir, cast.RayInfo.Parameters)

					local subDisplacement = (subPosition - (subPosition + subVelocity)).Magnitude

					if (subResult ~= nil) then
						local subDisplacement = (subPosition - subResult.Position).Magnitude
						local dbgSeg = DbgVisualizeSegment(CFrame.new(subPosition, subPosition + subVelocity), subDisplacement)
						if (dbgSeg ~= nil) then dbgSeg.Color3 = Color3.new(0.286275, 0.329412, 0.247059) end

						if cast.RayInfo.CanPierceCallback == nil or (cast.RayInfo.CanPierceCallback ~= nil and cast.RayInfo.CanPierceCallback(cast, subResult, subVelocity, cast.RayInfo.CosmeticBulletObject) == false) then
							cast.StateInfo.IsActivelyResimulating = false
							SendRayHit(cast, subResult, subVelocity, cast.RayInfo.CosmeticBulletObject)
							cast:Terminate()
							local vis = DbgVisualizeHit(CFrame.new(point), false)
							if (vis ~= nil) then vis.Color3 = Color3.new(0.0588235, 0.87451, 1) end
							return
						else
							SendRayPierced(cast, subResult, subVelocity, cast.RayInfo.CosmeticBulletObject)
							local vis = DbgVisualizeHit(CFrame.new(point), true)
							if (vis ~= nil) then vis.Color3 = Color3.new(1, 0.113725, 0.588235) end
							if (dbgSeg ~= nil) then dbgSeg.Color3 = Color3.new(0.305882, 0.243137, 0.329412) end
						end
					else
						local dbgSeg = DbgVisualizeSegment(CFrame.new(subPosition, subPosition + subVelocity), subDisplacement)
						if (dbgSeg ~= nil) then dbgSeg.Color3 = Color3.new(0.286275, 0.329412, 0.247059) end
					end
				end

				cast.StateInfo.IsActivelyResimulating = false
			elseif (cast.StateInfo.HighFidelityBehavior ~= 1 and cast.StateInfo.HighFidelityBehavior ~= 3) then
				cast:Terminate()
				error("Invalid value " .. (cast.StateInfo.HighFidelityBehavior) .. " for HighFidelityBehavior.")
			else
				PrintDebug("Hit was successful. Terminating.")
				SendRayHit(cast, resultOfCast, segmentVelocity, cast.RayInfo.CosmeticBulletObject)
				cast:Terminate()
				DbgVisualizeHit(CFrame.new(point), false)
				return
			end
		else
			PrintDebug("Piercing function returned TRUE to pierce this part.")
			if rayVisualization ~= nil then
				rayVisualization.Color3 = Color3.new(0.4, 0.05, 0.05)
			end
			DbgVisualizeHit(CFrame.new(point), true)

			local params = cast.RayInfo.Parameters
			local alteredParts = {}
			local currentPierceTestCount = 0
			local originalFilter = params.FilterDescendantsInstances
			local brokeFromSolidObject = false
			while true do
				if resultOfCast.Instance:IsA("Terrain") then
					if material == Enum.Material.Water then
						cast:Terminate()
						error("Do not add Water as a piercable material. If you need to pierce water, set cast.RayInfo.Parameters.IgnoreWater = true instead", 0)
					end
					warn("WARNING: The pierce callback for this cast returned TRUE on Terrain! This can cause severely adverse effects.")
				end

				if params.FilterType == Enum.RaycastFilterType.Blacklist then
					local filter = params.FilterDescendantsInstances
					table.insert(filter, resultOfCast.Instance)
					table.insert(alteredParts, resultOfCast.Instance)
					params.FilterDescendantsInstances = filter
				else
					local filter = params.FilterDescendantsInstances
					table.removeObject(filter, resultOfCast.Instance)
					table.insert(alteredParts, resultOfCast.Instance)
					params.FilterDescendantsInstances = filter
				end

				SendRayPierced(cast, resultOfCast, segmentVelocity, cast.RayInfo.CosmeticBulletObject)

				resultOfCast = targetWorldRoot:Raycast(lastPoint, rayDir, params)

				if resultOfCast == nil then
					break
				end

				if currentPierceTestCount >= MAX_PIERCE_TEST_COUNT then
					warn("WARNING: Exceeded maximum pierce test budget for a single ray segment (attempted to test the same segment " .. MAX_PIERCE_TEST_COUNT .. " times!)")
					break
				end
				currentPierceTestCount = currentPierceTestCount + 1;

				if cast.RayInfo.CanPierceCallback(cast, resultOfCast, segmentVelocity, cast.RayInfo.CosmeticBulletObject) == false then
					brokeFromSolidObject = true
					break
				end
			end

			cast.RayInfo.Parameters.FilterDescendantsInstances = originalFilter
			cast.StateInfo.IsActivelySimulatingPierce = false

			if brokeFromSolidObject then
				PrintDebug("Broke because the ray hit something solid (" .. tostring(resultOfCast.Instance) .. ") while testing for a pierce. Terminating the cast.")
				SendRayHit(cast, resultOfCast, segmentVelocity, cast.RayInfo.CosmeticBulletObject)
				cast:Terminate()
				DbgVisualizeHit(CFrame.new(resultOfCast.Position), false)
				return
			end
		end
	end

	if (cast.StateInfo.DistanceCovered >= cast.RayInfo.MaxDistance) then
		cast:Terminate()
		DbgVisualizeHit(CFrame.new(currentTarget), false)
	end
end

-----------------------------------------------------------
-------------------- ACTIVECAST CTOR ----------------------
-----------------------------------------------------------

function ActiveCastStatic.new(caster, origin: Vector3, direction: Vector3, velocity: Vector3 | number, castDataPacket)
	if typeof(velocity) == "number" then
		velocity = direction.Unit * velocity
	end

	if (castDataPacket.HighFidelitySegmentSize <= 0) then
		error("Cannot set FastCastBehavior.HighFidelitySegmentSize <= 0!", 0)
	end

	local cast = {
		Caster = caster,
		StateInfo = {
			UpdateConnection = nil,
			Paused = false,
			TotalRuntime = 0,
			DistanceCovered = 0,
			HighFidelitySegmentSize = castDataPacket.HighFidelitySegmentSize,
			HighFidelityBehavior = castDataPacket.HighFidelityBehavior,
			IsActivelySimulatingPierce = false,
			IsActivelyResimulating = false,
			CancelHighResCast = false,
			Trajectories = {
				{
					StartTime = 0,
					EndTime = -1,
					Origin = origin,
					InitialVelocity = velocity,
					Acceleration = castDataPacket.Acceleration
				}
			}
		},
		RayInfo = {
			Parameters = castDataPacket.RaycastParams,
			WorldRoot = workspace,
			MaxDistance = castDataPacket.MaxDistance or 1000,
			CosmeticBulletObject = castDataPacket.CosmeticBulletTemplate,
			CanPierceCallback = castDataPacket.CanPierceFunction
		},
		UserData = {}
	}

	if cast.StateInfo.HighFidelityBehavior == 2 then
		cast.StateInfo.HighFidelityBehavior = 3
	end

	if cast.RayInfo.Parameters ~= nil then
		cast.RayInfo.Parameters = CloneCastParams(cast.RayInfo.Parameters)
	else
		cast.RayInfo.Parameters = RaycastParams.new()
	end

	local usingProvider = false
	if castDataPacket.CosmeticBulletProvider == nil then
		if cast.RayInfo.CosmeticBulletObject ~= nil then
			cast.RayInfo.CosmeticBulletObject = cast.RayInfo.CosmeticBulletObject:Clone()
			cast.RayInfo.CosmeticBulletObject.CFrame = CFrame.new(origin, origin + direction)
			cast.RayInfo.CosmeticBulletObject.Parent = castDataPacket.CosmeticBulletContainer
		end
	else
		if typeof(castDataPacket.CosmeticBulletProvider) == "PartCache" then
			if cast.RayInfo.CosmeticBulletObject ~= nil then
				warn("Do not define FastCastBehavior.CosmeticBulletTemplate and FastCastBehavior.CosmeticBulletProvider at the same time! The provider will be used, and CosmeticBulletTemplate will be set to nil.")
				cast.RayInfo.CosmeticBulletObject = nil
				castDataPacket.CosmeticBulletTemplate = nil
			end
			cast.RayInfo.CosmeticBulletObject = castDataPacket.CosmeticBulletProvider:GetPart()
			cast.RayInfo.CosmeticBulletObject.CFrame = CFrame.new(origin, origin + direction)
			usingProvider = true
		else
			warn("FastCastBehavior.CosmeticBulletProvider was not an instance of the PartCache module (an external/separate model)! Are you inputting an instance created via PartCache.new? If so, are you on the latest version of PartCache? Setting FastCastBehavior.CosmeticBulletProvider to nil.")
			castDataPacket.CosmeticBulletProvider = nil
		end
	end

	local targetContainer: Instance;
	if usingProvider then
		targetContainer = castDataPacket.CosmeticBulletProvider.CurrentCacheParent
	else
		targetContainer = castDataPacket.CosmeticBulletContainer
	end

	if castDataPacket.AutoIgnoreContainer == true and targetContainer ~= nil then
		local ignoreList = cast.RayInfo.Parameters.FilterDescendantsInstances
		if table.find(ignoreList, targetContainer) == nil then
			table.insert(ignoreList, targetContainer)
			cast.RayInfo.Parameters.FilterDescendantsInstances = ignoreList
		end
	end

	local event
	if RunService:IsClient() then
		event = RunService.RenderStepped
	else
		event = RunService.Heartbeat
	end

	setmetatable(cast, ActiveCastStatic)

	cast.StateInfo.UpdateConnection = event:Connect(function (delta)
		if cast.StateInfo.Paused then return end

		PrintDebug("Casting for frame.")
		local latestTrajectory = cast.StateInfo.Trajectories[#cast.StateInfo.Trajectories]
		if (cast.StateInfo.HighFidelityBehavior == 3 and latestTrajectory.Acceleration ~= Vector3.new() and cast.StateInfo.HighFidelitySegmentSize > 0) then

			local timeAtStart = tick()

			if cast.StateInfo.IsActivelyResimulating then
				cast:Terminate()
				error("Cascading cast lag encountered! The caster attempted to perform a high fidelity cast before the previous one completed, resulting in exponential cast lag. Consider increasing HighFidelitySegmentSize.")
			end

			cast.StateInfo.IsActivelyResimulating = true

			local origin = latestTrajectory.Origin
			local totalDelta = cast.StateInfo.TotalRuntime - latestTrajectory.StartTime
			local initialVelocity = latestTrajectory.InitialVelocity
			local acceleration = latestTrajectory.Acceleration

			local lastPoint = GetPositionAtTime(totalDelta, origin, initialVelocity, acceleration)
			local lastVelocity = GetVelocityAtTime(totalDelta, initialVelocity, acceleration)
			local lastDelta = cast.StateInfo.TotalRuntime - latestTrajectory.StartTime

			cast.StateInfo.TotalRuntime += delta

			totalDelta = cast.StateInfo.TotalRuntime - latestTrajectory.StartTime

			local currentPoint = GetPositionAtTime(totalDelta, origin, initialVelocity, acceleration)
			local currentVelocity = GetVelocityAtTime(totalDelta, initialVelocity, acceleration)
			local totalDisplacement = currentPoint - lastPoint

			local rayDir = totalDisplacement.Unit * currentVelocity.Magnitude * delta
			local targetWorldRoot = cast.RayInfo.WorldRoot
			local resultOfCast = targetWorldRoot:Raycast(lastPoint, rayDir, cast.RayInfo.Parameters)

			local point = currentPoint

			if (resultOfCast ~= nil) then
				point = resultOfCast.Position
			end

			local rayDisplacement = (point - lastPoint).Magnitude

			cast.StateInfo.TotalRuntime -= delta

			local numSegmentsDecimal = rayDisplacement / cast.StateInfo.HighFidelitySegmentSize
			local numSegmentsReal = math.floor(numSegmentsDecimal)
			if (numSegmentsReal == 0) then
				numSegmentsReal = 1
			end

			local timeIncrement = delta / numSegmentsReal

			for segmentIndex = 1, numSegmentsReal do
				if getmetatable(cast) == nil then return end
				if cast.StateInfo.CancelHighResCast then
					cast.StateInfo.CancelHighResCast = false
					break
				end
				PrintDebug("[" .. segmentIndex .. "] Subcast of time increment " .. timeIncrement)
				SimulateCast(cast, timeIncrement, true)
			end

			if getmetatable(cast) == nil then return end
			cast.StateInfo.IsActivelyResimulating = false

			if (tick() - timeAtStart) > 0.016 * 5 then
				warn("Extreme cast lag encountered! Consider increasing HighFidelitySegmentSize.")
			end

		else
			SimulateCast(cast, delta, false)
		end
	end)

	return cast
end

function ActiveCastStatic.SetStaticFastCastReference(ref)
	FastCast = ref
end

---- GETTERS AND SETTERS ----

local function ModifyTransformation(cast, velocity: Vector3?, acceleration: Vector3?, position: Vector3?)
	local trajectories = cast.StateInfo.Trajectories
	local lastTrajectory = trajectories[#trajectories]

	if lastTrajectory.StartTime == cast.StateInfo.TotalRuntime then
		if (velocity == nil) then
			velocity = lastTrajectory.InitialVelocity
		end
		if (acceleration == nil) then
			acceleration = lastTrajectory.Acceleration
		end
		if (position == nil) then
			position = lastTrajectory.Origin
		end

		lastTrajectory.Origin = position
		lastTrajectory.InitialVelocity = velocity
		lastTrajectory.Acceleration = acceleration
	else
		lastTrajectory.EndTime = cast.StateInfo.TotalRuntime

		local point, velAtPoint = unpack(GetLatestTrajectoryEndInfo(cast))

		if (velocity == nil) then
			velocity = velAtPoint
		end
		if (acceleration == nil) then
			acceleration = lastTrajectory.Acceleration
		end
		if (position == nil) then
			position = point
		end
		table.insert(cast.StateInfo.Trajectories, {
			StartTime = cast.StateInfo.TotalRuntime,
			EndTime = -1,
			Origin = position,
			InitialVelocity = velocity,
			Acceleration = acceleration
		})
		cast.StateInfo.CancelHighResCast = true
	end
end

function ActiveCastStatic:SetVelocity(velocity: Vector3)
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("SetVelocity", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	ModifyTransformation(self, velocity, nil, nil)
end

function ActiveCastStatic:SetAcceleration(acceleration: Vector3)
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("SetAcceleration", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	ModifyTransformation(self, nil, acceleration, nil)
end

function ActiveCastStatic:SetPosition(position: Vector3)
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("SetPosition", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	ModifyTransformation(self, nil, nil, position)
end

---- GETTERS ----

function ActiveCastStatic:GetVelocity(): Vector3
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("GetVelocity", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	local currentTrajectory = self.StateInfo.Trajectories[#self.StateInfo.Trajectories]
	return GetVelocityAtTime(self.StateInfo.TotalRuntime - currentTrajectory.StartTime, currentTrajectory.InitialVelocity, currentTrajectory.Acceleration)
end

function ActiveCastStatic:GetAcceleration(): Vector3
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("GetAcceleration", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	local currentTrajectory = self.StateInfo.Trajectories[#self.StateInfo.Trajectories]
	return currentTrajectory.Acceleration
end

function ActiveCastStatic:GetPosition(): Vector3
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("GetPosition", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	local currentTrajectory = self.StateInfo.Trajectories[#self.StateInfo.Trajectories]
	return GetPositionAtTime(self.StateInfo.TotalRuntime - currentTrajectory.StartTime, currentTrajectory.Origin, currentTrajectory.InitialVelocity, currentTrajectory.Acceleration)
end

---- ARITHMETIC ----

function ActiveCastStatic:AddVelocity(velocity: Vector3)
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("AddVelocity", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	self:SetVelocity(self:GetVelocity() + velocity)
end

function ActiveCastStatic:AddAcceleration(acceleration: Vector3)
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("AddAcceleration", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	self:SetAcceleration(self:GetAcceleration() + acceleration)
end

function ActiveCastStatic:AddPosition(position: Vector3)
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("AddPosition", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	self:SetPosition(self:GetPosition() + position)
end

---- STATE MODIFICATION ----

function ActiveCastStatic:Pause()
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("Pause", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	self.StateInfo.Paused = true
end

function ActiveCastStatic:Resume()
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("Resume", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)
	self.StateInfo.Paused = false
end

function ActiveCastStatic:Terminate()
	assert(getmetatable(self) == ActiveCastStatic, ERR_NOT_INSTANCE:format("Terminate", "ActiveCast.new(...)"))
	assert(self.StateInfo.UpdateConnection ~= nil, ERR_OBJECT_DISPOSED)

	local trajectories = self.StateInfo.Trajectories
	local lastTrajectory = trajectories[#trajectories]
	lastTrajectory.EndTime = self.StateInfo.TotalRuntime

	self.StateInfo.UpdateConnection:Disconnect()

	self.Caster.CastTerminating:FireSync(self)

	self.StateInfo.UpdateConnection = nil

	self.Caster = nil
	self.StateInfo = nil
	self.RayInfo = nil
	self.UserData = nil
	setmetatable(self, nil)
end

-----------------------------------------------------------
----------------------- FASTCAST --------------------------
-----------------------------------------------------------

local FastCastModule = {}
FastCastModule.DebugLogging = false
FastCastModule.VisualizeCasts = false
FastCastModule.__index = FastCastModule
FastCastModule.__type = "FastCast"

FastCastModule.HighFidelityBehavior = {
	Default = 1,
	Always = 3
}

local Signal = SignalStatic

ActiveCastStatic.SetStaticFastCastReference(FastCastModule)

function FastCastModule.new()
	return setmetatable({
		LengthChanged = Signal.new("LengthChanged"),
		RayHit = Signal.new("RayHit"),
		RayPierced = Signal.new("RayPierced"),
		CastTerminating = Signal.new("CastTerminating"),
		WorldRoot = workspace
	}, FastCastModule)
end

function FastCastModule.newBehavior()
	return {
		RaycastParams = nil,
		Acceleration = Vector3.new(),
		MaxDistance = 1000,
		CanPierceFunction = nil,
		HighFidelityBehavior = FastCastModule.HighFidelityBehavior.Default,
		HighFidelitySegmentSize = 0.5,
		CosmeticBulletTemplate = nil,
		CosmeticBulletProvider = nil,
		CosmeticBulletContainer = nil,
		AutoIgnoreContainer = true
	}
end

local DEFAULT_DATA_PACKET = FastCastModule.newBehavior()
function FastCastModule:Fire(origin: Vector3, direction: Vector3, velocity: Vector3 | number, castDataPacket?)
	if castDataPacket == nil then castDataPacket = DEFAULT_DATA_PACKET end
	local cast = ActiveCastStatic.new(self, origin, direction, velocity, castDataPacket)
	cast.RayInfo.WorldRoot = self.WorldRoot
	return cast
end

export type CanPierceFunction = (any, RaycastResult, Vector3) -> boolean
export type GenericTable = {[any]: any}

export type Caster = {
	WorldRoot: WorldRoot,
	LengthChanged: any,
	RayHit: any,
	RayPierced: any,
	CastTerminating: any,
	Fire: (Vector3, Vector3, Vector3 | number, FastCastBehavior) -> ()
}

export type FastCastBehavior = {
	RaycastParams: RaycastParams?,
	MaxDistance: number,
	Acceleration: Vector3,
	HighFidelityBehavior: number,
	HighFidelitySegmentSize: number,
	CosmeticBulletTemplate: Instance?,
	CosmeticBulletProvider: any,
	CosmeticBulletContainer: Instance?,
	AutoIgnoreContainer: boolean,
	CanPierceFunction: CanPierceFunction
}

export type CastTrajectory = {
	StartTime: number,
	EndTime: number,
	Origin: Vector3,
	InitialVelocity: Vector3,
	Acceleration: Vector3
}

export type CastStateInfo = {
	UpdateConnection: any,
	HighFidelityBehavior: number,
	HighFidelitySegmentSize: number,
	Paused: boolean,
	TotalRuntime: number,
	DistanceCovered: number,
	IsActivelySimulatingPierce: boolean,
	IsActivelyResimulating: boolean,
	CancelHighResCast: boolean,
	Trajectories: {[number]: CastTrajectory}
}

export type CastRayInfo = {
	Parameters: RaycastParams,
	WorldRoot: WorldRoot,
	MaxDistance: number,
	CosmeticBulletObject: Instance?,
	CanPierceCallback: CanPierceFunction
}

export type ActiveCast = {
	Caster: Caster,
	StateInfo: CastStateInfo,
	RayInfo: CastRayInfo,
	UserData: {[any]: any}
}

return FastCastModule
