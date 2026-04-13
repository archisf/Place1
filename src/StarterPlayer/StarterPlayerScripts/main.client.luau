local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)

print("[Client]", Shared.getGreeting())
