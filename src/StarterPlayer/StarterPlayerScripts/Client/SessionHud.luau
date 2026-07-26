--!strict

local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = require(ReplicatedStorage.Shared)

export type Controller = {
    destroy: () -> (),
}

type PurchaseResponse = {
    succeeded: boolean,
    message: string,
}

local SessionHud = {}

local function createTextLabel(
    parent: Instance,
    name: string,
    position: UDim2,
    size: UDim2,
    font: Enum.Font,
    textSize: number,
    color: Color3,
    text: string
): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = font
    label.TextSize = textSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = color
    label.Text = text
    label.Parent = parent

    return label
end

function SessionHud.mount(player: Player, purchaseSpeedBoost: RemoteFunction): Controller
    local playerGuiInstance = player:WaitForChild("PlayerGui")

    if not playerGuiInstance:IsA("PlayerGui") then
        error(string.format("%s.PlayerGui must be a PlayerGui", player:GetFullName()))
    end

    local existingGui = playerGuiInstance:FindFirstChild("SessionStatsGui")

    if existingGui then
        if not existingGui:IsA("ScreenGui") then
            error(
                string.format(
                    "%s.SessionStatsGui must be a ScreenGui",
                    playerGuiInstance:GetFullName()
                )
            )
        end

        existingGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SessionStatsGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGuiInstance

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

    createTextLabel(
        panel,
        "Title",
        UDim2.fromOffset(14, 10),
        UDim2.new(1, -24, 0, 22),
        Enum.Font.GothamBold,
        17,
        Color3.fromRGB(255, 255, 255),
        Shared.SessionStats.HudTitle
    )

    local timeLabel = createTextLabel(
        panel,
        "TimePlayed",
        UDim2.fromOffset(14, 40),
        UDim2.new(1, -24, 0, 20),
        Enum.Font.Gotham,
        14,
        Color3.fromRGB(225, 231, 255),
        "Time: 00:00"
    )

    local jumpsLabel = createTextLabel(
        panel,
        "Jumps",
        UDim2.fromOffset(14, 64),
        UDim2.new(1, -24, 0, 20),
        Enum.Font.Gotham,
        14,
        Color3.fromRGB(225, 231, 255),
        "Jumps: 0"
    )

    local coinsLabel = createTextLabel(
        panel,
        "Coins",
        UDim2.fromOffset(14, 88),
        UDim2.new(1, -24, 0, 20),
        Enum.Font.Gotham,
        14,
        Color3.fromRGB(253, 224, 71),
        "Coins: 0"
    )

    local milestoneLabel = createTextLabel(
        panel,
        "Milestone",
        UDim2.fromOffset(14, 108),
        UDim2.new(1, -24, 0, 14),
        Enum.Font.GothamMedium,
        12,
        Color3.fromRGB(140, 226, 168),
        "Reach 00:30 for a milestone"
    )

    local boostStatusLabel = createTextLabel(
        panel,
        "BoostStatus",
        UDim2.fromOffset(14, 126),
        UDim2.new(1, -28, 0, 16),
        Enum.Font.GothamMedium,
        12,
        Color3.fromRGB(125, 211, 252),
        ""
    )

    local boostButton = Instance.new("TextButton")
    boostButton.Name = "BoostButton"
    boostButton.Position = UDim2.new(1, -126, 1, -34)
    boostButton.Size = UDim2.fromOffset(112, 26)
    boostButton.Font = Enum.Font.GothamBold
    boostButton.TextSize = 12
    boostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boostButton.Parent = panel

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = boostButton

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Transparency = 0.45
    buttonStroke.Color = Color3.fromRGB(191, 219, 254)
    buttonStroke.Parent = boostButton

    local connections: { RBXScriptConnection } = {}
    local destroyed = false
    local lastMilestone = 0
    local basePanelPosition = panel.Position
    local boostRequestInFlight = false
    local countdownAccumulator = 0

    local function connect(signal: RBXScriptSignal, callback: (...any) -> ())
        table.insert(connections, signal:Connect(callback))
    end

    local function pulsePanel()
        if destroyed then
            return
        end

        panel.Position = basePanelPosition + UDim2.fromOffset(0, -2)

        task.delay(0.18, function()
            if not destroyed and panel.Parent then
                panel.Position = basePanelPosition
            end
        end)
    end

    local function updateBoostUi()
        if destroyed then
            return
        end

        local expiresAtAttribute = player:GetAttribute("SpeedBoostExpiresAt")
        local expiresAt = if typeof(expiresAtAttribute) == "number" then expiresAtAttribute else nil
        local model = Shared.HudViewModel.getBoostUi(
            player:GetAttribute("SpeedBoostActive") == true,
            expiresAt,
            workspace:GetServerTimeNow(),
            boostRequestInFlight
        )

        boostStatusLabel.Text = model.statusText
        boostButton.Text = model.buttonText
        boostButton.BackgroundColor3 = model.buttonColor
        boostButton.AutoButtonColor = model.autoButtonColor
        boostButton.Active = model.buttonActive
    end

    local function updateLabels()
        if destroyed then
            return
        end

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

            if
                seconds > 0
                and seconds % Shared.SessionStats.MilestoneSeconds == 0
                and seconds ~= lastMilestone
            then
                lastMilestone = seconds
                milestoneLabel.Text =
                    string.format("Milestone reached: %s", Shared.formatClock(seconds))
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

    local function invokePurchase(): PurchaseResponse
        local purchaseSucceeded, message = purchaseSpeedBoost:InvokeServer()

        if typeof(purchaseSucceeded) ~= "boolean" or typeof(message) ~= "string" then
            error("PurchaseSpeedBoost returned an invalid response")
        end

        return {
            succeeded = purchaseSucceeded,
            message = message,
        }
    end

    local function requestBoostPurchase()
        if boostRequestInFlight or player:GetAttribute("SpeedBoostActive") == true then
            return
        end

        boostRequestInFlight = true
        updateBoostUi()

        local callSucceeded, responseOrError = pcall(invokePurchase)
        boostRequestInFlight = false

        if callSucceeded then
            local response = responseOrError :: PurchaseResponse
            milestoneLabel.Text =
                Shared.HudViewModel.getPurchaseFeedback(true, response.succeeded, response.message)

            if response.succeeded then
                pulsePanel()
            end
        else
            milestoneLabel.Text = Shared.HudViewModel.getPurchaseFeedback(false, nil, nil)
        end

        updateBoostUi()
    end

    local function hookLeaderstats()
        local leaderstats = player:WaitForChild("leaderstats", 10)

        if destroyed then
            return
        end

        if not leaderstats or not leaderstats:IsA("Folder") then
            warn("[Client] leaderstats did not appear within 10 seconds")
            return
        end

        for _, statName in { "TimePlayed", "Jumps", "Coins" } do
            local stat = leaderstats:WaitForChild(statName, 10)

            if not stat or not stat:IsA("IntValue") then
                warn(
                    string.format(
                        "[Client] leaderstats.%s is missing or has the wrong class",
                        statName
                    )
                )
                return
            end

            connect(stat:GetPropertyChangedSignal("Value"), updateLabels)
        end

        updateLabels()
    end

    connect(boostButton.MouseButton1Click, requestBoostPurchase)
    connect(player:GetAttributeChangedSignal("SpeedBoostActive"), updateBoostUi)
    connect(player:GetAttributeChangedSignal("SpeedBoostExpiresAt"), updateBoostUi)
    connect(RunService.Heartbeat, function(deltaTime: number)
        if player:GetAttribute("SpeedBoostActive") ~= true then
            countdownAccumulator = 0
            return
        end

        countdownAccumulator += deltaTime

        if countdownAccumulator >= 0.1 then
            countdownAccumulator %= 0.1
            updateBoostUi()
        end
    end)

    updateBoostUi()
    task.spawn(hookLeaderstats)

    local controller: Controller
    controller = {
        destroy = function()
            if destroyed then
                return
            end

            destroyed = true

            for _, connection in connections do
                connection:Disconnect()
            end

            table.clear(connections)
            screenGui:Destroy()
        end,
    }

    return controller
end

return SessionHud
