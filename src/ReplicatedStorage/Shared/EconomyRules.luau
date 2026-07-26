--!strict

local Config = require(script.Parent.Config)
local Types = require(script.Parent.Types)

local EconomyRules = {}

function EconomyRules.getPassiveCoinReward(timePlayed: number): number
    local safeTimePlayed = math.max(0, math.floor(timePlayed))

    if safeTimePlayed == 0 or safeTimePlayed % Config.CoinRewardSeconds ~= 0 then
        return 0
    end

    return Config.CoinRewardAmount
end

function EconomyRules.evaluateSpeedBoostPurchase(
    coins: number,
    isBoostActive: boolean
): Types.SpeedBoostDecision
    local safeCoins = math.max(0, math.floor(coins))

    if isBoostActive then
        return {
            succeeded = false,
            remainingCoins = safeCoins,
            message = "Speed boost already active.",
        }
    end

    if safeCoins < Config.SpeedBoostCost then
        return {
            succeeded = false,
            remainingCoins = safeCoins,
            message = string.format("Need %d coins for boost.", Config.SpeedBoostCost),
        }
    end

    return {
        succeeded = true,
        remainingCoins = safeCoins - Config.SpeedBoostCost,
        message = string.format("Speed boost active for %d seconds.", Config.SpeedBoostDuration),
    }
end

function EconomyRules.canProcessBoostRequest(lastRequestAt: number?, now: number): boolean
    return lastRequestAt == nil or now - lastRequestAt >= Config.SpeedBoostRequestCooldownSeconds
end

function EconomyRules.canCollectPickup(lastTouchAt: number?, now: number): boolean
    return lastTouchAt == nil or now - lastTouchAt >= Config.PickupTouchDebounceSeconds
end

return EconomyRules
