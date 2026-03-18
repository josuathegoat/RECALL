--[[
    RECALL — FPS Controller
    Handles first-person camera, mouse look, movement (WASD/sprint/crouch/jump).
    All values reference shared GameConfig.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local MovementController = require(script.Parent.Movement)

local FPSController = {}
FPSController.__index = FPSController

function FPSController.new()
    local self = setmetatable({}, FPSController)

    self._player = Players.LocalPlayer
    self._camera = workspace.CurrentCamera
    self._character = nil
    self._humanoid = nil
    self._rootPart = nil

    -- Camera state
    self._yaw = 0
    self._pitch = 0
    self._sensitivity = GameConfig.Camera.Sensitivity
    self._currentCameraOffset = GameConfig.Camera.StandingCameraOffset

    -- Movement state
    self._isSprinting = false
    self._isCrouching = false
    self._moveDirection = Vector3.zero

    -- Input tracking
    self._keysDown = {}

    -- Advanced movement
    self._movement = MovementController.new()

    -- Connections
    self._connections = {}

    return self
end

function FPSController:Start()
    self:_setupCharacter()
    self:_bindInput()
    self:_bindRenderStep()

    -- Start advanced movement system
    self._movement:Start()

    -- Handle respawns
    self._connections.characterAdded = self._player.CharacterAdded:Connect(function()
        self:_setupCharacter()
    end)
end

function FPSController:_setupCharacter()
    local character = self._player.Character or self._player.CharacterAdded:Wait()
    self._character = character
    self._humanoid = character:WaitForChild("Humanoid")
    self._rootPart = character:WaitForChild("HumanoidRootPart")

    -- Force first person
    self._player.CameraMode = Enum.CameraMode.Classic
    self._camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    -- Set base walk speed
    self._humanoid.WalkSpeed = GameConfig.Movement.BaseWalkSpeed

    -- Reset camera angles to face character's direction
    local currentCFrame = self._rootPart.CFrame
    local _, yaw, _ = currentCFrame:ToEulerAnglesYXZ()
    self._yaw = math.deg(yaw)
    self._pitch = 0

    -- Reset states
    self._isSprinting = false
    self._isCrouching = false
    self._currentCameraOffset = GameConfig.Camera.StandingCameraOffset

    -- Setup advanced movement for this character
    self._movement:SetupCharacter(character, self._humanoid, self._rootPart)

    -- Hide local character from camera (first-person invisibility)
    self:_hideCharacter(character)

    -- Handle death
    self._humanoid.Died:Connect(function()
        self._humanoid = nil
        self._rootPart = nil
    end)
end

function FPSController:_hideCharacter(character: Model)
    -- Set LocalTransparencyModifier on all BaseParts so they're invisible
    -- only to this client's camera (other players still see you)
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end

    -- Keep hiding new parts and prevent the engine from resetting the modifier
    self._connections.hideDescendantAdded = character.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end)

    self._connections.hideRenderStep = RunService.RenderStepped:Connect(function()
        for _, part in character:GetDescendants() do
            if part:IsA("BasePart") and part.LocalTransparencyModifier < 1 then
                part.LocalTransparencyModifier = 1
            end
        end
    end)
end

function FPSController:_bindInput()
    self._connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        self:_onInputBegan(input)
    end)

    self._connections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        self:_onInputEnded(input)
    end)
end

function FPSController:_onInputBegan(input: InputObject)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        self._keysDown[input.KeyCode] = true

        if input.KeyCode == Enum.KeyCode.LeftShift then
            self:_startSprint()
        elseif input.KeyCode == Enum.KeyCode.C then
            -- Try slide first: pass live sprint state + move direction so the
            -- check happens BEFORE _toggleCrouch kills the sprint flag.
            local worldMoveDir = self:_getWorldMoveDirection()
            if self._movement:TrySlide(self._isSprinting, worldMoveDir) then
                -- Slide consumed the input — sync our local state to match
                self._isSprinting = false
                self._isCrouching = true
                self:_updateWalkSpeed()
            else
                self:_toggleCrouch()
            end
        end
    end
end

--- Compute camera-relative world move direction from current WASD keys
function FPSController:_getWorldMoveDirection(): Vector3
    local moveVector = self:_getMoveVector()
    if moveVector.Magnitude == 0 then
        return Vector3.zero
    end
    local cameraYawCFrame = CFrame.fromEulerAnglesYXZ(0, math.rad(self._yaw), 0)
    local worldMove = cameraYawCFrame:VectorToWorldSpace(moveVector)
    return Vector3.new(worldMove.X, 0, worldMove.Z).Unit
