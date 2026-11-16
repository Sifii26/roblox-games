--!strict
-- Builds the whole Phase 1 world into Workspace.Map.
-- If a Map already exists (for example after you baked the generated map into
-- the place file and hand-edited it), the builder leaves it alone.
local Workspace = game:GetService("Workspace")

local Builder = require(script.Builder)
local Environment = require(script.Environment)
local TownCenter = require(script.TownCenter)
local Houses = require(script.Houses)
local Districts = require(script.Districts)
local Hideout = require(script.Hideout)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Config.Layout)

local World = {}

local function step(name: string, fn: () -> ())
	local t = os.clock()
	local ok, err = pcall(fn)
	if ok then
		print(string.format("[World] %s built in %.2fs", name, os.clock() - t))
	else
		warn(string.format("[World] %s failed: %s", name, tostring(err)))
	end
end

function World.build(): Model
	local existing = Workspace:FindFirstChild("Map")
	if existing and existing:IsA("Model") then
		print("[World] Existing Map found; skipping generation")
		Environment.lighting()
		return existing
	end

	local map = Builder.model("Map", nil)
	map.ModelStreamingMode = Enum.ModelStreamingMode.Default

	step("Lighting", Environment.lighting)
	step("Terrain", function()
		Environment.terrain(map)
	end)
	step("Roads", function()
		Environment.roads(map)
	end)
	step("Town center", function()
		TownCenter.build(map)
	end)
	step("Starter neighborhood", function()
		local hood = Builder.folder("StarterNeighborhood", map)
		local n = Layout.Neighborhood
		local edge = Layout.RoadWidth / 2 + Layout.SidewalkWidth
		-- Lots on the north side face +Z (toward the road); south side faces -Z.
		local function northLot(x: number): CFrame
			return CFrame.lookAt(Vector3.new(x, 0, n.Z - edge), Vector3.new(x, 0, n.Z))
		end
		local function southLot(x: number): CFrame
			return CFrame.lookAt(Vector3.new(x, 0, n.Z + edge), Vector3.new(x, 0, n.Z))
		end
		Houses.hollyCottage(hood, northLot(-180))
		Houses.crookedSpire(hood, southLot(-230))
		Houses.gingerbreadLodge(hood, northLot(-300))
		Houses.twinDomes(hood, southLot(-350))
		Houses.curlicueTownhouse(hood, northLot(-420))
		-- Lamp posts along Holly Lane.
		local Props = require(script.Props)
		for x = -140, -500, -60 do
			Props.lamppost(hood, CFrame.lookAt(Vector3.new(x, 0.9, n.Z - edge + 3), Vector3.new(x, 0.9, n.Z)), true)
			Props.lamppost(hood, CFrame.lookAt(Vector3.new(x - 30, 0.9, n.Z + edge - 3), Vector3.new(x - 30, 0.9, n.Z)), true)
		end
		-- Trees between the town and the first lots.
		local rng = Random.new(5)
		for _, z in { -100, 100 } do
			for i = 0, 2 do
				Props.pine(hood, CFrame.new(-128 - i * 6, 0, z + rng:NextNumber(-8, 8)), rng:NextNumber(20, 30), rng)
			end
		end
	end)
	step("Gated community", function()
		Districts.gatedCommunity(map)
	end)
	step("Mansion district", function()
		Districts.mansionDistrict(map)
	end)
	step("Mountain hideout", function()
		Hideout.build(map)
	end)

	-- Interior zone for the cottage, used by the music system to switch states.
	local cottage = map:FindFirstChild("HollyCottage", true)
	if cottage and cottage:IsA("Model") then
		local cf, size = cottage:GetBoundingBox()
		local interior = cottage:FindFirstChild("Interior")
		if interior and interior:IsA("Model") then
			cf, size = interior:GetBoundingBox()
		end
		local zone = Builder.part({ Name = "InteriorZone", Size = size, CFrame = cf, Transparency = 1, CanCollide = false, CastShadow = false, Parent = cottage })
		zone.CanQuery = false
		zone.CanTouch = false
		Builder.tag(zone, "InteriorZone")
	end

	map.Parent = Workspace
	return map
end

return World
