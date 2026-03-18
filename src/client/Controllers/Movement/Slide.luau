--[[
    RECALL — Slide Module
    Sprint + Crouch while moving triggers a slide along the ground.
    Chains: Slide -> DoubleJump (boosted), Slide -> AirDash
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local Slide = {}
Slide.__index = Slide

function Slide.new(state)
    local self = setmetatable({}, Slide)
    self._state = state
    self._timer = 0
    self._cooldownTimer = 0
    self._bodyVelocity = nil
    return self
end

function Slide:CanActivate(): boolean
    local s = self._state
    return s.humanoid
        and s.isGrounded
        and s.isSprinting
        and not s.isSliding
        and self._cooldownTimer <= 0
        and s.moveDirection.Magnitude > 0
end

function Slide:Activate()
    local s = self._state
    if not self:CanActivate() then return end

    s.isSliding = true
    s.isCrouching = true
    s.isSprinting = false
    self._timer = GameConfig.Movement.SlideDuration

    -- Capture slide direction at activation (camera-relative move direction)
    local rootPart = s.rootPart
    self._slideDirection = rootPart.CFrame.LookVector
    if s.moveDirection.Magnitude > 0 then
        self._slideDirection = s.moveDirection.Unit
    end

    -- Apply slide velocity via BodyVelocity
    self:_applySlideForce()
end

function Slide:_applySlideForce()
    local s = self._state
    if not s.rootPart then return end

    -- Clean up old one
    self:_removeSlideForce()

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(30000, 0, 30000)
    bv.Velocity = self._slideDirection * GameConfig.Movement.SlideSpeed
    bv.Parent = s.rootPart
    self._bodyVelocity = bv
end

function Slide:_removeSlideForce()
    if self._bodyVelocity then
        self._bodyVelocity:Destroy()
        self._bodyVelocity = nil
    end
end

function Slide:Cancel()
    if not self._state.isSliding then return end
    self._state.isSliding = false
    self._state.isCrouching = false
    self._timer = 0
    self._cooldownTimer = GameConfig.Movement.SlideCooldown
    self:_removeSlideForce()
end

function Slide:Update(dt: number)
    -- Tick cooldown
    if self._cooldownTimer > 0 then
        self._cooldownTimer = math.max(0, self._cooldownTimer - dt)
    end

    if not self._state.isSliding then return end

    self._timer -= dt

    -- Decay slide velocity over duration for a smooth stop
    if self._bodyVelocity then
        local alpha = math.max(0, self._timer / GameConfig.Movement.SlideDuration)
        self._bodyVelocity.Velocity = self._slideDirection * GameConfig.Movement.SlideSpeed * alpha
    end

    -- End slide when timer expires or player leaves ground
    if self._timer <= 0 or not self._state.isGrounded then
        self:Cancel()
    end
end

function Slide:Destroy()
    self:_removeSlideForce()
end

return Slide
