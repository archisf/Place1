local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = require(ReplicatedStorage.Shared)

print("[Client]", Shared.getGreeting())

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local purchaseSpeedBoost = remotesFolder:WaitForChild("PurchaseSpeedBoost") :: RemoteFunction

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SessionStatsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -16, 0, 16)
panel.Size = UDim2.fromOffset(260, 170)
panel.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Transparency = 0.35
stroke.Color = Color3.fromRGB(96, 165, 250)
stroke.Parent = panel

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 41, 59)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42)),
})
gradient.Rotation = 90
gradient.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 10)
title.Size = UDim2.new(1, -24, 0, 22)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = Shared.SessionStats.HudTitle
title.Parent = panel

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimePlayed"
timeLabel.BackgroundTransparency = 1
timeLabel.Position = UDim2.fromOffset(14, 40)
timeLabel.Size = UDim2.new(1, -24, 0, 20)
timeLabel.Font = Enum.Font.Gotham
timeLabel.TextSize = 14
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.TextColor3 = Color3.fromRGB(225, 231, 255)
timeLabel.Text = "Time: 00:00"
timeLabel.Parent = panel

local jumpsLabel = Instance.new("TextLabel")
jumpsLabel.Name = "Jumps"
jumpsLabel.BackgroundTransparency = 1
jumpsLabel.Position = UDim2.fromOffset(14, 64)
jumpsLabel.Size = UDim2.new(1, -24, 0, 20)
jumpsLabel.Font = Enum.Font.Gotham
jumpsLabel.TextSize = 14
jumpsLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpsLabel.TextColor3 = Color3.fromRGB(225, 231, 255)
jumpsLabel.Text = "Jumps: 0"
jumpsLabel.Parent = panel

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "Coins"
coinsLabel.BackgroundTransparency = 1
coinsLabel.Position = UDim2.fromOffset(14, 88)
coinsLabel.Size = UDim2.new(1, -24, 0, 20)
coinsLabel.Font = Enum.Font.Gotham
coinsLabel.TextSize = 14
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.TextColor3 = Color3.fromRGB(253, 224, 71)
coinsLabel.Text = "Coins: 0"
coinsLabel.Parent = panel

local milestoneLabel = Instance.new("TextLabel")
milestoneLabel.Name = "Milestone"
milestoneLabel.BackgroundTransparency = 1
milestoneLabel.Position = UDim2.fromOffset(14, 108)
milestoneLabel.Size = UDim2.new(1, -24, 0, 14)
milestoneLabel.Font = Enum.Font.GothamMedium
milestoneLabel.TextSize = 12
milestoneLabel.TextXAlignment = Enum.TextXAlignment.Left
milestoneLabel.TextColor3 = Color3.fromRGB(140, 226, 168)
milestoneLabel.Text = "Reach 00:30 for a milestone"
milestoneLabel.Parent = panel

local boostStatusLabel = Instance.new("TextLabel")
boostStatusLabel.Name = "BoostStatus"
boostStatusLabel.BackgroundTransparency = 1
boostStatusLabel.Position = UDim2.fromOffset(14, 126)
boostStatusLabel.Size = UDim2.new(1, -28, 0, 16)
boostStatusLabel.Font = Enum.Font.GothamMedium
boostStatusLabel.TextSize = 12
boostStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
boostStatusLabel.TextColor3 = Color3.fromRGB(125, 211, 252)
boostStatusLabel.Text = string.format(
    "Buy speed boost: %d coins for %ds",
    Shared.SessionStats.SpeedBoostCost,
    Shared.SessionStats.SpeedBoostDuration
)
boostStatusLabel.Parent = panel

local boostButton = Instance.new("TextButton")
boostButton.Name = "BoostButton"
boostButton.Position = UDim2.new(1, -126, 1, -34)
boostButton.Size = UDim2.fromOffset(112, 26)
boostButton.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
boostButton.AutoButtonColor = true
boostButton.Font = Enum.Font.GothamBold
boostButton.TextSize = 12
boostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
boostButton.Text = "Use Speed Boost"
boostButton.Parent = panel

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = boostButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Transparency = 0.45
buttonStroke.Color = Color3.fromRGB(191, 219, 254)
buttonStroke.Parent = boostButton

local lastMilestone = 0
local basePanelPosition = panel.Position
local boostRequestInFlight = false

