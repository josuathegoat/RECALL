--[[
    RECALL — Double Jump Module
    Grants one extra jump while airborne.
    Chains: Can trigger after Slide launch, Wall Bounce, or normal jump.
           Resets on landing. Wall Bounce also resets this via shared state.
           Air Dash can follow.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local DoubleJump = {}
DoubleJump.__index = DoubleJump

function DoubleJump.new(state)
    local self = setmetatable({}, DoubleJump)
    self._state = state
    self._wasGrounded = true
    return self
end

function DoubleJump:CanActivate(): boolean
    local s = self._state
    return s.humanoid
        and not s.isGrounded
        and not s.hasDoubleJumped -- uses SHARED state so wall bounce reset flows through
        and not s.isWallSliding
end

function DoubleJump:Activate()
    local s = self._state
    if not self:CanActivate() then return end

    s.hasDoubleJumped = true

    -- Apply upward impulse
    local rootPart = s.rootPart
    if not rootPart then return end

    -- Zero out current vertical velocity then apply jump force
    local currentVel = rootPart.AssemblyLinearVelocity
    rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, 0, currentVel.Z)

    local jumpImpulse = Vector3.new(0, GameConfig.Movement.DoubleJumpPower, 0)
    rootPart:ApplyImpulse(jumpImpulse * rootPart.AssemblyMass)
    print("DOUBLE JUMP - applied impulse:", GameConfig.Movement.DoubleJumpPower)
end

function DoubleJump:Update(dt: number)
    local s = self._state

    -- Reset double jump when landing
    if s.isGrounded and not self._wasGrounded then
        s.hasDoubleJumped = false
    end

    self._wasGrounded = s.isGrounded
end

function DoubleJump:Destroy()
    -- No cleanup needed
end

return DoubleJump
