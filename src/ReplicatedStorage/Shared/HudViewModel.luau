--!strict

local Config = require(script.Parent.Config)
local Formatters = require(script.Parent.Formatters)
local Types = require(script.Parent.Types)

local HudViewModel = {}

function HudViewModel.getBoostUi(
    isActive: boolean,
    expiresAt: number?,
    now: number,
    requestInFlight: boolean
): Types.BoostUiModel
    if isActive and expiresAt ~= nil and expiresAt > 0 then
        local remaining = math.max(0, expiresAt - now)

        return {
            statusText = string.format(
                "Boost active: +%d speed for %s",
                Config.BoostWalkSpeed - Config.DefaultWalkSpeed,
                Formatters.formatDuration(remaining)
            ),
            buttonText = "Boost Active",
            buttonColor = Color3.fromRGB(8, 145, 178),
            autoButtonColor = false,
            buttonActive = false,
        }
    end

    return {
        statusText = string.format(
            "Buy speed boost: %d coins for %ds",
            Config.SpeedBoostCost,
            Config.SpeedBoostDuration
        ),
        buttonText = if requestInFlight then "Buying..." else "Use Speed Boost",
        buttonColor = Color3.fromRGB(37, 99, 235),
        autoButtonColor = not requestInFlight,
        buttonActive = not requestInFlight,
    }
end

function HudViewModel.getPurchaseFeedback(
    callSucceeded: boolean,
    purchaseSucceeded: boolean?,
    message: string?
): string
    if not callSucceeded then
        return "Boost purchase failed. Try again."
    end

    if message == nil then
        return if purchaseSucceeded then "Speed boost purchased." else "Boost purchase rejected."
    end

    return message
end

return HudViewModel
