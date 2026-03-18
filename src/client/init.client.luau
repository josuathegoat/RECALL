--[[
    RECALL — Client Entry Point
    Initializes all client-side controllers.

    NOTE: Knit framework disabled until Comm/Signal packages are added.
    Controllers are loaded directly for now.
]]

local FPSController = require(script.Controllers.FPSController)
local CrosshairController = require(script.Controllers.CrosshairController)

-- Initialize controllers
local fps = FPSController.new()
local crosshair = CrosshairController.new()

fps:Start()
crosshair:Start()

print("[RECALL Client] All controllers started.")
