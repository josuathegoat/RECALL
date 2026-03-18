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

function WallBounce:Activate()
    local s = self._state
    if not self:CanActivate() then return end

    local wallNormal = self._wallSlide:GetWallNormal()

    -- Cancel wall slide first
    self._wallSlide:Cancel()

    -- Reset double jump so the player can chain another jump after bouncing
    s.hasDoubleJumped = false

    -- Launch: outward from wall + upward
    local bounceForce = GameConfig.Movement.WallBounceForce
    local launchDir = (wallNormal * 0.7 + Vector3.new(0, 0.7, 0)).Unit
    local impulse = launchDir * bounceForce

    local rootPart = s.rootPart
    if not rootPart then return end

    -- Zero current velocity for a clean launch
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
