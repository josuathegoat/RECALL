--[[
    RECALL — Crosshair Controller
    Creates a simple white dot crosshair at screen center.
]]

local Players = game:GetService("Players")

local CrosshairController = {}
CrosshairController.__index = CrosshairController

function CrosshairController.new()
    local self = setmetatable({}, CrosshairController)
    self._gui = nil
    return self
end

function CrosshairController:Start()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CrosshairGui"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 10
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local dot = Instance.new("Frame")
    dot.Name = "Crosshair"
    dot.Size = UDim2.fromOffset(4, 4)
    dot.Position = UDim2.fromScale(0.5, 0.5)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.BorderSizePixel = 0
    dot.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot

    self._gui = screenGui
end

function CrosshairController:Destroy()
    if self._gui then
        self._gui:Destroy()
        self._gui = nil
    end
end

return CrosshairController
