--!strict
-- Reusable decorative props. Each function returns a Model placed at `cf`
-- (cf = position on the ground, facing its LookVector).
local B = require(script.Parent.Builder)
local P = B.Palette

local Props = {}

-- Stylized snowy pine: stacked rounded tiers with snow on each tier.
function Props.pine(parent: Instance, cf: CFrame, height: number, rng: Random?): Model
	local r = rng or Random.new()
	local m = B.model("Pine", parent)
	local trunkH = height * 0.18
	B.vcyl(m, "Trunk", cf * CFrame.new(0, trunkH / 2, 0), trunkH, height * 0.09, P.DarkWood, Enum.Material.Wood)
	local tiers = 4
	local y = trunkH * 0.7
	local tierH = (height - trunkH) / tiers * 1.25
	for i = 1, tiers do
		local w = height * 0.55 * (1 - (i - 1) / (tiers + 0.6))
		local lean = CFrame.Angles(r:NextNumber(-0.05, 0.05), r:NextNumber(0, math.pi * 2), r:NextNumber(-0.05, 0.05))
		local tierCf = cf * CFrame.new(0, y + tierH / 2, 0) * lean
		B.blob(m, "Tier", tierCf, Vector3.new(w, tierH, w), if i % 2 == 0 then P.Pine else P.PineDark, Enum.Material.Grass, i == 1)
		B.blob(m, "TierSnow", tierCf * CFrame.new(0, tierH * 0.28, 0), Vector3.new(w * 0.8, tierH * 0.45, w * 0.8), P.Snow, Enum.Material.Snow, false)
		y += tierH * 0.62
	end
	B.blob(m, "TopSnow", cf * CFrame.new(0, y + tierH * 0.25, 0), Vector3.new(height * 0.12, tierH * 0.5, height * 0.12), P.Snow, Enum.Material.Snow, false)
	return m
end

