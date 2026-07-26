--!strict

local RemoteRegistry = {}

local function getOrCreateFolder(parent: Instance, name: string): Folder
    local existing = parent:FindFirstChild(name)

    if existing then
        if not existing:IsA("Folder") then
            error(
                string.format(
                    "%s.%s must be a Folder, got %s",
                    parent:GetFullName(),
                    name,
                    existing.ClassName
                )
            )
        end

        return existing
    end

    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent

    return folder
end

local function getOrCreateRemoteFunction(parent: Instance, name: string): RemoteFunction
    local existing = parent:FindFirstChild(name)

    if existing then
        if not existing:IsA("RemoteFunction") then
            error(
                string.format(
                    "%s.%s must be a RemoteFunction, got %s",
                    parent:GetFullName(),
                    name,
                    existing.ClassName
                )
            )
        end

        return existing
    end

    local remoteFunction = Instance.new("RemoteFunction")
    remoteFunction.Name = name
    remoteFunction.Parent = parent

    return remoteFunction
end

function RemoteRegistry.getPurchaseSpeedBoost(replicatedStorage: Instance): RemoteFunction
    local remotes = getOrCreateFolder(replicatedStorage, "Remotes")

    return getOrCreateRemoteFunction(remotes, "PurchaseSpeedBoost")
end

return RemoteRegistry
