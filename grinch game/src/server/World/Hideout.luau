--!strict
-- Area E: the mountain hideout. A cave workshop carved into the cliff behind
-- the plateau, sleigh storage, a dog corner, and a lookout deck over town.
-- Cave interior (world): x -32..32, y 130..170, z 725..835 (see Environment).
local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Config.Layout)
local P = B.Palette

local Hideout = {}

local function lantern(parent: Instance, pos: Vector3, color: Color3?)
	local c = color or Color3.fromRGB(255, 190, 110)
	B.part({ Name = "Chain", Size = Vector3.new(0.2, 4, 0.2), CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)), Color = P.Iron, Material = Enum.Material.Metal, CanCollide = false, Parent = parent })
	local glow = B.part({ Name = "Lantern", Size = Vector3.new(1.4, 1.8, 1.4), CFrame = CFrame.new(pos), Color = c, Material = Enum.Material.Neon, CanCollide = false, CastShadow = false, Parent = parent })
	B.part({ Name = "LanternCap", Size = Vector3.new(1.8, 0.4, 1.8), CFrame = CFrame.new(pos + Vector3.new(0, 1.1, 0)), Color = P.Iron, Material = Enum.Material.Metal, CanCollide = false, Parent = parent })
	B.pointLight(glow, c, 24, 1.2, true)
	B.tag(glow, "Flicker")
	return glow
end

local function marker(parent: Instance, name: string, cf: CFrame, size: Vector3, tag: string)
	local p = B.part({ Name = name, Size = size, CFrame = cf, Transparency = 1, CanCollide = false, CastShadow = false, Parent = parent })
	p.CanQuery = false
	p.CanTouch = false
	B.tag(p, tag)
	return p
end

