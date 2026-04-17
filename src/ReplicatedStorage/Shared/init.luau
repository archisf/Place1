local Shared = {}

function Shared.getGreeting(): string
    return "Place1 shared module loaded"
end

Shared.SessionStats = {
    HudTitle = "Session Stats",
    MilestoneSeconds = 30,
    CoinRewardSeconds = 15,
    CoinRewardAmount = 5,
    PickupCoinReward = 10,
    PickupRespawnSeconds = 8,
    SpeedBoostCost = 20,
    SpeedBoostDuration = 12,
    DefaultWalkSpeed = 16,
    BoostWalkSpeed = 26,
}

function Shared.formatClock(totalSeconds: number): string
    local safeSeconds = math.max(0, math.floor(totalSeconds))
    local minutes = math.floor(safeSeconds / 60)
    local seconds = safeSeconds % 60

    return string.format("%02d:%02d", minutes, seconds)
end

function Shared.formatCoins(totalCoins: number): string
    return string.format("%d", math.max(0, math.floor(totalCoins)))
end

function Shared.formatDuration(totalSeconds: number): string
    return string.format("%.1fs", math.max(0, totalSeconds))
end

return Shared
