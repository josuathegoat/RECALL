--[[
    RECALL — Game Configuration
    Central config for game balance, tuning values, and constants.
]]

local GameConfig = {}

-- Movement
GameConfig.Movement = {
    BaseWalkSpeed = 16,
    SprintMultiplier = 1.4,
    CrouchMultiplier = 0.6,
    SlideSpeed = 24,
    SlideDuration = 1.5,
    SlideCooldown = 2.0,
    DashSpeed = 50,
    DashDuration = 0.3,
    DashCooldown = 3.0,
    DoubleJumpPower = 35, -- 70% of normal jump
    WallSlideSpeed = 4,
    WallBounceForce = 45,
    MaxStamina = 100,
    StaminaDrainRate = 20, -- per second while sprinting
    StaminaRegenRate = 15, -- per second while not sprinting
}

-- Camera
GameConfig.Camera = {
    Sensitivity = 0.5,
    MinPitch = -80, -- degrees, looking down
    MaxPitch = 80,  -- degrees, looking up
    StandingCameraOffset = Vector3.new(0, 0, 0),
    CrouchCameraOffset = Vector3.new(0, -2, 0),
    CrouchTransitionSpeed = 10, -- lerp speed
}

-- Combat
GameConfig.Combat = {
    HeadshotMultiplier = 1.5,
    BaseDropRates = {
        HealthPack = 0.15,
        AmmoCrate = 0.10,
        SpeedBoost = 0.03,
        DamageBoost = 0.02,
        ShieldBubble = 0.01,
        WeaponDrop = 0.005,
        SkillPointCrystal = 0.003,
    },
}

-- Enemy Scaling (continuous, no waves)
GameConfig.EnemyScaling = {
    HPScalePerMinute = 0.03,       -- +3% per minute
    DamageScalePerMinute = 0.02,   -- +2% per minute
    SpawnRateScalePerMinute = 0.015, -- +1.5% per minute
    FodderOnlyEnd = 180,           -- 0-3 min (seconds)
    RangedMixStart = 180,          -- 3 min
    TankStart = 420,               -- 7 min
    EliteStart = 720,              -- 12 min
    FirstMiniboss = 1080,          -- 18 min
    FullChaos = 1500,              -- 25 min
    BossInterval = 600,            -- Boss every 10 min after 35 min
    BossStart = 2100,              -- 35 min
}

-- Progression
GameConfig.Progression = {
    MaxSkillNodesPerRun = 30,
    PrestigeMaxLevel = 10,
    PrestigeXPBonus = 0.05, -- +5% per prestige
    PrestigeLevelRequirement = 100,
}

-- Server
GameConfig.Server = {
    MaxPlayersPerServer = 16,
    MaxActiveEnemies = 200,
    TickRate = 20, -- Hz
}

return GameConfig
