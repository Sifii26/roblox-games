--!strict
-- Picks the music state from where the player's character is standing.
-- Outside by default, Inside within any part tagged "InteriorZone".
-- Later phases can override with MusicZones.setOverride("Detected") etc.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Music = require(script.Parent.MusicController)

local MusicZones = {}

local override: string? = nil
local running = false

local function inZone(pos: Vector3): boolean
	for _, zone in CollectionService:GetTagged("InteriorZone") do
		if zone:IsA("BasePart") then
			local localPos = zone.CFrame:PointToObjectSpace(pos)
			local half = zone.Size / 2
			if math.abs(localPos.X) <= half.X and math.abs(localPos.Y) <= half.Y and math.abs(localPos.Z) <= half.Z then
				return true
			end
		end
	end
	return false
end

function MusicZones.setOverride(state: string?)
	override = state
end

function MusicZones.start()
	if running then
		return
	end
	running = true
	task.spawn(function()
		while running do
			local character = Players.LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
			if override then
				Music.setState(override)
			elseif root then
				-- Until an Inside track is configured, keep the outside music playing indoors.
				local inside = inZone(root.Position) and Music.hasTrack("Inside")
				Music.setState(if inside then "Inside" else "Outside")
			end
			task.wait(0.5)
		end
	end)
end

function MusicZones.stop()
	running = false
end

return MusicZones
