--!strict

local Formatters = {}

function Formatters.formatClock(totalSeconds: number): string
    local safeSeconds = math.max(0, math.floor(totalSeconds))
    local minutes = math.floor(safeSeconds / 60)
    local seconds = safeSeconds % 60

    return string.format("%02d:%02d", minutes, seconds)
end

function Formatters.formatCoins(totalCoins: number): string
    return string.format("%d", math.max(0, math.floor(totalCoins)))
end

function Formatters.formatDuration(totalSeconds: number): string
    return string.format("%.1fs", math.max(0, totalSeconds))
end

return Formatters