end

function FPSController:_onInputEnded(input: InputObject)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        self._keysDown[input.KeyCode] = nil

        if input.KeyCode == Enum.KeyCode.LeftShift then
            self:_stopSprint()
        end
    end
end

function FPSController:_startSprint()
    if self._isCrouching then
        self:_toggleCrouch()
    end
    self._isSprinting = true
    self:_updateWalkSpeed()
end

function FPSController:_stopSprint()
    self._isSprinting = false
    self:_updateWalkSpeed()
end

function FPSController:_toggleCrouch()
    self._isCrouching = not self._isCrouching
    if self._isCrouching and self._isSprinting then
        self._isSprinting = false
    end
    self:_updateWalkSpeed()
end

function FPSController:_updateWalkSpeed()
    if not self._humanoid then return end

    -- During slide or dash, modules control velocity directly via BodyVelocity
    if self._movement:IsSliding() or self._movement:IsDashing() then
        return
    end

    local speed = GameConfig.Movement.BaseWalkSpeed
    if self._isSprinting then
        speed = speed * GameConfig.Movement.SprintMultiplier
    elseif self._isCrouching then
        speed = speed * GameConfig.Movement.CrouchMultiplier
    end
    self._humanoid.WalkSpeed = speed
end

function FPSController:_getMoveVector(): Vector3
    local forward = self._keysDown[Enum.KeyCode.W] and 1 or 0
    local backward = self._keysDown[Enum.KeyCode.S] and 1 or 0
    local left = self._keysDown[Enum.KeyCode.A] and 1 or 0
    local right = self._keysDown[Enum.KeyCode.D] and 1 or 0

    local moveX = right - left
    local moveZ = backward - forward -- negative Z is forward in Roblox

    if moveX == 0 and moveZ == 0 then
        return Vector3.zero
    end

    return Vector3.new(moveX, 0, moveZ).Unit
end

function FPSController:_bindRenderStep()
    self._connections.renderStep = RunService.RenderStepped:Connect(function(dt)
        self:_update(dt)
    end)
end

function FPSController:_update(dt: number)
    if not self._rootPart or not self._humanoid then return end
    if self._humanoid.Health <= 0 then return end

    -- Mouse look
    local mouseDelta = UserInputService:GetMouseDelta()
    self._yaw = self._yaw - mouseDelta.X * self._sensitivity
    self._pitch = math.clamp(
        self._pitch - mouseDelta.Y * self._sensitivity,
        GameConfig.Camera.MinPitch,
        GameConfig.Camera.MaxPitch
    )

    -- Smooth crouch camera offset
    local targetOffset = if self._isCrouching
        then GameConfig.Camera.CrouchCameraOffset
        else GameConfig.Camera.StandingCameraOffset
    self._currentCameraOffset = self._currentCameraOffset:Lerp(
        targetOffset,
        math.min(1, dt * GameConfig.Camera.CrouchTransitionSpeed)
    )

    -- Build camera CFrame
    local headPosition = self._rootPart.Position + Vector3.new(0, 1.5, 0) + self._currentCameraOffset
    local cameraRotation = CFrame.fromEulerAnglesYXZ(
        math.rad(self._pitch),
        math.rad(self._yaw),
        0
    )
    self._camera.CFrame = CFrame.new(headPosition) * cameraRotation

    -- Movement relative to camera facing
    local moveVector = self:_getMoveVector()
    local worldMoveDir = Vector3.zero
    if moveVector.Magnitude > 0 then
        -- Get camera's horizontal rotation only (no pitch)
        local cameraYawCFrame = CFrame.fromEulerAnglesYXZ(0, math.rad(self._yaw), 0)
        local worldMove = cameraYawCFrame:VectorToWorldSpace(moveVector)
        worldMoveDir = Vector3.new(worldMove.X, 0, worldMove.Z).Unit
        self._humanoid:Move(worldMoveDir)
    else
        self._humanoid:Move(Vector3.zero)
    end

    -- Sync crouch state from movement controller (slide sets isCrouching)
    if self._movement:IsSliding() then
        self._isCrouching = true
    end

    -- Update advanced movement system
    self._movement:Update(dt, self._isSprinting, self._isCrouching, worldMoveDir)

    -- Keep mouse locked
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end

function FPSController:Destroy()
    for _, connection in self._connections do
        connection:Disconnect()
    end
    self._connections = {}
    self._movement:Destroy()
end

return FPSController
