local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = require(ReplicatedStorage.Shared)

print("[Server]", Shared.getGreeting())
