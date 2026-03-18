--[[
    RECALL — Wall Bounce Module
    Jump off a wall while wall sliding for a powerful directional launch.
    Chains: Wall Bounce -> DoubleJump, Wall Bounce -> AirDash.
           Launches player away from the wall and upward.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local WallBounce = {}
WallBounce.__index = WallBounce

function WallBounce.new(state, wallSlideModule)
    local self = setmetatable({}, WallBounce)
    self._state = state
    self._wallSlide = wallSlideModule
    return self
end

function WallBounce:CanActivate(): boolean
    local s = self._state
    return s.humanoid
        and s.isWallSliding
        and self._wallSlide:GetWallNormal().Magnitude > 0
end

local UPWARD_MULTIPLIER = 1.8

function WallBounce:Activate()
    local s = self._state
    if not self:CanActivate() then return end

    local wallNormal = self._wallSlide:GetWallNormal()

    -- Cancel wall slide first
    self._wallSlide:Cancel()

    -- Reset double jump so the player can chain: wall bounce > double jump > air dash
    s.hasDoubleJumped = false

    local rootPart = s.rootPart
    if not rootPart then return end

    -- BO3-style: launch direction is based on player's WASD input, not just wall normal.
    -- Wall normal is only a fallback when there's no directional input.
    local bounceForce = GameConfig.Movement.WallBounceForce
    local horizontalDir

    if s.moveDirection.Magnitude > 0.1 then
        -- Player is pressing a direction — use it as the horizontal launch direction
        horizontalDir = Vector3.new(s.moveDirection.X, 0, s.moveDirection.Z).Unit
    else
        -- No input — fall back to wall normal (perpendicular away from wall)
        horizontalDir = Vector3.new(wallNormal.X, 0, wallNormal.Z).Unit
    end

    -- Combine horizontal direction with strong upward component
    -- The upward multiplier makes it feel like a powerful parkour leap
    local launchDir = (horizontalDir + Vector3.new(0, UPWARD_MULTIPLIER, 0)).Unit
    local impulse = launchDir * bounceForce

    -- Zero current velocity for a clean, powerful launch
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart:ApplyImpulse(impulse * rootPart.AssemblyMass)
end

function WallBounce:Update(_dt: number)
    -- Wall Bounce is instantaneous; no per-frame logic needed.
    -- Activation is handled by input (jump while wall sliding).
end

function WallBounce:Destroy()
    -- No cleanup needed
end

return WallBounce
