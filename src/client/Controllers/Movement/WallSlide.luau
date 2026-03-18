--[[
    RECALL — Wall Slide Module
    When airborne and pressing into a wall, the player slides down it slowly.
    Chains: Wall Slide -> Wall Bounce (jump off wall), Wall Slide -> AirDash.
           Resets double jump on wall contact for extended aerial play.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local WALL_DETECT_DISTANCE = 2.5
local WALL_MIN_HEIGHT = 5 -- minimum height from ground to allow wall slide

local WallSlide = {}
WallSlide.__index = WallSlide

function WallSlide.new(state)
    local self = setmetatable({}, WallSlide)
    self._state = state
    self._bodyVelocity = nil
    self._wallNormal = Vector3.zero
    return self
end

function WallSlide:GetWallNormal(): Vector3
    return self._wallNormal
end

function WallSlide:CanActivate(): boolean
    local s = self._state
    if not s.humanoid or s.isGrounded or s.isSliding or s.isDashing then
        return false
    end

    -- Must be falling (negative Y velocity)
    if s.rootPart.AssemblyLinearVelocity.Y > 0 then
        return false
    end

    -- Must be high enough off the ground
    if not self:_isHighEnough() then
        return false
    end

    -- Must be pressing into a wall
    local wallNormal = self:_detectWall()
    if not wallNormal then
        return false
    end

    return true
end

function WallSlide:Activate()
    if not self:CanActivate() then return end

    local s = self._state
    s.isWallSliding = true

    -- Reset double jump so player can jump again after wall contact
    s.hasDoubleJumped = false

    self:_applyWallSlideForce()
end

function WallSlide:_detectWall(): Vector3?
    local s = self._state
    if not s.rootPart then return nil end

    local origin = s.rootPart.Position
    local moveDir = s.moveDirection

    -- If not actively moving, use the character's look direction
    if moveDir.Magnitude < 0.1 then
        moveDir = s.rootPart.CFrame.LookVector
    end
    moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
    if moveDir.Magnitude < 0.01 then return nil end
    moveDir = moveDir.Unit

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { s.character }

    local result = workspace:Raycast(origin, moveDir * WALL_DETECT_DISTANCE, rayParams)
    if result and result.Normal then
        -- Wall normal should be mostly horizontal
        local normal = result.Normal
        if math.abs(normal.Y) < 0.3 then
            self._wallNormal = normal
            return normal
        end
    end

    return nil
end

function WallSlide:_isHighEnough(): boolean
    local s = self._state
    if not s.rootPart then return false end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { s.character }

    local origin = s.rootPart.Position
    local result = workspace:Raycast(origin, Vector3.new(0, -WALL_MIN_HEIGHT, 0), rayParams)

    -- If no ground hit within WALL_MIN_HEIGHT, we're high enough
    return result == nil
end

function WallSlide:_applyWallSlideForce()
    local s = self._state
    if not s.rootPart then return end

    self:_removeWallSlideForce()

    -- Clamp downward velocity to WallSlideSpeed
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, 30000, 0) -- only control vertical axis
    bv.Velocity = Vector3.new(0, -GameConfig.Movement.WallSlideSpeed, 0)
    bv.Parent = s.rootPart
    self._bodyVelocity = bv
end

function WallSlide:_removeWallSlideForce()
    if self._bodyVelocity then
        self._bodyVelocity:Destroy()
        self._bodyVelocity = nil
    end
end

function WallSlide:Cancel()
    self._state.isWallSliding = false
    self._wallNormal = Vector3.zero
    self:_removeWallSlideForce()
end

function WallSlide:Update(dt: number)
    local s = self._state

    if not s.isWallSliding then
        -- Check if we should auto-activate (pressing into wall while falling)
        if self:CanActivate() then
            self:Activate()
        end
        return
    end

    -- Cancel if grounded, or no longer pressing into wall
    if s.isGrounded then
        self:Cancel()
        return
    end

    local wallNormal = self:_detectWall()
    if not wallNormal then
        self:Cancel()
        return
    end
end

function WallSlide:Destroy()
    self:_removeWallSlideForce()
end

return WallSlide
