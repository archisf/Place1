local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)

print("[Server]", Shared.getGreeting())

type StatFolder = Folder
type BoostState = {
    expiresAt: number,
    token: number,
}

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local purchaseSpeedBoost = remotesFolder:FindFirstChild("PurchaseSpeedBoost")

if not purchaseSpeedBoost then
    purchaseSpeedBoost = Instance.new("RemoteFunction")
    purchaseSpeedBoost.Name = "PurchaseSpeedBoost"
    purchaseSpeedBoost.Parent = remotesFolder
end

local playerBoostStates: {[Player]: BoostState} = {}
local pickupTouchDebounce: {[Player]: number} = {}

local function getHumanoidFromCharacter(character: Model): Humanoid?
    return character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("Humanoid") :: Humanoid?
end

local function setBoostAttributes(player: Player, isActive: boolean, expiresAt: number?)
    player:SetAttribute("SpeedBoostActive", isActive)
    player:SetAttribute("SpeedBoostExpiresAt", expiresAt or 0)
end

local function applyWalkSpeed(player: Player)
    local character = player.Character

    if not character then
        return
    end

    local humanoid = getHumanoidFromCharacter(character)

    if not humanoid then
        return
    end

    local boostState = playerBoostStates[player]
    local now = workspace:GetServerTimeNow()
    local isBoostActive = boostState ~= nil and boostState.expiresAt > now

    humanoid.WalkSpeed = if isBoostActive then Shared.SessionStats.BoostWalkSpeed else Shared.SessionStats.DefaultWalkSpeed
end

local function ensureLeaderstats(player: Player): StatFolder
    local leaderstats = player:FindFirstChild("leaderstats")

    if leaderstats then
        return leaderstats :: StatFolder
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

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = leaderstats

    return leaderstats :: StatFolder
end

local function awardCoins(player: Player, amount: number)
    local leaderstats = ensureLeaderstats(player)
    local coins = leaderstats:WaitForChild("Coins") :: IntValue

    coins.Value += amount
end

local function getPickupSpawnCFrame(): CFrame
    local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation")

    if spawnLocation then
        return spawnLocation.CFrame + Vector3.new(0, 4, -8)
    end

    return CFrame.new(0, 6, 0)
end

local function createCoinPickup()
    local pickup = Instance.new("Part")
    pickup.Name = "CoinPickup"
    pickup.Shape = Enum.PartType.Ball
    pickup.Size = Vector3.new(2.5, 2.5, 2.5)
    pickup.Material = Enum.Material.Neon
    pickup.Color = Color3.fromRGB(255, 221, 45)
    pickup.Anchored = true
    pickup.CanCollide = false
    pickup.CastShadow = false
    pickup.CFrame = getPickupSpawnCFrame()
    pickup.Parent = workspace

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 245, 157)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = pickup

    local prompt = Instance.new("BillboardGui")
    prompt.Name = "Prompt"
    prompt.Size = UDim2.fromOffset(120, 40)
    prompt.StudsOffset = Vector3.new(0, 2.8, 0)
    prompt.AlwaysOnTop = true
    prompt.Parent = pickup

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 249, 196)
    label.TextStrokeTransparency = 0.4
    label.Text = string.format("+%d Coins", Shared.SessionStats.PickupCoinReward)
    label.Parent = prompt

    local respawning = false

    pickup.Touched:Connect(function(otherPart)
        if respawning then
            return
        end

        local character = otherPart.Parent

        if not character then
            return
        end

        local player = Players:GetPlayerFromCharacter(character)

        if not player then
            return
        end

        local now = os.clock()
        local lastTouch = pickupTouchDebounce[player]

        if lastTouch and now - lastTouch < 0.75 then
            return
        end

        pickupTouchDebounce[player] = now
        respawning = true

        awardCoins(player, Shared.SessionStats.PickupCoinReward)

        pickup.Transparency = 1
        pickup.CanTouch = false
        prompt.Enabled = false
        highlight.Enabled = false

        task.delay(Shared.SessionStats.PickupRespawnSeconds, function()
            if not pickup.Parent then
                return
            end

            pickup.CFrame = getPickupSpawnCFrame()
            pickup.Transparency = 0
            pickup.CanTouch = true
            prompt.Enabled = true
            highlight.Enabled = true
            respawning = false
        end)
    end)
end

local function clearBoost(player: Player)
    playerBoostStates[player] = nil
    setBoostAttributes(player, false, 0)
    applyWalkSpeed(player)
end

local function trackCharacter(player: Player, character: Model)
    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
    local leaderstats = ensureLeaderstats(player)
    local jumps = leaderstats:WaitForChild("Jumps") :: IntValue
    local lastJumpTick = 0

    applyWalkSpeed(player)

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

local function startSpeedBoost(player: Player)
    local now = workspace:GetServerTimeNow()
    local currentState = playerBoostStates[player]
    local newToken = if currentState then currentState.token + 1 else 1
    local expiresAt = now + Shared.SessionStats.SpeedBoostDuration

    playerBoostStates[player] = {
        expiresAt = expiresAt,
        token = newToken,
    }

    setBoostAttributes(player, true, expiresAt)
    applyWalkSpeed(player)

    task.spawn(function()
        task.wait(Shared.SessionStats.SpeedBoostDuration)

        local latestState = playerBoostStates[player]

        if not latestState or latestState.token ~= newToken then
            return
        end

        if latestState.expiresAt > workspace:GetServerTimeNow() then
            return
        end

        clearBoost(player)
    end)
end

local function startSessionTracking(player: Player)
    local leaderstats = ensureLeaderstats(player)
    local timePlayed = leaderstats:WaitForChild("TimePlayed") :: IntValue
    local coins = leaderstats:WaitForChild("Coins") :: IntValue

    task.spawn(function()
        while player.Parent do
            task.wait(1)
            timePlayed.Value += 1

            if timePlayed.Value % Shared.SessionStats.CoinRewardSeconds == 0 then
                coins.Value += Shared.SessionStats.CoinRewardAmount
            end
        end
    end)
end

local function onPlayerAdded(player: Player)
    ensureLeaderstats(player)
    setBoostAttributes(player, false, 0)
    startSessionTracking(player)

    player.CharacterAdded:Connect(function(character)
        trackCharacter(player, character)
    end)

    if player.Character then
        trackCharacter(player, player.Character)
    end
end

local function onPlayerRemoving(player: Player)
    playerBoostStates[player] = nil
end

local function purchaseBoostForPlayer(player: Player)
    local leaderstats = ensureLeaderstats(player)
    local coins = leaderstats:WaitForChild("Coins") :: IntValue
    local boostState = playerBoostStates[player]
    local now = workspace:GetServerTimeNow()

    if boostState and boostState.expiresAt > now then
        return false, "Speed boost already active."
    end

    if coins.Value < Shared.SessionStats.SpeedBoostCost then
        return false, string.format("Need %d coins for boost.", Shared.SessionStats.SpeedBoostCost)
    end

    coins.Value -= Shared.SessionStats.SpeedBoostCost
    startSpeedBoost(player)

    return true, string.format("Speed boost active for %d seconds.", Shared.SessionStats.SpeedBoostDuration)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

local purchaseSpeedBoostRemote = purchaseSpeedBoost :: RemoteFunction

purchaseSpeedBoostRemote.OnServerInvoke = function(player)
    return purchaseBoostForPlayer(player)
end

for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

createCoinPickup()