local function pulsePanel()
    panel.Position = basePanelPosition + UDim2.fromOffset(0, -2)

    task.delay(0.18, function()
        if panel.Parent then
            panel.Position = basePanelPosition
        end
    end)
end

local function updateBoostUi()
    local expiresAt = player:GetAttribute("SpeedBoostExpiresAt")
    local isActive = player:GetAttribute("SpeedBoostActive") == true

    if isActive and typeof(expiresAt) == "number" and expiresAt > 0 then
        local remaining = math.max(0, expiresAt - workspace:GetServerTimeNow())

        boostStatusLabel.Text = string.format(
            "Boost active: +%d speed for %s",
            Shared.SessionStats.BoostWalkSpeed - Shared.SessionStats.DefaultWalkSpeed,
            Shared.formatDuration(remaining)
        )
        boostButton.Text = "Boost Active"
        boostButton.BackgroundColor3 = Color3.fromRGB(8, 145, 178)
        boostButton.AutoButtonColor = false
        boostButton.Active = false
        return
    end

    boostStatusLabel.Text = string.format(
        "Buy speed boost: %d coins for %ds",
        Shared.SessionStats.SpeedBoostCost,
        Shared.SessionStats.SpeedBoostDuration
    )
    boostButton.Text = if boostRequestInFlight then "Buying..." else "Use Speed Boost"
    boostButton.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
    boostButton.AutoButtonColor = not boostRequestInFlight
    boostButton.Active = not boostRequestInFlight
end

local function updateLabels()
    local leaderstats = player:FindFirstChild("leaderstats")

    if not leaderstats then
        return
    end

    local timePlayed = leaderstats:FindFirstChild("TimePlayed")
    local jumps = leaderstats:FindFirstChild("Jumps")
    local coins = leaderstats:FindFirstChild("Coins")

    if timePlayed and timePlayed:IsA("IntValue") then
        local seconds = timePlayed.Value
        timeLabel.Text = string.format("Time: %s", Shared.formatClock(seconds))

        if seconds > 0 and seconds % Shared.SessionStats.MilestoneSeconds == 0 and seconds ~= lastMilestone then
            lastMilestone = seconds
            milestoneLabel.Text = string.format("Milestone reached: %s", Shared.formatClock(seconds))
            pulsePanel()
        elseif lastMilestone == 0 then
            milestoneLabel.Text = string.format(
                "Reach %s for a milestone",
                Shared.formatClock(Shared.SessionStats.MilestoneSeconds)
            )
        end
    end

    if jumps and jumps:IsA("IntValue") then
        jumpsLabel.Text = string.format("Jumps: %d", jumps.Value)
    end

    if coins and coins:IsA("IntValue") then
        coinsLabel.Text = string.format("Coins: %s", Shared.formatCoins(coins.Value))
    end
end

local function requestBoostPurchase()
    if boostRequestInFlight or player:GetAttribute("SpeedBoostActive") == true then
        return
    end

    boostRequestInFlight = true
    updateBoostUi()

    local success, purchaseSucceeded, message = pcall(function()
        return purchaseSpeedBoost:InvokeServer()
    end)

    boostRequestInFlight = false

    if success and purchaseSucceeded then
        milestoneLabel.Text = message
        pulsePanel()
    elseif success then
        milestoneLabel.Text = message
    else
        milestoneLabel.Text = "Boost purchase failed. Try again."
    end

    updateBoostUi()
end

local function hookLeaderstats()
    local leaderstats = player:WaitForChild("leaderstats")
    local timePlayed = leaderstats:WaitForChild("TimePlayed")
    local jumps = leaderstats:WaitForChild("Jumps")
    local coins = leaderstats:WaitForChild("Coins")

    timePlayed:GetPropertyChangedSignal("Value"):Connect(updateLabels)
    jumps:GetPropertyChangedSignal("Value"):Connect(updateLabels)
    coins:GetPropertyChangedSignal("Value"):Connect(updateLabels)

    updateLabels()
end

boostButton.MouseButton1Click:Connect(requestBoostPurchase)
player:GetAttributeChangedSignal("SpeedBoostActive"):Connect(updateBoostUi)
player:GetAttributeChangedSignal("SpeedBoostExpiresAt"):Connect(updateBoostUi)

RunService.Heartbeat:Connect(function()
    if player:GetAttribute("SpeedBoostActive") == true then
        updateBoostUi()
    end
end)

updateBoostUi()
task.spawn(hookLeaderstats)
