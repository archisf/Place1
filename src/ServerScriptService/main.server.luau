--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)
local Server = script.Parent.Server
local BoostService = require(Server.BoostService)
local PickupService = require(Server.PickupService)
local RemoteRegistry = require(Server.RemoteRegistry)
local StatsService = require(Server.StatsService)

print("[Server]", Shared.getGreeting())

local purchaseSpeedBoost = RemoteRegistry.getPurchaseSpeedBoost(ReplicatedStorage)

local function onPlayerAdded(player: Player)
    StatsService.startPlayer(player)
    BoostService.startPlayer(player)
end

local function onPlayerRemoving(player: Player)
    PickupService.stopPlayer(player)
    BoostService.stopPlayer(player)
    StatsService.stopPlayer(player)
end

purchaseSpeedBoost.OnServerInvoke = function(player: Player): (boolean, string)
    return BoostService.purchase(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in Players:GetPlayers() do
    task.spawn(onPlayerAdded, player)
end

PickupService.start()
