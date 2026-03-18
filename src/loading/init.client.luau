--[[
    RECALL — Loading Screen
    Runs in ReplicatedFirst to show a loading screen while the game loads.
]]

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

-- Remove default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create a simple loading screen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LoadingScreen"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.6, 0.1)
title.Position = UDim2.fromScale(0.2, 0.4)
title.BackgroundTransparency = 1
title.Text = "RECALL"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromScale(0.4, 0.04)
subtitle.Position = UDim2.fromScale(0.3, 0.52)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Every memory fights back."
subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.GothamMedium
subtitle.Parent = frame

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Fade out
task.wait(1)
for i = 0, 1, 0.02 do
    frame.BackgroundTransparency = i
    title.TextTransparency = i
    subtitle.TextTransparency = i
    task.wait(0.016)
end

screenGui:Destroy()
