--!strict

export type SessionStatsConfig = {
    HudTitle: string,
    MilestoneSeconds: number,
    CoinRewardSeconds: number,
    CoinRewardAmount: number,
    PickupCoinReward: number,
    PickupRespawnSeconds: number,
    PickupTouchDebounceSeconds: number,
    SpeedBoostCost: number,
    SpeedBoostDuration: number,
    SpeedBoostRequestCooldownSeconds: number,
    DefaultWalkSpeed: number,
    BoostWalkSpeed: number,
}

export type SpeedBoostDecision = {
    succeeded: boolean,
    remainingCoins: number,
    message: string,
}

export type BoostUiModel = {
    statusText: string,
    buttonText: string,
    buttonColor: Color3,
    autoButtonColor: boolean,
    buttonActive: boolean,
}

return {}
