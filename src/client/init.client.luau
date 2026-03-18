--[[
    RECALL — Client Entry Point
    Initializes Knit framework and all client-side Controllers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Load all Controllers (Knit auto-discovers them)
for _, module in ipairs(script.Controllers:GetChildren()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end

-- Start Knit
Knit.Start():andThen(function()
    print("[RECALL Client] All controllers started.")
end):catch(function(err)
    warn("[RECALL Client] Failed to start:", err)
end)
