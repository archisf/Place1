--!strict

local Types = require(script.Parent.Types)

local SessionStats: Types.SessionStatsConfig = {
    HudTitle = "Session Stats",
    MilestoneSeconds = 30,
    CoinRewardSeconds = 15,
    CoinRewardAmount = 5,
    PickupCoinReward = 10,
    PickupRespawnSeconds = 8,
    PickupTouchDebounceSeconds = 0.75,
    SpeedBoostCost = 20,
    SpeedBoostDuration = 12,
    SpeedBoostRequestCooldownSeconds = 0.25,
    DefaultWalkSpeed = 16,
    BoostWalkSpeed = 26,
}

return table.freeze(SessionStats)