function Hideout.build(map: Instance)
	local area = B.folder("MountainHideout", map)
	local h = Layout.Hideout
	local fy = h.Y
	local wood = Color3.fromRGB(105, 75, 50)
	local oldWood = Color3.fromRGB(85, 70, 60)
	local function at(x: number, y: number, z: number, yaw: number?): CFrame
		return CFrame.new(h.X + x, fy + y, z) * CFrame.Angles(0, yaw or 0, 0)
	end

	-- Cave floor (smooth surface over the voxel floor).
	B.part({ Name = "CaveFloor", Size = Vector3.new(62, 1, 108), CFrame = at(0, 0.1, 780), Color = Color3.fromRGB(80, 78, 84), Material = Enum.Material.Slate, Parent = area })
	-- Plank floor in the living corner.
	B.part({ Name = "PlankFloor", Size = Vector3.new(26, 0.3, 26), CFrame = at(-17, 0.75, 812), Color = oldWood, Material = Enum.Material.WoodPlanks, Parent = area })

	-- Entrance timber frame, slightly crooked, with a hand-made sign.
	local entrance = B.model("Entrance", area)
	B.part({ Name = "Post", Size = Vector3.new(2.6, 26, 2.6), CFrame = at(-17, 13, 729) * CFrame.Angles(0, 0, math.rad(3)), Color = wood, Material = Enum.Material.Wood, Parent = entrance })
	B.part({ Name = "Post", Size = Vector3.new(2.6, 26, 2.6), CFrame = at(17, 13, 729) * CFrame.Angles(0, 0, math.rad(-2)), Color = wood, Material = Enum.Material.Wood, Parent = entrance })
	local beam = B.part({ Name = "Beam", Size = Vector3.new(40, 2.6, 2.6), CFrame = at(0, 26, 729) * CFrame.Angles(0, 0, math.rad(1.5)), Color = wood, Material = Enum.Material.Wood, Parent = entrance })
	B.snowCap(entrance, beam, 0.6, 0)
	local sign = B.part({ Name = "Sign", Size = Vector3.new(10, 3, 0.4), CFrame = at(0, 22, 727.6) * CFrame.Angles(0, 0, math.rad(-6)), Color = oldWood, Material = Enum.Material.WoodPlanks, Parent = entrance })
	for _, sx in { -3.5, 3.5 } do
		B.part({ Name = "Rope", Size = Vector3.new(0.15, 2.4, 0.15), CFrame = sign.CFrame * CFrame.new(sx, 2.2, 0), Color = Color3.fromRGB(170, 150, 110), CanCollide = false, Parent = entrance })
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.Parent = sign
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "KEEP OUT!!"
	label.TextScaled = true
	label.Font = Enum.Font.Creepster
	label.TextColor3 = Color3.fromRGB(150, 220, 90)
	label.Parent = gui
	lantern(entrance, (at(-14, 20, 726)).Position, Color3.fromRGB(170, 255, 120))
	lantern(entrance, (at(14, 20, 726)).Position, Color3.fromRGB(170, 255, 120))
	Props.snowbank(entrance, at(-24, 0, 724), 12, 4)
	Props.snowbank(entrance, at(24, 0, 724), 12, 4)

	-- Interior support beams.
	for _, z in { 755, 785, 815 } do
		for _, sx in { -1, 1 } do
			B.part({ Name = "Support", Size = Vector3.new(2, 38, 2), CFrame = at(sx * 28, 19, z), Color = wood, Material = Enum.Material.Wood, Parent = area })
		end
		B.part({ Name = "CrossBeam", Size = Vector3.new(58, 2, 2), CFrame = at(0, 37, z), Color = wood, Material = Enum.Material.Wood, Parent = area })
		lantern(area, (at(0, 33, z)).Position)
	end

	---------------------------------------------------------------- Workshop
	local shop = B.model("Workshop", area)
	local bench = B.part({ Name = "Workbench", Size = Vector3.new(16, 0.8, 5), CFrame = at(-22, 3.6, 770), Color = wood, Material = Enum.Material.WoodPlanks, Parent = shop })
	for _, sx in { -7, 7 } do
		for _, sz in { -2, 2 } do
			B.part({ Name = "Leg", Size = Vector3.new(0.8, 3.4, 0.8), CFrame = bench.CFrame * CFrame.new(sx, -2, sz), Color = oldWood, Material = Enum.Material.Wood, Parent = shop })
		end
	end
	B.part({ Name = "Vise", Size = Vector3.new(1.4, 1.2, 1.6), CFrame = bench.CFrame * CFrame.new(-6, 1, -1.5), Color = P.Iron, Material = Enum.Material.Metal, Parent = shop })
	B.part({ Name = "Hammer", Size = Vector3.new(0.3, 0.3, 2.4), CFrame = bench.CFrame * CFrame.new(-2, 0.55, 0) * CFrame.Angles(0, 0.6, 0), Color = oldWood, CanCollide = false, Parent = shop })
	B.part({ Name = "HammerHead", Size = Vector3.new(1, 0.6, 0.6), CFrame = bench.CFrame * CFrame.new(-1.3, 0.6, -1) * CFrame.Angles(0, 0.6, 0), Color = P.Iron, Material = Enum.Material.Metal, CanCollide = false, Parent = shop })
	-- Blueprint of a sleigh pinned to the bench.
	B.part({ Name = "Blueprint", Size = Vector3.new(4, 0.05, 3), CFrame = bench.CFrame * CFrame.new(3, 0.43, 0) * CFrame.Angles(0, -0.2, 0), Color = Color3.fromRGB(70, 110, 190), CanCollide = false, Parent = shop })
	-- Pegboard with tools.
	local board = B.part({ Name = "Pegboard", Size = Vector3.new(0.4, 8, 16), CFrame = at(-30.5, 8, 770), Color = Color3.fromRGB(150, 120, 80), Material = Enum.Material.WoodPlanks, Parent = shop })
	for i = 0, 5 do
		B.part({ Name = "Tool", Size = Vector3.new(0.3, 2.6, 0.5), CFrame = board.CFrame * CFrame.new(0.4, (i % 2) * 1.5, -6 + i * 2.4) * CFrame.Angles(0.3 * (i % 3 - 1), 0, 0), Color = if i % 2 == 0 then P.Iron else P.Red, Material = Enum.Material.Metal, CanCollide = false, Parent = shop })
	end
	-- Scrap pile: wheels, gears, an old ski.
	for i = 0, 3 do
		B.hcyl(shop, "Wheel", at(-25 + i * 2.5, 1.2 + (i % 2) * 1.6, 790) * CFrame.Angles(0, math.pi / 2, 0.5 * i), 0.6, 3 + i * 0.3, oldWood, Enum.Material.Wood)
	end
	B.part({ Name = "OldSki", Size = Vector3.new(0.6, 0.3, 9), CFrame = at(-28, 3, 795) * CFrame.Angles(0.9, 0.2, 0), Color = Color3.fromRGB(160, 50, 40), Parent = shop })
	-- Future: the upgrade menu opens from here.
	local upgradeMarker = marker(shop, "UpgradeBench", bench.CFrame * CFrame.new(0, 2, -4), Vector3.new(16, 6, 6), "UpgradeBench")
	upgradeMarker:SetAttribute("Purpose", "Opens the upgrade shop in a later phase")

	---------------------------------------------------------------- Sleigh storage
	local garage = B.model("SleighStorage", area)
	local deck = B.part({ Name = "SleighPlatform", Size = Vector3.new(24, 1, 38), CFrame = at(17, 0.9, 772), Color = oldWood, Material = Enum.Material.WoodPlanks, Parent = garage })
	for _, sx in { -12.5, 12.5 } do
		B.part({ Name = "Curb", Size = Vector3.new(1, 1.6, 38), CFrame = deck.CFrame * CFrame.new(sx, 0.8, 0), Color = wood, Material = Enum.Material.Wood, Parent = garage })
	end
	local sleighSpawn = Instance.new("Attachment")
	sleighSpawn.Name = "SleighSpawn"
	sleighSpawn.Position = Vector3.new(0, 1, 0)
	sleighSpawn.Parent = deck
	B.tag(deck, "SleighStorage")
	-- Hanging harness and a tarp rolled up on hooks.
	B.part({ Name = "Harness", Size = Vector3.new(4, 0.3, 0.3), CFrame = at(17, 10, 752), Color = Color3.fromRGB(120, 60, 40), Material = Enum.Material.Fabric, CanCollide = false, Parent = garage })
	B.hcyl(garage, "Tarp", at(17, 14, 792), 18, 2, Color3.fromRGB(90, 110, 80), Enum.Material.Fabric, false)

	---------------------------------------------------------------- Dog corner
	local dog = B.model("DogCorner", area)
	B.vcyl(dog, "DogBed", at(22, 1.1, 805), 1.2, 7, Color3.fromRGB(160, 60, 60), Enum.Material.Fabric)
	B.vcyl(dog, "DogBedInner", at(22, 1.5, 805), 0.6, 5.4, Color3.fromRGB(220, 200, 170), Enum.Material.Fabric)
	B.vcyl(dog, "Bowl", at(17, 1, 808), 0.8, 2, Color3.fromRGB(80, 120, 200), Enum.Material.Metal)
	B.ball(dog, "Bone", (at(19, 1.2, 802)).Position, 0.8, P.Snow, nil, false)
	local dogSpawn = Instance.new("Attachment")
	dogSpawn.Name = "DogSpawn"
	dogSpawn.Parent = dog:FindFirstChild("DogBed")

	---------------------------------------------------------------- Living corner
	local den = B.model("Den", area)
	local chairCf = at(-18, 0.9, 812, math.rad(160))
	B.part({ Name = "ChairSeat", Size = Vector3.new(5, 2, 5), CFrame = chairCf * CFrame.new(0, 1.2, 0) * CFrame.Angles(0, 0, math.rad(4)), Color = Color3.fromRGB(110, 130, 60), Material = Enum.Material.Fabric, Parent = den })
	B.part({ Name = "ChairBack", Size = Vector3.new(5, 6, 1.2), CFrame = chairCf * CFrame.new(0, 4, 2) * CFrame.Angles(0.15, 0, math.rad(-5)), Color = Color3.fromRGB(110, 130, 60), Material = Enum.Material.Fabric, Parent = den })
	-- Pot-bellied stove with a flickering fire.
	B.vcyl(den, "Stove", at(-26, 3.5, 820), 5, 4.5, P.Iron, Enum.Material.Metal)
	B.vcyl(den, "StovePipe", at(-26, 20, 820), 28, 1.2, P.Iron, Enum.Material.Metal)
	local fire = B.part({ Name = "StoveFire", Size = Vector3.new(1.6, 1.6, 0.2), CFrame = at(-26, 3, 817.7), Color = Color3.fromRGB(255, 130, 40), Material = Enum.Material.Neon, CanCollide = false, Parent = den })
	B.pointLight(fire, Color3.fromRGB(255, 140, 60), 18, 1.5, true)
	B.tag(fire, "Flicker")
	B.part({ Name = "Rug", Size = Vector3.new(12, 0.1, 9), CFrame = at(-16, 0.95, 818), Color = Color3.fromRGB(120, 50, 70), Material = Enum.Material.Fabric, CanCollide = false, Parent = den })

	---------------------------------------------------------------- Loot pile
	local loot = B.model("LootPile", area)
	marker(loot, "LootDropZone", at(10, 3, 826), Vector3.new(24, 6, 14), "LootDropZone")
	for i = 0, 4 do
		B.blob(loot, "Sack", at(3 + i * 3.5, 1.8, 828 + (i % 2) * 2), Vector3.new(3, 3.4, 3), Color3.fromRGB(150, 120, 80), Enum.Material.Fabric, true)
	end

	---------------------------------------------------------------- Lookout deck
	local look = B.model("LookoutDeck", area)
	local deckCf = CFrame.lookAt(Vector3.new(h.X + 46, fy + 1, h.Z - 48), Vector3.new(0, fy + 1, 0))
	local platform = B.part({ Name = "Deck", Size = Vector3.new(26, 1, 22), CFrame = deckCf, Color = oldWood, Material = Enum.Material.WoodPlanks, Parent = look })
	B.part({ Name = "DeckSnow", Size = Vector3.new(4, 0.3, 22), CFrame = platform.CFrame * CFrame.new(-11, 0.6, 0), Color = P.Snow, Material = Enum.Material.Snow, CanCollide = false, CastShadow = false, Parent = look })
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			B.part({ Name = "Stilt", Size = Vector3.new(1.5, 30, 1.5), CFrame = platform.CFrame * CFrame.new(sx * 12, -15, sz * 10), Color = wood, Material = Enum.Material.Wood, Parent = look })
		end
	end
	-- Railing on the open three sides.
	for _, r in { { Vector3.new(26, 0.5, 0.5), Vector3.new(0, 3.5, -11) }, { Vector3.new(0.5, 0.5, 22), Vector3.new(-13, 3.5, 0) }, { Vector3.new(0.5, 0.5, 22), Vector3.new(13, 3.5, 0) } } do
		local rail = B.part({ Name = "Rail", Size = r[1], CFrame = platform.CFrame * CFrame.new(r[2]), Color = wood, Material = Enum.Material.Wood, Parent = look })
		B.snowCap(look, rail, 0.25, 0)
	end
	for i = 0, 6 do
		B.part({ Name = "Baluster", Size = Vector3.new(0.4, 3.2, 0.4), CFrame = platform.CFrame * CFrame.new(-12 + i * 4, 2, -11), Color = wood, Material = Enum.Material.Wood, Parent = look })
	end
	-- Telescope pointed at town.
	B.part({ Name = "Tripod", Size = Vector3.new(0.4, 4, 0.4), CFrame = platform.CFrame * CFrame.new(0, 2.5, -7), Color = oldWood, Parent = look })
	B.hcyl(look, "Telescope", platform.CFrame * CFrame.new(0, 4.8, -8) * CFrame.Angles(0, math.pi / 2, math.rad(-8)), 4.5, 1, P.Gold, Enum.Material.Metal, false)
	B.stringLights(look, (platform.CFrame * CFrame.new(-13, 4, -11)).Position, (platform.CFrame * CFrame.new(13, 4, -11)).Position, 2, 0.6, 4)
	local launch = marker(look, "SleighLaunch", platform.CFrame * CFrame.new(0, 2, 0), Vector3.new(20, 4, 18), "SleighLaunch")
	launch:SetAttribute("Purpose", "Future sleigh take-off point")

	-- Trail-end signpost.
	Props.streetSign(area, at(-30, 0, h.Z - 8) * CFrame.Angles(0, math.rad(30), 0), "Hideout")
	-- Plateau trees.
	local rng = Random.new(101)
	for _, deg in { -20, 0, 20, 40, 140, 160, 180 } do
		local a = math.rad(deg)
		Props.pine(area, CFrame.new(h.X + math.cos(a) * 62, fy, h.Z + math.sin(a) * 62 + 10), rng:NextNumber(18, 28), rng)
	end
	return area
end

return Hideout
