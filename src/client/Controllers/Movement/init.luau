--[[
    RECALL — Movement Controller (Orchestrator)
    Manages all advanced movement modules and shared state.
    Handles input routing so mechanics chain fluidly:

    Chain map:
      Sprint + C (ground)    ->  Slide
      Slide + Jump           ->  Boosted launch into air
      Air + Space            ->  Double Jump
      Air + LeftShift        ->  Air Dash
      Falling + Wall         ->  Wall Slide (auto)
      Wall Slide + Space     ->  Wall Bounce (resets double jump)
      Wall Bounce + Space    ->  Double Jump
      Wall Bounce + Shift    ->  Air Dash
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local Slide = require(script.Slide)
local DoubleJump = require(script.DoubleJump)
local AirDash = require(script.AirDash)
local WallSlide = require(script.WallSlide)
local WallBounce = require(script.WallBounce)

local GROUND_RAYCAST_DISTANCE = 3.5

local MovementController = {}
MovementController.__index = MovementController

function MovementController.new()
    local self = setmetatable({}, MovementController)

    self._player = Players.LocalPlayer

    -- Shared state table passed to all modules
    self._state = {
        -- References (set on character setup)
        character = nil,
        humanoid = nil,
        rootPart = nil,

        -- Ground detection
        isGrounded = true,

        -- States from FPSController
        isSprinting = false,
        isCrouching = false,
        moveDirection = Vector3.zero, -- world-space move direction

        -- Advanced movement states
        isSliding = false,
        isDashing = false,
        isWallSliding = false,
        hasDoubleJumped = false,
    }

    -- Create modules with shared state
    self._slide = Slide.new(self._state)
    self._doubleJump = DoubleJump.new(self._state)
    self._airDash = AirDash.new(self._state)
    self._wallSlide = WallSlide.new(self._state)
    self._wallBounce = WallBounce.new(self._state, self._wallSlide)

    self._connections = {}

    return self
end

function MovementController:Start()
    self:_bindInput()
end

--- Called by FPSController when character spawns/respawns
function MovementController:SetupCharacter(character: Model, humanoid: Humanoid, rootPart: BasePart)
    self._state.character = character
    self._state.humanoid = humanoid
    self._state.rootPart = rootPart

    -- Reset all states
    self._state.isGrounded = true
    self._state.isSliding = false
    self._state.isDashing = false
    self._state.isWallSliding = false
    self._state.hasDoubleJumped = false
end

--- Called every frame by FPSController._update()
function MovementController:Update(dt: number, isSprinting: boolean, isCrouching: boolean, moveDirection: Vector3)
    local s = self._state
    if not s.humanoid or not s.rootPart then return end

    -- Sync state from FPSController
    s.isSprinting = isSprinting
    s.isCrouching = isCrouching
    s.moveDirection = moveDirection

    -- Ground detection
    s.isGrounded = self:_checkGrounded()

    -- Update all modules (order matters for chaining)
    self._wallSlide:Update(dt) -- auto-activates when conditions met
    self._slide:Update(dt)
    self._doubleJump:Update(dt)
    self._airDash:Update(dt)
    self._wallBounce:Update(dt)
end

function MovementController:_checkGrounded(): boolean
    local s = self._state
    if not s.rootPart then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { s.character }

    local origin = s.rootPart.Position
    local result = workspace:Raycast(origin, Vector3.new(0, -GROUND_RAYCAST_DISTANCE, 0), rayParams)
    return result ~= nil
end

function MovementController:_bindInput()
    self._connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        self:_onInputBegan(input)
    end)
end

function MovementController:_onInputBegan(input: InputObject)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local s = self._state
    if not s.humanoid or not s.rootPart then return end

    -- Space: Wall Bounce (if wall sliding) or Double Jump (if airborne)
    if input.KeyCode == Enum.KeyCode.Space then
        print("SPACE PRESSED - airborne:", not s.isGrounded, "wallSliding:", s.isWallSliding, "hasDoubleJumped:", s.hasDoubleJumped)
        if s.isWallSliding then
            print("  -> Activating WALL BOUNCE")
            self._wallBounce:Activate()
            return
        end

        -- Cancel slide on jump for a boosted launch
        if s.isSliding then
            self._slide:Cancel()
        end

        if not s.isGrounded then
            print("  -> Activating DOUBLE JUMP")
            self._doubleJump:Activate()
            return
        end
    end
end

--- Called by FPSController when C is pressed while sprinting.
--- Directly activates slide without the CanActivate double-check race.
function MovementController:ForceSlide(worldMoveDir: Vector3)
    local s = self._state
    if not s.humanoid or not s.rootPart then return end

    -- Refresh ground state NOW (don't rely on last frame's value)
    s.isGrounded = self:_checkGrounded()

    print("FORCE SLIDE - onGround:", s.isGrounded, "sliding:", s.isSliding, "onCooldown:", self._slide._cooldownTimer > 0, "moveDir:", worldMoveDir)

    if not s.isGrounded then return end
    if s.isSliding then return end
    if self._slide._cooldownTimer > 0 then return end

    -- Set shared state to match what Slide expects, then activate
    s.isSprinting = true
    s.moveDirection = worldMoveDir
    self._slide:Activate()
    print("  -> Slide ACTIVATED:", s.isSliding)
end

--- Called by FPSController when LeftShift is pressed while airborne.
function MovementController:TryAirDash(worldMoveDir: Vector3)
    local s = self._state
    if not s.humanoid or not s.rootPart then return end

    -- Update move direction for the dash
    s.moveDirection = worldMoveDir
    self._airDash:Activate()
end

--- Returns current grounded state
function MovementController:IsGrounded(): boolean
    return self._state.isGrounded
end

--- Returns true if the player is currently sliding
function MovementController:IsSliding(): boolean
    return self._state.isSliding
end

--- Returns true if the player is dashing
function MovementController:IsDashing(): boolean
    return self._state.isDashing
end

--- Returns true if wall sliding
function MovementController:IsWallSliding(): boolean
    return self._state.isWallSliding
end

function MovementController:Destroy()
    for _, connection in self._connections do
        connection:Disconnect()
    end
    self._connections = {}

    self._slide:Destroy()
    self._doubleJump:Destroy()
    self._airDash:Destroy()
    self._wallSlide:Destroy()
    self._wallBounce:Destroy()
end

return MovementController
