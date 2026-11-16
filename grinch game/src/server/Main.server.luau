--!strict
-- Server entry point: build the world, then start services.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

Players.CharacterAutoLoads = false

local Shared = ReplicatedStorage:WaitForChild("Shared")
require(Shared.Remotes) -- creates the RemoteEvents

local World = require(script.Parent.World)
local PlayerService = require(script.Parent.Services.PlayerService)

PlayerService.start()

local t = os.clock()
World.build()
ReplicatedStorage:SetAttribute("WorldReady", true)
print(string.format("[Main] World ready in %.2fs", os.clock() - t))
