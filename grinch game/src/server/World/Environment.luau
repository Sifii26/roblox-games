--!strict
-- Lighting, terrain (ground, mountain, trail) and the road network.
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Config.Layout)
local P = B.Palette

local Environment = {}

local terrain = Workspace.Terrain

function Environment.lighting()
	Lighting.ClockTime = 0.2
	Lighting.Brightness = 1.2
	Lighting.Ambient = Color3.fromRGB(40, 50, 80)
	Lighting.OutdoorAmbient = Color3.fromRGB(70, 90, 140)
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.4
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.3
	Lighting.GeographicLatitude = 41.7

	local function ensure(className: string, name: string): Instance
		local existing = Lighting:FindFirstChild(name)
		if existing then
			return existing
		end
		local inst = Instance.new(className :: any)
		inst.Name = name
		inst.Parent = Lighting
		return inst
	end

	local atmosphere = ensure("Atmosphere", "WinterAtmosphere") :: Atmosphere
	atmosphere.Density = 0.32
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(120, 140, 190)
	atmosphere.Decay = Color3.fromRGB(40, 50, 90)
	atmosphere.Glare = 0
	atmosphere.Haze = 1.4

	local sky = ensure("Sky", "NightSky") :: Sky
	sky.StarCount = 3000
	sky.MoonAngularSize = 14
	sky.CelestialBodiesShown = true

	local bloom = ensure("BloomEffect", "Glow") :: BloomEffect
	bloom.Intensity = 0.8
	bloom.Size = 28
	bloom.Threshold = 0.95

	local cc = ensure("ColorCorrectionEffect", "WinterGrade") :: ColorCorrectionEffect
	cc.TintColor = Color3.fromRGB(225, 232, 255)
	cc.Saturation = 0.12
	cc.Contrast = 0.08
	cc.Brightness = 0.02
end

-- Ground, nearby mountain with a carved switchback trail, distant peaks.
-- Returns the trail waypoints (useful later for sleigh pathing).
function Environment.terrain(map: Instance): { Vector3 }
	terrain:Clear()
	-- Snowy ground. Top surface sits at y = 0.
	terrain:FillBlock(CFrame.new(0, -6, 150), Vector3.new(2000, 12, 2200), Enum.Material.Snow)

	-- Mountain mass south of town.
	terrain:FillBall(Vector3.new(0, -200, 860), 360, Enum.Material.Snow)
	terrain:FillBall(Vector3.new(0, -120, 570), 200, Enum.Material.Snow)
	terrain:FillBall(Vector3.new(-230, -150, 730), 260, Enum.Material.Snow)
	terrain:FillBall(Vector3.new(230, -150, 730), 260, Enum.Material.Snow)
	-- Rocky outcrops for silhouette.
	terrain:FillBall(Vector3.new(-160, 70, 820), 70, Enum.Material.Rock)
	terrain:FillBall(Vector3.new(170, 50, 800), 60, Enum.Material.Rock)

	-- Plateau for the hideout (top at y = 130).
	local hideout = Layout.Hideout
	terrain:FillCylinder(CFrame.new(hideout.X, 0, hideout.Z), 260, 75, Enum.Material.Snow)
	terrain:FillBall(Vector3.new(hideout.X, hideout.Y + 20, hideout.Z + 125), 95, Enum.Material.Rock)
	-- Cave carved into the cliff behind the plateau.
	terrain:FillBlock(CFrame.new(hideout.X, hideout.Y + 20, hideout.Z + 80), Vector3.new(64, 40, 110), Enum.Material.Air)

	-- Switchback trail: wide ramps with snowy shoulders, carved clear above.
	local points = {
		Vector3.new(0, 0.6, 420),
		Vector3.new(130, 26, 490),
		Vector3.new(-110, 56, 555),
		Vector3.new(120, 86, 615),
		Vector3.new(-70, 114, 655),
		Vector3.new(hideout.X, hideout.Y + 0.6, hideout.Z - 15),
	}
	local trail = B.folder("SummitTrail", map)
	local width = Layout.RoadWidth - 6
	for i = 1, #points - 1 do
		local a, b = points[i], points[i + 1]
		local len = (b - a).Magnitude
		local cf = CFrame.lookAt((a + b) / 2, b)
		terrain:FillBlock(cf * CFrame.new(0, -32, 0), Vector3.new(width + 22, 60, len + 24), Enum.Material.Snow)
		terrain:FillBlock(cf * CFrame.new(0, 18, 0), Vector3.new(width + 10, 34, len + 30), Enum.Material.Air)
		local ramp = B.part({ Name = "TrailRamp", Size = Vector3.new(width, 1.2, len + 2), CFrame = cf * CFrame.new(0, -0.6, 0), Color = P.Ice, Material = Enum.Material.Snow, Parent = trail })
		ramp:SetAttribute("SleighPath", true)
		-- Wooden guard posts with lanterns on the outside edge.
		for t = 0.25, 0.75, 0.5 do
			local postPos = (cf * CFrame.new(width / 2 + 2, 0, (t - 0.5) * len)).Position - Vector3.new(0, 0.6, 0)
			local inward = -Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
			Props.lamppost(trail, CFrame.lookAt(postPos, postPos + inward))
		end
	end
	for i = 2, #points - 1 do
		local p = points[i]
		terrain:FillCylinder(CFrame.new(p.X, p.Y - 30, p.Z), 60, width * 0.9 + 8, Enum.Material.Snow)
		terrain:FillCylinder(CFrame.new(p.X, p.Y + 18, p.Z), 34, width * 0.9 + 4, Enum.Material.Air)
		B.vcyl(trail, "TrailTurn", CFrame.new(p - Vector3.new(0, 0.6, 0)), 1.2, width * 1.8, P.Ice, Enum.Material.Snow)
	end

	-- Distant peaks as low-cost mesh blobs (no terrain cost).
	local far = B.folder("DistantPeaks", map)
	local rng = Random.new(7)
	for i = 0, 15 do
		local a = i / 16 * math.pi * 2
		local r = 1250 + rng:NextNumber(-80, 120)
		local pos = Vector3.new(math.cos(a) * r, 0, math.sin(a) * r + 150)
		local h = rng:NextNumber(260, 480)
		local w = rng:NextNumber(500, 760)
		B.blob(far, "Peak", CFrame.new(pos), Vector3.new(w, h * 2, w * 0.8), P.Rock, Enum.Material.Rock, false)
		B.blob(far, "PeakSnow", CFrame.new(pos + Vector3.new(0, h * 0.55, 0)), Vector3.new(w * 0.6, h * 0.95, w * 0.5), P.Snow, Enum.Material.Snow, false)
	end
	return points
