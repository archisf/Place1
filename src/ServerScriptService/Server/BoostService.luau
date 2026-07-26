--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)
local BoostState = require(script.Parent.BoostState)
local StatsService = require(script.Parent.StatsService)

type ActiveBoost = {
    expiresAt: number,
    token: number,
    humanoid: Humanoid?,
    restoreWalkSpeed: number?,
}

type PlayerState = {
    boost: ActiveBoost?,
    characterConnection: RBXScriptConnection?,
    lastRequestAt: number?,
    nextToken: number,
}

local BoostService = {}
local playerStates: { [Player]: PlayerState } = {}

local function now(): number
    return workspace:GetServerTimeNow()
end

local function setBoostAttributes(player: Player, isActive: boolean, expiresAt: number?)
    player:SetAttribute("SpeedBoostActive", isActive)
    player:SetAttribute("SpeedBoostExpiresAt", expiresAt or 0)
end

local function restoreWalkSpeed(boost: ActiveBoost)
    local humanoid = boost.humanoid
    local restoreSpeed = boost.restoreWalkSpeed

    if
        humanoid
        and restoreSpeed
        and humanoid.Parent
        and humanoid.WalkSpeed == Shared.SessionStats.BoostWalkSpeed
    then
        humanoid.WalkSpeed = restoreSpeed
    end

    boost.humanoid = nil
    boost.restoreWalkSpeed = nil
end

local function clearBoost(player: Player, state: PlayerState, expectedToken: number?)
    local boost = state.boost

    if not boost or (expectedToken ~= nil and boost.token ~= expectedToken) then
        return
    end

    restoreWalkSpeed(boost)
    state.boost = nil
    setBoostAttributes(player, false, 0)
end

local function getHumanoid(character: Model): Humanoid?
    local existing = character:FindFirstChildOfClass("Humanoid")

    if existing then
        return existing
    end

    local child = character:WaitForChild("Humanoid", 10)

    if child and child:IsA("Humanoid") then
        return child
    end

    return nil
end

local function applyBoostToCharacter(player: Player, state: PlayerState, character: Model)
    local humanoid = getHumanoid(character)
    local boost = state.boost

    if not humanoid or playerStates[player] ~= state or not boost then
        return
    end

    if not BoostState.isActive(boost, now()) then
        clearBoost(player, state, boost.token)
        return
    end

    if boost.humanoid and boost.humanoid ~= humanoid then
        restoreWalkSpeed(boost)
    end

    boost.humanoid = humanoid
    boost.restoreWalkSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = Shared.SessionStats.BoostWalkSpeed
end

local function startExpiryLoop(player: Player, state: PlayerState, token: number)
    task.spawn(function()
        while playerStates[player] == state do
            local boost = state.boost

            if not boost or boost.token ~= token then
                return
            end

            local remaining = BoostState.getRemaining(boost, now())

            if remaining <= 0 then
                clearBoost(player, state, token)
                return
            end

            task.wait(math.min(remaining, 0.5))
        end
    end)
end

local function beginBoost(player: Player, state: PlayerState)
    state.nextToken += 1

    local baseState =
        BoostState.create(now(), Shared.SessionStats.SpeedBoostDuration, state.nextToken)
    local boost: ActiveBoost = {
        expiresAt = baseState.expiresAt,
        token = baseState.token,
        humanoid = nil,
        restoreWalkSpeed = nil,
    }

    state.boost = boost
    setBoostAttributes(player, true, boost.expiresAt)

    if player.Character then
        task.spawn(applyBoostToCharacter, player, state, player.Character)
    end

    startExpiryLoop(player, state, boost.token)
end

function BoostService.startPlayer(player: Player)
    if playerStates[player] then
        return
    end

    local state: PlayerState = {
        boost = nil,
        characterConnection = nil,
        lastRequestAt = nil,
        nextToken = 0,
    }

    playerStates[player] = state
    setBoostAttributes(player, false, 0)

    state.characterConnection = player.CharacterAdded:Connect(function(character)
        task.spawn(applyBoostToCharacter, player, state, character)
    end)
end

function BoostService.stopPlayer(player: Player)
    local state = playerStates[player]

    if not state then
        return
    end

    if state.characterConnection then
        state.characterConnection:Disconnect()
    end

    if state.boost then
        restoreWalkSpeed(state.boost)
    end

    state.boost = nil
    playerStates[player] = nil
    setBoostAttributes(player, false, 0)
end

function BoostService.purchase(player: Player): (boolean, string)
    local state = playerStates[player]

    if not state then
        BoostService.startPlayer(player)
        state = playerStates[player]
    end

    assert(state, "Boost state was not created")

    local requestTime = now()

    if not Shared.EconomyRules.canProcessBoostRequest(state.lastRequestAt, requestTime) then
        return false, "Please wait before trying again."
    end

    state.lastRequestAt = requestTime

    if state.boost and not BoostState.isActive(state.boost, requestTime) then
        clearBoost(player, state, state.boost.token)
    end

    local coins = StatsService.getCoinsValue(player)
    local decision = Shared.EconomyRules.evaluateSpeedBoostPurchase(
        coins.Value,
        BoostState.isActive(state.boost, requestTime)
    )

    if not decision.succeeded then
        return false, decision.message
    end

    coins.Value = decision.remainingCoins
    beginBoost(player, state)

    return true, decision.message
end

function BoostService.isTracking(player: Player): boolean
    return playerStates[player] ~= nil
end

return BoostService
