--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)
local StatsService = require(script.Parent.StatsService)

local PickupService = {}

local pickup: BasePart? = nil
local touchConnection: RBXScriptConnection? = nil
local respawning = false
local lastTouches: { [Player]: number } = {}

local function requireChildOfClass<T>(
    parent: Instance,
    name: string,
    className: string,
    create: () -> T
): T
    local existing = parent:FindFirstChild(name)

    if existing then
        if not existing:IsA(className) then
            error(
                string.format(
                    "%s.%s must be a %s, got %s",
                    parent:GetFullName(),
                    name,
                    className,
                    existing.ClassName
                )
            )
        end

        return existing :: any
    end

    local child = create()
    local dynamicChild = child :: any
    dynamicChild.Name = name
    dynamicChild.Parent = parent

    return child
end

local function getPickupSpawnCFrame(): CFrame
    local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation")

    if spawnLocation then
        return spawnLocation.CFrame + Vector3.new(0, 4, -8)
    end

    return CFrame.new(0, 6, 0)
end

local function configurePickup(): BasePart
    local existing = workspace:FindFirstChild("CoinPickup")
    local part: BasePart

    if existing then
        if not existing:IsA("BasePart") then
            error(
                string.format("Workspace.CoinPickup must be a BasePart, got %s", existing.ClassName)
            )
        end

        part = existing
    else
        local created = Instance.new("Part")
        created.Name = "CoinPickup"
        created.Parent = workspace
        part = created
    end

    if part:IsA("Part") then
        part.Shape = Enum.PartType.Ball
    end

    part.Size = Vector3.new(2.5, 2.5, 2.5)
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 221, 45)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = true
    part.CastShadow = false
    part.Transparency = 0
    part.CFrame = getPickupSpawnCFrame()

    local highlight = requireChildOfClass(part, "Highlight", "Highlight", function()
        return Instance.new("Highlight")
    end) :: Highlight
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 245, 157)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true

    local prompt = requireChildOfClass(part, "Prompt", "BillboardGui", function()
        return Instance.new("BillboardGui")
    end) :: BillboardGui
    prompt.Size = UDim2.fromOffset(120, 40)
    prompt.StudsOffset = Vector3.new(0, 2.8, 0)
    prompt.AlwaysOnTop = true
    prompt.Enabled = true

    local label = requireChildOfClass(prompt, "Label", "TextLabel", function()
        return Instance.new("TextLabel")
    end) :: TextLabel
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 249, 196)
    label.TextStrokeTransparency = 0.4
    label.Text = string.format("+%d Coins", Shared.SessionStats.PickupCoinReward)

    return part
end

local function setPickupVisible(part: BasePart, visible: boolean)
    part.Transparency = if visible then 0 else 1
    part.CanTouch = visible

    local prompt = part:FindFirstChild("Prompt")

    if prompt and prompt:IsA("BillboardGui") then
        prompt.Enabled = visible
    end

    local highlight = part:FindFirstChild("Highlight")

    if highlight and highlight:IsA("Highlight") then
        highlight.Enabled = visible
    end
end

local function onTouched(otherPart: BasePart)
    local part = pickup

    if respawning or not part then
        return
    end

    local character = otherPart:FindFirstAncestorOfClass("Model")

    if not character then
        return
    end

    local player = Players:GetPlayerFromCharacter(character)

    if not player then
        return
    end

    local touchTime = os.clock()

    if not Shared.EconomyRules.canCollectPickup(lastTouches[player], touchTime) then
        return
    end

    lastTouches[player] = touchTime
    respawning = true
    StatsService.awardCoins(player, Shared.SessionStats.PickupCoinReward)
    setPickupVisible(part, false)

    task.delay(Shared.SessionStats.PickupRespawnSeconds, function()
        if pickup ~= part or not part.Parent then
            return
        end

        part.CFrame = getPickupSpawnCFrame()
        setPickupVisible(part, true)
        respawning = false
    end)
end

function PickupService.start()
    if pickup then
        return
    end

    local part = configurePickup()
    pickup = part
    touchConnection = part.Touched:Connect(onTouched)
end

function PickupService.stopPlayer(player: Player)
    lastTouches[player] = nil
end

function PickupService.destroy()
    if touchConnection then
        touchConnection:Disconnect()
        touchConnection = nil
    end

    table.clear(lastTouches)
    pickup = nil
    respawning = false
end

return PickupService
