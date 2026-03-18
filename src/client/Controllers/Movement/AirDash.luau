--[[
    RECALL — Air Dash Module
    A short, fast burst of horizontal movement while airborne.
    Chains: Can trigger after DoubleJump, Wall Bounce, or any airborne state.
           One dash per airborne phase; resets on landing.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local AirDash = {}
AirDash.__index = AirDash

function AirDash.new(state)
    local self = setmetatable({}, AirDash)
    self._state = state
    self._hasDashed = false
    self._dashTimer = 0
    self._dashDirection = Vector3.zero
    self._bodyVelocity = nil
    self._cooldownTimer = 0
    self._wasGrounded = true
    return self
end

function AirDash:CanActivate(): boolean
    local s = self._state
    return s.humanoid
        and not s.isGrounded
        and not self._hasDashed
        and not s.isDashing
        and not s.isSliding
        and self._cooldownTimer <= 0
end

function AirDash:Activate()
    local s = self._state
    if not self:CanActivate() then return end

    self._hasDashed = true
    s.isDashing = true
    self._dashTimer = GameConfig.Movement.DashDuration

    -- Dash in the direction the player is moving, or camera forward if stationary
    if s.moveDirection.Magnitude > 0 then
        self._dashDirection = s.moveDirection.Unit
    else
        self._dashDirection = s.rootPart.CFrame.LookVector
    end
    self._dashDirection = Vector3.new(self._dashDirection.X, 0, self._dashDirection.Z).Unit

    self:_applyDashForce()
end

function AirDash:_applyDashForce()
    local s = self._state
    if not s.rootPart then return end

    self:_removeDashForce()

    -- Freeze vertical velocity during dash for a crisp horizontal burst
    local currentVel = s.rootPart.AssemblyLinearVelocity
    s.rootPart.AssemblyLinearVelocity = Vector3.new(currentVel.X, 0, currentVel.Z)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(50000, 50000, 50000)
    bv.Velocity = self._dashDirection * GameConfig.Movement.DashSpeed
    bv.Parent = s.rootPart
    self._bodyVelocity = bv
end

function AirDash:_removeDashForce()
    if self._bodyVelocity then
        self._bodyVelocity:Destroy()
        self._bodyVelocity = nil
    end
end

function AirDash:Update(dt: number)
    local s = self._state

    -- Tick cooldown
    if self._cooldownTimer > 0 then
        self._cooldownTimer = math.max(0, self._cooldownTimer - dt)
    end

    -- Reset on landing
    if s.isGrounded and not self._wasGrounded then
        self._hasDashed = false
        s.isDashing = false
        self:_removeDashForce()
    end
    self._wasGrounded = s.isGrounded

    if not s.isDashing then return end

    self._dashTimer -= dt
    if self._dashTimer <= 0 then
        s.isDashing = false
        self._cooldownTimer = GameConfig.Movement.DashCooldown
        self:_removeDashForce()
    end
end

function AirDash:Destroy()
    self:_removeDashForce()
end

return AirDash
