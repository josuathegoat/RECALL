--[[
    RECALL — Server Entry Point
    Initializes Knit framework and all server-side Services.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Load all Services (Knit auto-discovers them)
for _, module in ipairs(script.Services:GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end

-- Start Knit
Knit.Start():andThen(function()
    print("[RECALL Server] All services started.")
end):catch(function(err)
    warn("[RECALL Server] Failed to start:", err)
end)
