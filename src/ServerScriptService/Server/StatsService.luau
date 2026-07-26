--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)
local Leaderstats = require(script.Parent.Leaderstats)

type PlayerState = {
    active: boolean,
    characterConnection: RBXScriptConnection?,
    humanoidConnection: RBXScriptConnection?,
}

local StatsService = {}
local playerStates: { [Player]: PlayerState } = {}

local function disconnect(connection: RBXScriptConnection?)
    if connection then
        connection:Disconnect()
    end
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

local function trackCharacter(player: Player, state: PlayerState, character: Model)
    local humanoid = getHumanoid(character)

    if not humanoid or playerStates[player] ~= state or not state.active then
        return
    end

    disconnect(state.humanoidConnection)

    local jumps = Leaderstats.getStat(player, "Jumps")
    local lastJumpAt = 0

    state.humanoidConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState ~= Enum.HumanoidStateType.Jumping then
            return
        end

        local now = os.clock()

        if now - lastJumpAt < 0.2 then
            return
        end

        lastJumpAt = now
        jumps.Value += 1
    end)
end

local function startSessionLoop(player: Player, state: PlayerState)
    local timePlayed = Leaderstats.getStat(player, "TimePlayed")
    local coins = Leaderstats.getStat(player, "Coins")

    task.spawn(function()
        while state.active and playerStates[player] == state and player.Parent ~= nil do
            task.wait(1)

            if not state.active or playerStates[player] ~= state or player.Parent == nil then
                break
            end

            timePlayed.Value += 1
            coins.Value += Shared.EconomyRules.getPassiveCoinReward(timePlayed.Value)
        end
    end)
end

function StatsService.startPlayer(player: Player)
    if playerStates[player] then
        return
    end

    Leaderstats.ensure(player)

    local state: PlayerState = {
        active = true,
        characterConnection = nil,
        humanoidConnection = nil,
    }

    playerStates[player] = state
    state.characterConnection = player.CharacterAdded:Connect(function(character)
        task.spawn(trackCharacter, player, state, character)
    end)

    if player.Character then
        task.spawn(trackCharacter, player, state, player.Character)
    end

    startSessionLoop(player, state)
end

function StatsService.stopPlayer(player: Player)
    local state = playerStates[player]

    if not state then
        return
    end

    state.active = false
    disconnect(state.characterConnection)
    disconnect(state.humanoidConnection)
    playerStates[player] = nil
end

function StatsService.awardCoins(player: Player, amount: number)
    local coins = Leaderstats.getStat(player, "Coins")
    coins.Value += math.floor(amount)
end

function StatsService.getCoinsValue(player: Player): IntValue
    return Leaderstats.getStat(player, "Coins")
end

function StatsService.isTracking(player: Player): boolean
    return playerStates[player] ~= nil
end

return StatsService
