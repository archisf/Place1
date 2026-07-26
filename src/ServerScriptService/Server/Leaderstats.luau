--!strict

local Leaderstats = {}

local function ensureIntValue(parent: Folder, name: string): IntValue
    local existing = parent:FindFirstChild(name)

    if existing then
        if not existing:IsA("IntValue") then
            error(
                string.format(
                    "%s.%s must be an IntValue, got %s",
                    parent:GetFullName(),
                    name,
                    existing.ClassName
                )
            )
        end

        return existing
    end

    local value = Instance.new("IntValue")
    value.Name = name
    value.Parent = parent

    return value
end

function Leaderstats.ensure(playerContainer: Instance): Folder
    local existing = playerContainer:FindFirstChild("leaderstats")
    local leaderstats: Folder

    if existing then
        if not existing:IsA("Folder") then
            error(
                string.format(
                    "%s.leaderstats must be a Folder, got %s",
                    playerContainer:GetFullName(),
                    existing.ClassName
                )
            )
        end

        leaderstats = existing
    else
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = playerContainer
    end

    ensureIntValue(leaderstats, "TimePlayed")
    ensureIntValue(leaderstats, "Jumps")
    ensureIntValue(leaderstats, "Coins")

    return leaderstats
end

function Leaderstats.getStat(playerContainer: Instance, name: string): IntValue
    local leaderstats = Leaderstats.ensure(playerContainer)
    local value = leaderstats:FindFirstChild(name)

    if not value or not value:IsA("IntValue") then
        error(string.format("%s.%s is not a valid leaderstat", leaderstats:GetFullName(), name))
    end

    return value
end

return Leaderstats
