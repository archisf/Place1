--!strict

export type State = {
    expiresAt: number,
    token: number,
}

local BoostState = {}

function BoostState.create(now: number, duration: number, token: number): State
    return {
        expiresAt = now + duration,
        token = token,
    }
end

function BoostState.isActive(state: State?, now: number): boolean
    return state ~= nil and state.expiresAt > now
end

function BoostState.getRemaining(state: State, now: number): number
    return math.max(0, state.expiresAt - now)
end

return BoostState
