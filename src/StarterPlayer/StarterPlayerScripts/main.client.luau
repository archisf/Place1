--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)
local SessionHud = require(script.Parent.Client.SessionHud)

print("[Client]", Shared.getGreeting())

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

if not remotes:IsA("Folder") then
    error("ReplicatedStorage.Remotes must be a Folder")
end

local purchaseSpeedBoost = remotes:WaitForChild("PurchaseSpeedBoost")

if not purchaseSpeedBoost:IsA("RemoteFunction") then
    error("ReplicatedStorage.Remotes.PurchaseSpeedBoost must be a RemoteFunction")
end

local hud = SessionHud.mount(player, purchaseSpeedBoost)

script.Destroying:Connect(hud.destroy)