function Props.lamppost(parent: Instance, cf: CFrame, withWreath: boolean?): Model
	local m = B.model("Lamppost", parent)
	B.vcyl(m, "Base", cf * CFrame.new(0, 0.6, 0), 1.2, 1.8, P.Iron, Enum.Material.Metal)
	B.vcyl(m, "Pole", cf * CFrame.new(0, 7, 0), 12, 0.6, P.Iron, Enum.Material.Metal)
	-- Curled arm
	B.part({ Name = "Arm", Size = Vector3.new(0.4, 0.4, 2.6), CFrame = cf * CFrame.new(0, 12.8, -1.1), Color = P.Iron, Material = Enum.Material.Metal, Parent = m })
	B.ball(m, "Curl", (cf * CFrame.new(0, 13.2, 0.3)).Position, 0.8, P.Iron, Enum.Material.Metal)
	local lantern = B.part({ Name = "Lantern", Size = Vector3.new(1.4, 1.8, 1.4), CFrame = cf * CFrame.new(0, 11.6, -2.3), Color = P.Window, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	B.part({ Name = "LanternCap", Size = Vector3.new(1.9, 0.4, 1.9), CFrame = lantern.CFrame * CFrame.new(0, 1.1, 0), Color = P.Iron, Material = Enum.Material.Metal, Parent = m })
	B.part({ Name = "CapSnow", Size = Vector3.new(1.7, 0.35, 1.7), CFrame = lantern.CFrame * CFrame.new(0, 1.45, 0), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, Parent = m })
	B.pointLight(lantern, P.WarmLight, 26, 1.4, false)
	if withWreath then
		local w = B.hcyl(m, "Wreath", cf * CFrame.new(0, 8.5, -0.45) * CFrame.Angles(0, math.pi / 2, 0), 0.4, 2.2, P.Green, Enum.Material.Grass, false)
		B.ball(m, "Bow", (w.CFrame * CFrame.new(-0.25, 0.9, 0)).Position, 0.6, P.Red, Enum.Material.SmoothPlastic, false)
	end
	return m
end

function Props.bench(parent: Instance, cf: CFrame): Model
	local m = B.model("Bench", parent)
	for _, x in { -2.4, 2.4 } do
		B.part({ Name = "Leg", Size = Vector3.new(0.4, 2, 2), CFrame = cf * CFrame.new(x, 1, 0), Color = P.Iron, Material = Enum.Material.Metal, Parent = m })
	end
	for i = 0, 2 do
		B.part({ Name = "Slat", Size = Vector3.new(6, 0.25, 0.55), CFrame = cf * CFrame.new(0, 2.1, -0.65 + i * 0.65), Color = P.Wood, Material = Enum.Material.Wood, Parent = m })
	end
	local back = B.part({ Name = "Back", Size = Vector3.new(6, 1.6, 0.25), CFrame = cf * CFrame.new(0, 3.2, 1) * CFrame.Angles(-0.15, 0, 0), Color = P.Wood, Material = Enum.Material.Wood, Parent = m })
	B.part({ Name = "Snow", Size = Vector3.new(5.6, 0.35, 1.6), CFrame = cf * CFrame.new(0, 2.4, -0.1), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
	B.snowCap(m, back, 0.25, 0)
	return m
end

-- Picket fence running along local X for `length` studs.
function Props.fence(parent: Instance, cf: CFrame, length: number, color: Color3?): Model
	local m = B.model("Fence", parent)
	local c = color or Color3.fromRGB(240, 236, 228)
	local count = math.floor(length / 1.6)
	for i = 0, count do
		local x = -length / 2 + i * (length / count)
		local picket = B.part({ Name = "Picket", Size = Vector3.new(0.6, 3.2, 0.25), CFrame = cf * CFrame.new(x, 1.6, 0), Color = c, Material = Enum.Material.Wood, Parent = m })
		B.part({ Name = "PicketSnow", Size = Vector3.new(0.7, 0.25, 0.4), CFrame = picket.CFrame * CFrame.new(0, 1.7, 0), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
	end
	for _, y in { 1, 2.4 } do
		B.part({ Name = "Rail", Size = Vector3.new(length, 0.3, 0.2), CFrame = cf * CFrame.new(0, y, 0.2), Color = c, Material = Enum.Material.Wood, Parent = m })
	end
	return m
end

function Props.mailbox(parent: Instance, cf: CFrame, color: Color3): Model
	local m = B.model("Mailbox", parent)
	B.part({ Name = "Post", Size = Vector3.new(0.5, 3.6, 0.5), CFrame = cf * CFrame.new(0, 1.8, 0), Color = P.Wood, Material = Enum.Material.Wood, Parent = m })
	local box = B.hcyl(m, "Box", cf * CFrame.new(0, 4, 0) * CFrame.Angles(0, math.pi / 2, 0), 2.2, 1.3, color, Enum.Material.Metal)
	B.part({ Name = "Flag", Size = Vector3.new(0.1, 0.8, 0.3), CFrame = cf * CFrame.new(0.7, 4.5, 0.3), Color = P.Red, Parent = m })
	B.blob(m, "Snow", box.CFrame * CFrame.new(0, 0.55, 0), Vector3.new(2, 0.5, 1.1), P.Snow, Enum.Material.Snow, false)
	return m
end

function Props.snowman(parent: Instance, cf: CFrame, scale: number?): Model
	local s = scale or 1
	local m = B.model("Snowman", parent)
	B.ball(m, "Bottom", (cf * CFrame.new(0, 2 * s, 0)).Position, 4.2 * s, P.Snow, Enum.Material.Snow)
	B.ball(m, "Middle", (cf * CFrame.new(0, 5.2 * s, 0)).Position, 3.1 * s, P.Snow, Enum.Material.Snow)
	local head = B.ball(m, "Head", (cf * CFrame.new(0, 7.6 * s, 0)).Position, 2.2 * s, P.Snow, Enum.Material.Snow)
	local face = CFrame.lookAt(head.Position, head.Position + cf.LookVector)
	B.part({ Name = "Nose", Size = Vector3.new(0.3, 0.3, 1.2) * s, CFrame = face * CFrame.new(0, 0, -1.3 * s), Color = Color3.fromRGB(240, 130, 40), CanCollide = false, Parent = m })
	for _, x in { -0.4, 0.4 } do
		B.ball(m, "Eye", (face * CFrame.new(x * s, 0.35 * s, -1 * s)).Position, 0.28 * s, P.Iron, nil, false)
	end
	B.vcyl(m, "HatBrim", face * CFrame.new(0, 1 * s, 0), 0.2 * s, 2.4 * s, P.Iron)
	B.vcyl(m, "Hat", face * CFrame.new(0, 1.8 * s, 0), 1.5 * s, 1.6 * s, P.Iron)
	B.vcyl(m, "Scarf", cf * CFrame.new(0, 6.6 * s, 0), 0.5 * s, 2.5 * s, P.Red, Enum.Material.Fabric, false)
	return m
end

function Props.present(parent: Instance, cf: CFrame, size: Vector3, color: Color3, ribbon: Color3?): Model
	local m = B.model("Present", parent)
	local box = B.part({ Name = "Box", Size = size, CFrame = cf * CFrame.new(0, size.Y / 2, 0), Color = color, Parent = m })
	local rc = ribbon or P.Gold
	B.part({ Name = "RibbonX", Size = Vector3.new(size.X + 0.05, size.Y + 0.05, size.Z * 0.18), CFrame = box.CFrame, Color = rc, CanCollide = false, Parent = m })
	B.part({ Name = "RibbonZ", Size = Vector3.new(size.X * 0.18, size.Y + 0.05, size.Z + 0.05), CFrame = box.CFrame, Color = rc, CanCollide = false, Parent = m })
	B.ball(m, "Bow", (box.CFrame * CFrame.new(0, size.Y / 2 + 0.15, 0)).Position, math.min(size.X, size.Z) * 0.35, rc, nil, false)
	m.PrimaryPart = box
	return m
end

function Props.wreath(parent: Instance, cf: CFrame, diameter: number?): Model
	local d = diameter or 3
	local m = B.model("Wreath", parent)
	local ring = B.hcyl(m, "Ring", cf * CFrame.Angles(0, math.pi / 2, 0), 0.5, d, P.Green, Enum.Material.Grass, false)
	B.hcyl(m, "Hole", ring.CFrame * CFrame.new(0.05, 0, 0), 0.52, d * 0.45, P.DarkWood, Enum.Material.Wood, false)
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		B.ball(m, "Berry", (cf * CFrame.new(math.cos(a) * d * 0.36, math.sin(a) * d * 0.36, -0.3)).Position, 0.35, P.Red, nil, false)
	end
	B.ball(m, "Bow", (cf * CFrame.new(0, -d * 0.4, -0.35)).Position, 0.7, P.Red, nil, false)
	return m
end

-- Soft snowbank along local X.
function Props.snowbank(parent: Instance, cf: CFrame, length: number, height: number?): Model
	local m = B.model("Snowbank", parent)
	local h = height or 2.5
	local pieces = math.max(1, math.floor(length / 10))
	for i = 1, pieces do
		local x = -length / 2 + (i - 0.5) * (length / pieces)
		B.blob(m, "Bank", cf * CFrame.new(x, h * 0.25, 0), Vector3.new(length / pieces * 1.35, h, 4), P.Snow, Enum.Material.Snow, false)
	end
	return m
end

function Props.bush(parent: Instance, cf: CFrame, size: number): Model
	local m = B.model("Bush", parent)
	B.blob(m, "Leaves", cf * CFrame.new(0, size * 0.35, 0), Vector3.new(size, size * 0.8, size), P.PineDark, Enum.Material.Grass, true)
	B.blob(m, "Snow", cf * CFrame.new(0, size * 0.6, 0), Vector3.new(size * 0.8, size * 0.4, size * 0.8), P.Snow, Enum.Material.Snow, false)
	return m
end

function Props.streetSign(parent: Instance, cf: CFrame, text: string): Model
	local m = B.model("StreetSign", parent)
	B.vcyl(m, "Pole", cf * CFrame.new(0, 5, 0), 10, 0.4, P.Iron, Enum.Material.Metal)
	local board = B.part({ Name = "Board", Size = Vector3.new(6, 1.3, 0.2), CFrame = cf * CFrame.new(0, 9.6, 0), Color = Color3.fromRGB(30, 90, 60), Material = Enum.Material.Metal, Parent = m })
	B.snowCap(m, board, 0.25, 0)
	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.PixelsPerStud = 40
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Parent = gui
	end
	return m
end

-- A candy cane (straight shaft plus a hook of small spheres).
function Props.candyCane(parent: Instance, cf: CFrame, height: number): Model
	local m = B.model("CandyCane", parent)
	local segs = math.floor(height / 0.8)
	for i = 0, segs do
		B.vcyl(m, "Shaft", cf * CFrame.new(0, i * 0.8 + 0.4, 0), 0.8, 0.8, if i % 2 == 0 then P.Red else P.Snow, nil, false)
	end
	for i = 1, 6 do
		local a = i / 6 * math.pi
		B.ball(m, "Hook", (cf * CFrame.new(-(1 - math.cos(a)) * 0.9, segs * 0.8 + 0.8 + math.sin(a) * 0.9, 0)).Position, 0.85, if i % 2 == 0 then P.Red else P.Snow, nil, false)
	end
	return m
end

return Props
