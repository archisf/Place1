local Shared = {}

function Shared.getGreeting(): string
    return "Place1 shared module loaded"
end

Shared.SessionStats = {
    HudTitle = "Session Stats",
    MilestoneSeconds = 30,
}

function Shared.formatClock(totalSeconds: number): string
    local safeSeconds = math.max(0, math.floor(totalSeconds))
    local minutes = math.floor(safeSeconds / 60)
    local seconds = safeSeconds % 60

    return string.format("%02d:%02d", minutes, seconds)
end

return Shared
