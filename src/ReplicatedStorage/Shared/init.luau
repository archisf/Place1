--!strict

local Config = require(script.Config)
local EconomyRules = require(script.EconomyRules)
local Formatters = require(script.Formatters)
local HudViewModel = require(script.HudViewModel)

local Shared = {
    -- Preserve the original facade so scripts stored in the legacy place keep working.
    SessionStats = Config,
    EconomyRules = EconomyRules,
    HudViewModel = HudViewModel,
}

function Shared.getGreeting(): string
    return "Place1 shared module loaded"
end

Shared.formatClock = Formatters.formatClock
Shared.formatCoins = Formatters.formatCoins
Shared.formatDuration = Formatters.formatDuration

return table.freeze(Shared)
