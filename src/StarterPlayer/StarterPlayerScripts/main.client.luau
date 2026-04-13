local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)

print("[Client]", Shared.getGreeting())

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SessionStatsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -16, 0, 16)
panel.Size = UDim2.fromOffset(210, 96)
panel.BackgroundColor3 = Color3.fromRGB(23, 27, 39)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Transparency = 0.35
stroke.Color = Color3.fromRGB(130, 170, 255)
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 8)
title.Size = UDim2.new(1, -24, 0, 22)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = Shared.SessionStats.HudTitle
title.Parent = panel

local timeLabel = Instance.new("TextLabel")
timeLabel.Name = "TimePlayed"
timeLabel.BackgroundTransparency = 1
timeLabel.Position = UDim2.fromOffset(12, 36)
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
jumpsLabel.Position = UDim2.fromOffset(12, 58)
jumpsLabel.Size = UDim2.new(1, -24, 0, 20)
jumpsLabel.Font = Enum.Font.Gotham
jumpsLabel.TextSize = 14
jumpsLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpsLabel.TextColor3 = Color3.fromRGB(225, 231, 255)
jumpsLabel.Text = "Jumps: 0"
jumpsLabel.Parent = panel

local milestoneLabel = Instance.new("TextLabel")
milestoneLabel.Name = "Milestone"
milestoneLabel.BackgroundTransparency = 1
milestoneLabel.Position = UDim2.fromOffset(12, 78)
milestoneLabel.Size = UDim2.new(1, -24, 0, 14)
milestoneLabel.Font = Enum.Font.GothamMedium
milestoneLabel.TextSize = 12
milestoneLabel.TextXAlignment = Enum.TextXAlignment.Left
milestoneLabel.TextColor3 = Color3.fromRGB(140, 226, 168)
milestoneLabel.Text = "Reach 00:30 for a milestone"
milestoneLabel.Parent = panel

local lastMilestone = 0

local function updateLabels()
    local leaderstats = player:FindFirstChild("leaderstats")

    if not leaderstats then
        return
    end

    local timePlayed = leaderstats:FindFirstChild("TimePlayed")
    local jumps = leaderstats:FindFirstChild("Jumps")

    if timePlayed and timePlayed:IsA("IntValue") then
        local seconds = timePlayed.Value
        timeLabel.Text = string.format("Time: %s", Shared.formatClock(seconds))

        if seconds > 0 and seconds % Shared.SessionStats.MilestoneSeconds == 0 and seconds ~= lastMilestone then
            lastMilestone = seconds
            milestoneLabel.Text = string.format("Milestone reached: %s", Shared.formatClock(seconds))
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
end

local function hookLeaderstats()
    local leaderstats = player:WaitForChild("leaderstats")
    local timePlayed = leaderstats:WaitForChild("TimePlayed")
    local jumps = leaderstats:WaitForChild("Jumps")

    timePlayed:GetPropertyChangedSignal("Value"):Connect(updateLabels)
    jumps:GetPropertyChangedSignal("Value"):Connect(updateLabels)

    updateLabels()
end

task.spawn(hookLeaderstats)