end

-- One straight road segment with sidewalks, center line and snowbanks.
local function road(parent: Instance, name: string, a: Vector3, b: Vector3, opts: { sidewalks: boolean?, banks: boolean? }?)
	local o = opts or {}
	local m = B.model(name, parent)
	local len = (b - a).Magnitude
	local w = Layout.RoadWidth
	local cf = CFrame.lookAt(Vector3.new((a.X + b.X) / 2, 0, (a.Z + b.Z) / 2), Vector3.new(b.X, 0, b.Z))
	local surface = B.part({ Name = "Surface", Size = Vector3.new(w, 1, len), CFrame = cf * CFrame.new(0, 0.1, 0), Color = P.Road, Material = Enum.Material.Asphalt, Parent = m })
	surface:SetAttribute("SleighPath", true)
	-- Packed snow on the edges of the asphalt.
	for _, side in { -1, 1 } do
		B.part({ Name = "EdgeSnow", Size = Vector3.new(4, 1.05, len), CFrame = cf * CFrame.new(side * (w / 2 - 2), 0.12, 0), Color = P.Ice, Material = Enum.Material.Snow, CastShadow = false, Parent = m })
	end
	-- Dashed center line.
	local dashes = math.floor(len / 12)
	for i = 0, dashes - 1 do
		B.part({ Name = "Line", Size = Vector3.new(0.6, 1.02, 5), CFrame = cf * CFrame.new(0, 0.11, -len / 2 + 6 + i * 12), Color = P.RoadLine, CanCollide = false, CastShadow = false, Parent = m })
	end
	if o.sidewalks ~= false then
		for _, side in { -1, 1 } do
			local sw = B.part({ Name = "Sidewalk", Size = Vector3.new(Layout.SidewalkWidth, 1.4, len), CFrame = cf * CFrame.new(side * (w / 2 + Layout.SidewalkWidth / 2), 0.3, 0), Color = P.Sidewalk, Material = Enum.Material.Concrete, Parent = m })
			B.part({ Name = "Curb", Size = Vector3.new(0.6, 1.6, len), CFrame = cf * CFrame.new(side * (w / 2 + 0.3), 0.3, 0), Color = Color3.fromRGB(200, 200, 205), Material = Enum.Material.Concrete, Parent = m })
			B.part({ Name = "SidewalkSnow", Size = Vector3.new(2, 0.3, len), CFrame = sw.CFrame * CFrame.new(-side * (Layout.SidewalkWidth / 2 - 1.2), 0.85, 0), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
		end
	end
	if o.banks ~= false then
		for _, side in { -1, 1 } do
			local off = w / 2 + (if o.sidewalks ~= false then Layout.SidewalkWidth + 2.5 else 3)
			Props.snowbank(m, cf * CFrame.new(side * off, 0, 0) * CFrame.Angles(0, math.pi / 2, 0), len * 0.9, 2.2)
		end
	end
	return m
end

local function pad(parent: Instance, name: string, center: Vector3, size: Vector2)
	local p = B.part({ Name = name, Size = Vector3.new(size.X, 1, size.Y), CFrame = CFrame.new(center.X, 0.1, center.Z), Color = P.Road, Material = Enum.Material.Asphalt, Parent = parent })
	p:SetAttribute("SleighPath", true)
	return p
end

-- Road network. Returns named nodes for future navigation / sleigh routes.
function Environment.roads(map: Instance): { [string]: Vector3 }
	local roads = B.folder("Roads", map)
	local R = Layout.RingRoad
	local W = Layout.RoadWidth
	-- Ring road around the plaza (segments end flush at the corners).
	-- No sidewalks on the ring itself so the side streets join it cleanly;
	-- the plaza has its own paved border.
	road(roads, "RingNorth", Vector3.new(-R + W / 2, 0, -R), Vector3.new(R - W / 2, 0, -R), { sidewalks = false })
	road(roads, "RingSouth", Vector3.new(-R + W / 2, 0, R), Vector3.new(R - W / 2, 0, R), { sidewalks = false })
	road(roads, "RingWest", Vector3.new(-R, 0, -R + W / 2), Vector3.new(-R, 0, R - W / 2), { sidewalks = false })
	road(roads, "RingEast", Vector3.new(R, 0, -R + W / 2), Vector3.new(R, 0, R - W / 2), { sidewalks = false })
	for _, c in { Vector3.new(-R, 0, -R), Vector3.new(R, 0, -R), Vector3.new(-R, 0, R), Vector3.new(R, 0, R) } do
		pad(roads, "Corner", c, Vector2.new(W, W))
	end

	-- West: Holly Lane into the starter neighborhood, ending in a cul-de-sac.
	local n = Layout.Neighborhood
	road(roads, "HollyLane", Vector3.new(-R - W / 2, 0, n.Z), Vector3.new(n.EndX, 0, n.Z), { banks = false })
	local cds = B.vcyl(roads, "CulDeSac", CFrame.new(n.EndX - n.CulDeSacRadius + 10, 0.1, n.Z), 1, n.CulDeSacRadius * 2, P.Road, Enum.Material.Asphalt)
	cds:SetAttribute("SleighPath", true)
	B.vcyl(roads, "CulDeSacIsland", CFrame.new(n.EndX - n.CulDeSacRadius + 10, 0.9, n.Z), 1.6, 22, P.Snow, Enum.Material.Snow)
	Props.pine(roads, CFrame.new(n.EndX - n.CulDeSacRadius + 10, 1.6, n.Z), 22, Random.new(3))

	-- East: Evergreen Way to the gated community entrance (continues past it).
	road(roads, "EvergreenWay", Vector3.new(R + W / 2, 0, 0), Vector3.new(Layout.GatedEntranceX + 300, 0, 0))
	-- North: Mansion Row toward the luxury district (continues past the gate).
	road(roads, "MansionRow", Vector3.new(0, 0, -R - W / 2), Vector3.new(0, 0, Layout.MansionGateZ - 280))
	-- South: Summit Road to the foot of the mountain trail.
	road(roads, "SummitRoad", Vector3.new(0, 0, R + W / 2), Vector3.new(0, 0, 420))
	pad(roads, "TrailHead", Vector3.new(0, 0, 420), Vector2.new(W + 10, W + 10))

	return {
		Plaza = Vector3.new(0, 0, 0),
		NeighborhoodStart = Vector3.new(-R - W / 2, 0, n.Z),
		CulDeSac = Vector3.new(n.EndX - n.CulDeSacRadius + 10, 0, n.Z),
		GatedEntrance = Vector3.new(Layout.GatedEntranceX, 0, 0),
		MansionGate = Vector3.new(0, 0, Layout.MansionGateZ),
		TrailHead = Vector3.new(0, 0, 420),
	}
end

return Environment
