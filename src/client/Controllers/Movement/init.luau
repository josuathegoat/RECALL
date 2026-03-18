--[[
    RECALL — Movement Controller (Orchestrator)
    Manages all advanced movement modules and shared state.
    Handles input routing so mechanics chain fluidly:

    Chain map:
      Sprint + Crouch  ->  Slide
      Slide + Jump     ->  Boosted launch into air
      Air + Jump       ->  Double Jump
      Air + Q          ->  Air Dash
      Falling + Wall   ->  Wall Slide (auto)
      Wall Slide + Jump -> Wall Bounce -> DoubleJump / AirDash
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

    -- C key: Slide if sprinting + moving, otherwise handled by FPSController as crouch
    if input.KeyCode == Enum.KeyCode.C then
        if s.isSprinting and s.isGrounded and s.moveDirection.Magnitude > 0 then
            self._slide:Activate()
            return
        end
    end

    -- Space: Wall Bounce (if wall sliding) or Double Jump (if airborne)
    if input.KeyCode == Enum.KeyCode.Space then
        if s.isWallSliding then
            self._wallBounce:Activate()
            return
        end

        -- Cancel slide on jump for a boosted launch
        if s.isSliding then
            self._slide:Cancel()
        end

        if not s.isGrounded then
            self._doubleJump:Activate()
            return
        end
    end

    -- Q: Air Dash
    if input.KeyCode == Enum.KeyCode.Q then
        self._airDash:Activate()
        return
    end
end

--- Returns true if the player is currently sliding (so FPSController can adjust speed/crouch)
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
