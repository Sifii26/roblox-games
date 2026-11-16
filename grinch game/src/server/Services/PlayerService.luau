--!strict
-- Handles players moving between the menu and Free Roam.
-- Characters do not load automatically (Players.CharacterAutoLoads = false);
-- the menu asks the server to spawn the character when Free Roam starts.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Remotes = require(Shared.Remotes)
local Layout = require(Shared.Config.Layout)
local Missions = require(Shared.Config.Missions)

local PlayerService = {}

local lastRequest: { [Player]: number } = {}
local menuFocus: BasePart

local function isPlayable(missionId: string): boolean
	for _, m in Missions do
		if m.Id == missionId then
			return m.Playable
		end
	end
	return false
end

local function spawnCharacter(player: Player)
	player.ReplicationFocus = nil
	player:LoadCharacter()
	local character = player.Character
	if not character then
		return
	end
	local root = character:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	if root then
		local spawnPos = Layout.FreeRoamSpawn
		character:PivotTo(CFrame.lookAt(spawnPos, Vector3.new(0, spawnPos.Y, 0)))
	end
	player:SetAttribute("InFreeRoam", true)
end

function PlayerService.start()
	-- Players in the menu stream the area around the menu camera.
	menuFocus = Instance.new("Part")
	menuFocus.Name = "MenuStreamFocus"
	menuFocus.Anchored = true
	menuFocus.CanCollide = false
	menuFocus.CanQuery = false
	menuFocus.CanTouch = false
	menuFocus.Transparency = 1
	menuFocus.Size = Vector3.one
	menuFocus.Position = Layout.MenuCamera.LookAt
	menuFocus.Parent = Workspace

	Players.PlayerAdded:Connect(function(player)
		player.ReplicationFocus = menuFocus
		player:SetAttribute("InFreeRoam", false)
	end)
	for _, player in Players:GetPlayers() do
		player.ReplicationFocus = menuFocus
	end
	Players.PlayerRemoving:Connect(function(player)
		lastRequest[player] = nil
	end)

	Remotes.get("StartFreeRoam").OnServerEvent:Connect(function(player, missionId)
		if typeof(missionId) ~= "string" or not isPlayable(missionId) then
			return
		end
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 2 then
			return -- debounce repeated clicks
		end
		lastRequest[player] = now
		spawnCharacter(player)
	end)

	Remotes.get("ReturnToMenu").OnServerEvent:Connect(function(player)
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 1 then
			return
		end
		lastRequest[player] = now
		if player.Character then
			player.Character:Destroy()
			player.Character = nil
		end
		player.ReplicationFocus = menuFocus
		player:SetAttribute("InFreeRoam", false)
	end)

	-- Respawn in Free Roam after falling or resetting.
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid") :: Humanoid
			humanoid.Died:Connect(function()
				task.wait(3)
				if player.Parent and player:GetAttribute("InFreeRoam") and player.Character == character then
					spawnCharacter(player)
				end
			end)
		end)
	end)
end

return PlayerService
