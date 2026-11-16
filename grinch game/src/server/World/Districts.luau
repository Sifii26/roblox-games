--!strict
-- Areas C and D: entrances and boundaries for the Gated Community and the
-- Luxury Mansion District. The gates are closed in Phase 1; the land behind
-- them is reserved (marked with FutureLot parts) for later phases.
local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Config.Layout)
local P = B.Palette

local Districts = {}

local function pillar(parent: Instance, cf: CFrame, height: number, color: Color3, lanternColor: Color3)
	local m = B.model("Pillar", parent)
	B.part({ Name = "Base", Size = Vector3.new(7, 2, 7), CFrame = cf * CFrame.new(0, 1, 0), Color = color, Material = Enum.Material.Cobblestone, Parent = m })
	B.part({ Name = "Column", Size = Vector3.new(5.5, height, 5.5), CFrame = cf * CFrame.new(0, 2 + height / 2, 0), Color = color, Material = Enum.Material.Cobblestone, Parent = m })
	local cap = B.part({ Name = "Cap", Size = Vector3.new(7, 1.2, 7), CFrame = cf * CFrame.new(0, 2.6 + height, 0), Color = color, Material = Enum.Material.Concrete, Parent = m })
	B.snowCap(m, cap, 0.6, 0)
	local lantern = B.part({ Name = "Lantern", Size = Vector3.new(2.4, 3, 2.4), CFrame = cap.CFrame * CFrame.new(0, 2.6, 0), Color = lanternColor, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	B.pointLight(lantern, lanternColor, 28, 1.4)
	-- Mount point for a future security camera.
	local mount = Instance.new("Attachment")
	mount.Name = "CameraMount"
	mount.Position = Vector3.new(0, height / 2 - 1, -3)
	mount.Parent = m:FindFirstChild("Column")
	B.tag(m:FindFirstChild("Column") :: Instance, "CameraMount")
	Props.wreath(m, cf * CFrame.new(0, 2 + height * 0.6, -2.9), 3.6)
	return m
end

-- Iron gate spanning `width`, centered at `cf` (LookVector = outward side).
local function ironGate(parent: Instance, cf: CFrame, width: number, height: number, color: Color3, accent: Color3)
	local m = B.model("Gate", parent)
	B.tag(m, "FutureGate")
	m:SetAttribute("Open", false)
	for _, side in { -1, 1 } do
		local leaf = B.model(if side == -1 then "LeftLeaf" else "RightLeaf", m)
		local lw = width / 2
		local leafCf = cf * CFrame.new(side * lw / 2, 0, 0)
		local bars = math.floor(lw / 1.4)
		for i = 0, bars do
			local x = -lw / 2 + i * (lw / bars)
			-- Bars rise toward the middle for an arched top.
			local t = (x * side + lw / 2) / lw
			local h = height + math.sin(t * math.pi / 2) * 3
			B.part({ Name = "Bar", Size = Vector3.new(0.4, h, 0.4), CFrame = leafCf * CFrame.new(x, h / 2, 0), Color = color, Material = Enum.Material.Metal, Parent = leaf })
			B.ball(leaf, "Finial", (leafCf * CFrame.new(x, h + 0.3, 0)).Position, 0.7, accent, Enum.Material.Metal, false)
		end
		for _, y in { 1.2, height * 0.55, height - 0.8 } do
			B.part({ Name = "Rail", Size = Vector3.new(lw, 0.5, 0.5), CFrame = leafCf * CFrame.new(0, y, 0), Color = color, Material = Enum.Material.Metal, Parent = leaf })
		end
		Props.wreath(leaf, leafCf * CFrame.new(-side * 0.5, height * 0.55, -0.6), 3)
	end
	return m
end

local function wallRun(parent: Instance, a: Vector3, b: Vector3, height: number, color: Color3)
	local len = (b - a).Magnitude
	local cf = CFrame.lookAt((a + b) / 2, b)
	local wall = B.part({ Name = "BoundaryWall", Size = Vector3.new(3, height, len), CFrame = cf * CFrame.new(0, height / 2, 0), Color = color, Material = Enum.Material.Cobblestone, Parent = parent })
	local cap = B.part({ Name = "WallCap", Size = Vector3.new(4, 0.8, len), CFrame = cf * CFrame.new(0, height + 0.4, 0), Color = P.Stone, Material = Enum.Material.Concrete, Parent = parent })
	B.snowCap(parent, cap, 0.5, 0)
	-- Posts every so often break up the long wall.
	local posts = math.floor(len / 40)
	for i = 1, posts - 1 do
		local p = B.part({ Name = "WallPost", Size = Vector3.new(4.5, height + 2, 4.5), CFrame = cf * CFrame.new(0, (height + 2) / 2, -len / 2 + i * (len / posts)), Color = color, Material = Enum.Material.Cobblestone, Parent = parent })
		B.snowCap(parent, p, 0.5, 0)
	end
	return wall
end

local function futureLots(parent: Instance, origin: Vector3, cols: number, rows: number, spacing: Vector2, district: string)
	local folder = B.folder("FutureLots", parent)
	for c = 0, cols - 1 do
		for r = 0, rows - 1 do
			local lot = B.part({ Name = "FutureLot", Size = Vector3.new(spacing.X * 0.8, 0.2, spacing.Y * 0.8), CFrame = CFrame.new(origin + Vector3.new(c * spacing.X, 0.1, r * spacing.Y)), Transparency = 1, CanCollide = false, CastShadow = false, Parent = folder })
			lot.CanQuery = false
			lot.CanTouch = false
			lot:SetAttribute("District", district)
			B.tag(lot, "FutureLot")
		end
	end
end

function Districts.gatedCommunity(map: Instance)
	local area = B.folder("GatedCommunity", map)
	local x = Layout.GatedEntranceX
	local W = Layout.RoadWidth
	local stone = Color3.fromRGB(150, 140, 130)
	-- Gate across the road, facing west toward town.
	local gateCf = CFrame.lookAt(Vector3.new(x, 0.6, 0), Vector3.new(x - 10, 0.6, 0))
	pillar(area, gateCf * CFrame.new(-(W / 2 + 4), 0, 0), 14, stone, P.WarmLight)
	pillar(area, gateCf * CFrame.new(W / 2 + 4, 0, 0), 14, stone, P.WarmLight)
	ironGate(area, gateCf, W + 2, 11, P.Iron, P.Gold)
	-- Entrance arch with name board.
	local beam = B.part({ Name = "ArchBeam", Size = Vector3.new(W + 16, 2.4, 3), CFrame = gateCf * CFrame.new(0, 21, 0), Color = P.DarkWood, Material = Enum.Material.Wood, Parent = area })
	B.snowCap(area, beam, 0.6, 0)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 25
	gui.LightInfluence = 0
	gui.Parent = beam
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "SNOWCREST ESTATES"
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.fromRGB(255, 230, 160)
	label.Parent = gui
	B.stringLights(area, (gateCf * CFrame.new(-(W / 2 + 8), 20, -1.8)).Position, (gateCf * CFrame.new(W / 2 + 8, 20, -1.8)).Position, 2, 1.2, 4)
	-- Guard booth on the right side of the road (from the visitor's view).
	local booth = B.model("GuardBooth", area)
	local bcf = gateCf * CFrame.new(-(W / 2 + 14), 0, -10)
	B.part({ Name = "BoothBase", Size = Vector3.new(10, 1, 10), CFrame = bcf * CFrame.new(0, 0.5, 0), Color = P.Stone, Material = Enum.Material.Concrete, Parent = booth })
	B.part({ Name = "BoothBody", Size = Vector3.new(9, 4, 9), CFrame = bcf * CFrame.new(0, 3, 0), Color = Color3.fromRGB(230, 225, 215), Material = Enum.Material.Plaster, Parent = booth })
	local glass = B.part({ Name = "BoothGlass", Size = Vector3.new(9.1, 4, 9.1), CFrame = bcf * CFrame.new(0, 7, 0), Color = P.Window, Material = Enum.Material.Glass, Transparency = 0.4, Parent = booth })
	B.pointLight(glass, P.WarmLight, 16, 1)
	local roof = B.part({ Name = "BoothRoof", Size = Vector3.new(12, 1, 12), CFrame = bcf * CFrame.new(0, 9.5, 0), Color = Color3.fromRGB(60, 70, 90), Material = Enum.Material.Slate, Parent = booth })
	B.blob(booth, "BoothSnow", roof.CFrame * CFrame.new(0, 0.7, 0), Vector3.new(11, 1.8, 11), P.Snow, Enum.Material.Snow, false)
	local guardSpot = Instance.new("Attachment")
	guardSpot.Name = "GuardSpawn"
	guardSpot.Parent = booth:FindFirstChild("BoothBase")
	guardSpot.Position = Vector3.new(0, 1, 0)
	-- Barrier arm in front of the gate.
	B.part({ Name = "BarrierPost", Size = Vector3.new(1.4, 4, 1.4), CFrame = gateCf * CFrame.new(-(W / 2 + 1), 2, -4), Color = P.Iron, Material = Enum.Material.Metal, Parent = booth })
	for i = 0, 7 do
		B.part({ Name = "BarrierArm", Size = Vector3.new(W / 8, 0.8, 0.8), CFrame = gateCf * CFrame.new(-(W / 2) + (i + 0.5) * (W / 8), 3.6, -4), Color = if i % 2 == 0 then P.Red else P.Snow, Parent = booth })
	end
	-- Boundary walls running north and south from the gate, then east.
	local wh = 10
	wallRun(area, Vector3.new(x, 0.6, -(W / 2 + 7.5)), Vector3.new(x, 0.6, -260), wh, stone)
	wallRun(area, Vector3.new(x, 0.6, W / 2 + 7.5), Vector3.new(x, 0.6, 260), wh, stone)
	wallRun(area, Vector3.new(x, 0.6, -260), Vector3.new(x + 520, 0.6, -260), wh, stone)
	wallRun(area, Vector3.new(x, 0.6, 260), Vector3.new(x + 520, 0.6, 260), wh, stone)
	wallRun(area, Vector3.new(x + 520, 0.6, -260), Vector3.new(x + 520, 0.6, 260), wh, stone)
	-- Trees lining the inside of the wall and reserved lots.
	local rng = Random.new(77)
	for i = 0, 12 do
		Props.pine(area, CFrame.new(x + 30 + i * 38, 0, -236 + rng:NextNumber(-6, 6)), rng:NextNumber(22, 34), rng)
		Props.pine(area, CFrame.new(x + 30 + i * 38, 0, 236 + rng:NextNumber(-6, 6)), rng:NextNumber(22, 34), rng)
	end
	for _, side in { -1, 1 } do
		Props.pine(area, CFrame.new(x - 12, 0, side * 40), 26, rng)
		Props.bush(area, CFrame.new(x - 8, 0, side * 28), 5)
	end
	futureLots(area, Vector3.new(x + 70, 0, -170), 5, 2, Vector2.new(90, 100), "GatedCommunity")
	futureLots(area, Vector3.new(x + 70, 0, 70), 5, 2, Vector2.new(90, 100), "GatedCommunity")
	return area
end

function Districts.mansionDistrict(map: Instance)
	local area = B.folder("MansionDistrict", map)
	local z = Layout.MansionGateZ
	local W = Layout.RoadWidth
	local stone = Color3.fromRGB(205, 200, 195)
	local gateCf = CFrame.lookAt(Vector3.new(0, 0.6, z), Vector3.new(0, 0.6, z + 10))
	pillar(area, gateCf * CFrame.new(-(W / 2 + 4), 0, 0), 18, stone, Color3.fromRGB(255, 220, 150))
	pillar(area, gateCf * CFrame.new(W / 2 + 4, 0, 0), 18, stone, Color3.fromRGB(255, 220, 150))
	ironGate(area, gateCf, W + 2, 14, Color3.fromRGB(30, 30, 34), P.Gold)
	-- Gilded crest above the gate.
	local crest = B.hcyl(area, "Crest", gateCf * CFrame.new(0, 22, 0) * CFrame.Angles(0, math.pi / 2, 0), 1, 8, P.Gold, Enum.Material.Metal, false)
	B.hcyl(area, "CrestInner", crest.CFrame * CFrame.new(-0.3, 0, 0), 0.6, 5.6, P.Red, Enum.Material.SmoothPlastic, false)
	for _, side in { -1, 1 } do
		B.part({ Name = "CrestArm", Size = Vector3.new(W / 2, 0.8, 0.8), CFrame = gateCf * CFrame.new(side * (W / 4 + 3), 21, 0) * CFrame.Angles(0, 0, side * math.rad(-12)), Color = P.Gold, Material = Enum.Material.Metal, Parent = area })
	end
	-- Garland across the gate.
	B.stringLights(area, (gateCf * CFrame.new(-(W / 2 + 4), 22, -1)).Position, (gateCf * CFrame.new(W / 2 + 4, 22, -1)).Position, 2, 2.5, 4)
	local wh = 12
	wallRun(area, Vector3.new(-(W / 2 + 7.5), 0.6, z), Vector3.new(-320, 0.6, z), wh, stone)
	wallRun(area, Vector3.new(W / 2 + 7.5, 0.6, z), Vector3.new(320, 0.6, z), wh, stone)
	wallRun(area, Vector3.new(-320, 0.6, z), Vector3.new(-320, 0.6, z - 560), wh, stone)
	wallRun(area, Vector3.new(320, 0.6, z), Vector3.new(320, 0.6, z - 560), wh, stone)
	wallRun(area, Vector3.new(-320, 0.6, z - 560), Vector3.new(320, 0.6, z - 560), wh, stone)
	-- Avenue of tall trees leading up to the gate (town side).
	local rng = Random.new(91)
	for i = 0, 4 do
		for _, side in { -1, 1 } do
			Props.pine(area, CFrame.new(side * (W / 2 + 18), 0, z + 30 + i * 36), rng:NextNumber(30, 38), rng)
		end
	end
	futureLots(area, Vector3.new(-200, 0, z - 140), 3, 2, Vector2.new(200, 220), "MansionDistrict")
	return area
end

return Districts
