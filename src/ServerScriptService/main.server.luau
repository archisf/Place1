local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)

print("[Server]", Shared.getGreeting())

local function ensureLeaderstats(player: Player)
    local leaderstats = player:FindFirstChild("leaderstats")

    if leaderstats then
        return leaderstats
    end

    leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local timePlayed = Instance.new("IntValue")
    timePlayed.Name = "TimePlayed"
    timePlayed.Parent = leaderstats

    local jumps = Instance.new("IntValue")
    jumps.Name = "Jumps"
    jumps.Parent = leaderstats

    return leaderstats
end

local function trackCharacter(player: Player, character: Model)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
    local leaderstats = ensureLeaderstats(player)
    local jumps = leaderstats:WaitForChild("Jumps") :: IntValue
    local lastJumpTick = 0

    humanoid.StateChanged:Connect(function(_, newState)
        if newState ~= Enum.HumanoidStateType.Jumping then
            return
        end

        local now = os.clock()

        -- Debounce quick repeat state changes so one jump does not count multiple times.
        if now - lastJumpTick < 0.2 then
            return
        end

        lastJumpTick = now
        jumps.Value += 1
    end)
end

Players.PlayerAdded:Connect(function(player)
    local leaderstats = ensureLeaderstats(player)
    local timePlayed = leaderstats:WaitForChild("TimePlayed") :: IntValue

    task.spawn(function()
        while player.Parent do
            task.wait(1)
            timePlayed.Value += 1
        end
    end)

    player.CharacterAdded:Connect(function(character)
        trackCharacter(player, character)
    end)

    if player.Character then
        trackCharacter(player, player.Character)
    end
end)

for _, player in Players:GetPlayers() do
    task.spawn(function()
        local leaderstats = ensureLeaderstats(player)
        local timePlayed = leaderstats:WaitForChild("TimePlayed") :: IntValue

        task.spawn(function()
            while player.Parent do
                task.wait(1)
                timePlayed.Value += 1
            end
        end)

        player.CharacterAdded:Connect(function(character)
            trackCharacter(player, character)
        end)

        if player.Character then
            trackCharacter(player, player.Character)
        end
    end)
end
