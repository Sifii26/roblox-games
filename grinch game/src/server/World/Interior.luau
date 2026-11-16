--!strict
-- Furnished interior for Holly Cottage.
-- Layout (house-local studs, front wall at z = -20, back wall at z = +20):
--   Living room  x -28..-6, z -20..6   (fireplace, sofa, Christmas tree)
--   Den          x -28..-6, z  6..20   (bookshelf, armchairs, toy chest)
--   Hallway      x  -6.. 2, z -20..20  (front door at x = -3)
--   Kitchen      x   2..28, z -20..4   (counters, stove, fridge, table)
--   Bedroom      x   2..28, z  4..20   (bed, nightstands, dresser)
-- Ceiling height is 14 studs, doorways 6 x 9, sized for R15/R6 characters.
local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local HP = require(script.Parent.HouseParts)
local P = B.Palette

local Interior = {}

export type Opts = { width: number, depth: number, wallHeight: number, floorY: number, trim: Color3 }

function Interior.build(house: Model, H: CFrame, o: Opts)
	local m = B.model("Interior", house)
	local spots = B.folder("PresentSpots", house)
	local fy = o.floorY + 0.2 -- top of the floorboards
	local WH = o.wallHeight
	local function at(x: number, y: number, z: number, yaw: number?): CFrame
		return H * CFrame.new(x, fy + y, z) * CFrame.Angles(0, yaw or 0, 0)
	end
	local function box(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?, collide: boolean?)
		return B.part({ Name = name, Size = size, CFrame = cf, Color = color, Material = mat, CanCollide = collide, Parent = m })
	end

	local wallpaper = Color3.fromRGB(236, 222, 196)
	local denPaper = Color3.fromRGB(170, 200, 180)
	local bedPaper = Color3.fromRGB(200, 190, 225)
	local wood = Color3.fromRGB(150, 100, 62)
	local fabricRed = Color3.fromRGB(160, 40, 50)

	-- Floors.
	box("Floor", Vector3.new(o.width - 1, 0.2, o.depth - 1), H * CFrame.new(0, o.floorY + 0.1, 0), Color3.fromRGB(160, 110, 70), Enum.Material.WoodPlanks)
	box("KitchenTile", Vector3.new(25, 0.05, 23), at(15, 0.02, -8), Color3.fromRGB(235, 235, 240), Enum.Material.Marble, false)

	-- Interior walls (offsets measured from each wall's start point).
	local function wallAt(x: number, z: number, alongZ: boolean): CFrame
		local cf = H * CFrame.new(x, o.floorY, z)
		return if alongZ then cf * CFrame.Angles(0, -math.pi / 2, 0) else cf
	end
	B.wall(m, "HallWallWest", wallAt(-6, -20, true), 40, WH, 0.8, wallpaper, Enum.Material.SmoothPlastic, {
		{ x = 5, w = 12, y = 0, h = 10 }, -- wide opening into the living room
		{ x = 29, w = 6, y = 0, h = 9 }, -- den door
	})
	B.wall(m, "HallWallEast", wallAt(2, -20, true), 40, WH, 0.8, wallpaper, Enum.Material.SmoothPlastic, {
		{ x = 6, w = 9, y = 0, h = 10 }, -- kitchen opening
		{ x = 29, w = 6, y = 0, h = 9 }, -- bedroom door
	})
	B.wall(m, "LivingDenWall", wallAt(-28, 6, false), 22, WH, 0.8, denPaper, Enum.Material.SmoothPlastic)
	B.wall(m, "KitchenBedWall", wallAt(2, 4, false), 26, WH, 0.8, bedPaper, Enum.Material.SmoothPlastic)
	-- Baseboards along every room (cheap detail that sells the interior).
	local base = Color3.fromRGB(250, 246, 238)
	for _, seg in {
		{ Vector3.new(21, 0.8, 0.3), Vector3.new(-17, 0.4, -19.3) },
		{ Vector3.new(21, 0.8, 0.3), Vector3.new(-17, 0.4, 19.3) },
		{ Vector3.new(25, 0.8, 0.3), Vector3.new(15, 0.4, 19.3) },
		{ Vector3.new(25, 0.8, 0.3), Vector3.new(15, 0.4, -19.3) },
		{ Vector3.new(0.3, 0.8, 39), Vector3.new(-27.3, 0.4, 0) },
		{ Vector3.new(0.3, 0.8, 39), Vector3.new(27.3, 0.4, 0) },
	} do
		box("Baseboard", seg[1], at(seg[2].X, seg[2].Y, seg[2].Z), base, Enum.Material.Wood, false)
	end

	-- Ceiling lights, one per room.
	local function ceilingLight(x: number, z: number, range: number)
		local fixture = box("CeilingLight", Vector3.new(2.4, 0.5, 2.4), at(x, WH - 0.5, z), Color3.fromRGB(255, 230, 180), Enum.Material.Neon, false)
		fixture.CastShadow = false
		B.pointLight(fixture, P.WarmLight, range, 0.9, true)
	end
	ceilingLight(-17, -8, 22)
	ceilingLight(-17, 13, 16)
	ceilingLight(-2, 0, 16)
	ceilingLight(15, -8, 20)
	ceilingLight(15, 12, 16)

	---------------------------------------------------------------- Living room
	local rug = box("Rug", Vector3.new(12, 0.1, 14), at(-17, 0.05, -8), fabricRed, Enum.Material.Fabric, false)
	box("RugBorder", Vector3.new(13, 0.08, 15), rug.CFrame * CFrame.new(0, -0.02, 0), P.Gold, Enum.Material.Fabric, false)

	-- Fireplace against the left (west) wall.
	local stone = Color3.fromRGB(150, 140, 135)
	box("Hearth", Vector3.new(4, 0.6, 11), at(-25.5, 0.3, -8), stone, Enum.Material.Cobblestone)
	box("FireplaceLeft", Vector3.new(3, 7, 1.6), at(-26.5, 3.5, -12), stone, Enum.Material.Cobblestone)
	box("FireplaceRight", Vector3.new(3, 7, 1.6), at(-26.5, 3.5, -4), stone, Enum.Material.Cobblestone)
	box("FireplaceTop", Vector3.new(3, 2.4, 9.6), at(-26.5, 6.2, -8), stone, Enum.Material.Cobblestone)
	box("Firebox", Vector3.new(0.4, 5, 6.4), at(-27.6, 2.5, -8), Color3.fromRGB(25, 20, 20))
	box("Mantel", Vector3.new(3.6, 0.6, 11), at(-26.2, 7.6, -8), wood, Enum.Material.Wood)
	box("Chimneybreast", Vector3.new(2, WH - 7.9, 7), at(-27, 7.9 + (WH - 7.9) / 2, -8), stone, Enum.Material.Cobblestone)
	for i = 0, 2 do
		B.hcyl(m, "Log", at(-26.3, 0.9 + (i % 2) * 0.6, -9 + i), 3, 0.7, P.DarkWood, Enum.Material.Wood, false)
	end
	local fire = box("Fire", Vector3.new(1.4, 2, 3.4), at(-26.3, 1.8, -8), Color3.fromRGB(255, 140, 40), Enum.Material.Neon, false)
	fire.Transparency = 0.2
	fire.CastShadow = false
	B.pointLight(fire, Color3.fromRGB(255, 140, 60), 20, 1.6, true)
	B.tag(fire, "Fireplace")
	local fireFx = Instance.new("Fire")
	fireFx.Size = 3
	fireFx.Heat = 4
	fireFx.Color = Color3.fromRGB(255, 120, 40)
	fireFx.SecondaryColor = Color3.fromRGB(255, 220, 90)
	fireFx.Parent = fire
	-- Stockings on the mantel (future steal targets).
	local stockingColors = { P.Red, P.Green, fabricRed }
	for i, c in stockingColors do
		local z = -11 + (i - 1) * 3
		box("Stocking", Vector3.new(0.4, 2, 1), at(-24.6, 6.2, z), c, Enum.Material.Fabric, false)
		box("StockingFoot", Vector3.new(0.4, 0.8, 1.6), at(-24.6, 5.4, z + 0.4), c, Enum.Material.Fabric, false)
		box("StockingCuff", Vector3.new(0.45, 0.5, 1.1), at(-24.6, 7.1, z), P.Snow, Enum.Material.Fabric, false)
		HP.presentSpot(spots, at(-24.6, 5, z), "Living")
	end
	B.stringLights(m, (at(-25.7, 8, -13)).Position, (at(-25.7, 8, -3)).Position, 1.2, 0.4, 0)

	-- Sofa facing the fireplace.
	local sofaCf = at(-13, 0, -8, math.pi / 2) -- LookVector toward the fireplace (-X)
	box("SofaBase", Vector3.new(10, 1.6, 4), sofaCf * CFrame.new(0, 1.3, 0), Color3.fromRGB(70, 90, 140), Enum.Material.Fabric)
	box("SofaBack", Vector3.new(10, 3, 1.2), sofaCf * CFrame.new(0, 3, 1.6), Color3.fromRGB(70, 90, 140), Enum.Material.Fabric)
	for _, sx in { -1, 1 } do
		box("SofaArm", Vector3.new(1.2, 2.6, 4), sofaCf * CFrame.new(sx * 5.2, 1.8, 0), Color3.fromRGB(60, 80, 125), Enum.Material.Fabric)
		box("Cushion", Vector3.new(1.6, 1.6, 0.6), sofaCf * CFrame.new(sx * 3.4, 3, 0.8) * CFrame.Angles(0.2, 0, 0), fabricRed, Enum.Material.Fabric, false)
	end
	for i = -1, 1 do
		box("SeatCushion", Vector3.new(3.1, 0.5, 3.4), sofaCf * CFrame.new(i * 3.2, 2.35, -0.2), Color3.fromRGB(80, 100, 155), Enum.Material.Fabric)
	end
	B.part({ Name = "Throw", Size = Vector3.new(2.5, 0.1, 3), CFrame = sofaCf * CFrame.new(-3.2, 2.65, -0.3), Color = P.Green, Material = Enum.Material.Fabric, CanCollide = false, Parent = m })

	-- Coffee table with cocoa mugs.
	box("CoffeeTop", Vector3.new(3.5, 0.4, 6), at(-19, 1.8, -8), wood, Enum.Material.Wood)
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			box("CoffeeLeg", Vector3.new(0.4, 1.6, 0.4), at(-19 + sx * 1.4, 0.8, -8 + sz * 2.6), P.DarkWood, Enum.Material.Wood)
		end
	end
	for _, z in { -9, -7 } do
		B.vcyl(m, "Mug", at(-19, 2.35, z), 0.7, 0.6, P.Snow, nil, false)
	end
	HP.presentSpot(spots, at(-19, 2, -8), "Living")

	-- Armchair in the corner.
	local chairCf = at(-9, 0, 3.5, math.rad(200))
	box("ChairSeat", Vector3.new(4, 1.8, 4), chairCf * CFrame.new(0, 1.2, 0), Color3.fromRGB(120, 60, 50), Enum.Material.Fabric)
	box("ChairBack", Vector3.new(4, 3, 1), chairCf * CFrame.new(0, 3.3, 1.5), Color3.fromRGB(120, 60, 50), Enum.Material.Fabric)

	-- The Christmas tree in the back-left corner of the living room.
	local treeBase = at(-22, 0, 1)
	box("TreeStand", Vector3.new(2.4, 1, 2.4), treeBase * CFrame.new(0, 0.5, 0), fabricRed, Enum.Material.Fabric)
	box("TreeSkirt", Vector3.new(7, 0.1, 7), treeBase * CFrame.new(0, 0.05, 0), P.Snow, Enum.Material.Fabric, false)
	local tiers = { { 7.5, 3.6, 1 }, { 6.2, 3.2, 3.6 }, { 4.8, 2.9, 6 }, { 3.2, 2.5, 8.2 }, { 1.8, 2, 10 } }
	local rng = Random.new(5)
	local ornamentColors = { P.Red, P.Gold, Color3.fromRGB(80, 150, 255), Color3.fromRGB(230, 230, 240), Color3.fromRGB(200, 70, 200) }
	for ti, t in tiers do
		local d, h, y = t[1], t[2], t[3]
		B.blob(m, "TreeTier", treeBase * CFrame.new(0, y + h / 2, 0) * CFrame.Angles(0, ti, 0), Vector3.new(d, h, d), if ti % 2 == 0 then P.Pine else P.PineDark, Enum.Material.Grass, ti == 1)
		for k = 1, 5 do
			local a = (k / 5 + ti * 0.13) * math.pi * 2
			local r = d * 0.46
			local pos = (treeBase * CFrame.new(math.cos(a) * r, y + h * rng:NextNumber(0.25, 0.5), math.sin(a) * r)).Position
			local isBulb = k % 2 == 0
			local orb = B.ball(m, if isBulb then "TreeBulb" else "Ornament", pos, if isBulb then 0.4 else 0.65, ornamentColors[((k + ti) % #ornamentColors) + 1], if isBulb then Enum.Material.Neon else Enum.Material.Glass, false)
			orb.CastShadow = false
			if isBulb then
				orb:SetAttribute("Index", k + ti)
				B.tag(orb, "XmasBulb")
			end
		end
	end
	local star = B.part({ Name = "TreeStar", Size = Vector3.new(1.2, 1.2, 0.3), CFrame = treeBase * CFrame.new(0, 12.6, 0) * CFrame.Angles(0, 0, math.rad(45)), Color = P.Gold, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	B.part({ Name = "TreeStar", Size = Vector3.new(1.2, 1.2, 0.3), CFrame = star.CFrame * CFrame.Angles(0, 0, math.rad(45)), Color = P.Gold, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	B.pointLight(star, P.Gold, 10, 0.8)
	-- Presents under the tree (decorative now; spawn points for later).
	local giftColors = { P.Red, P.Green, Color3.fromRGB(70, 110, 210), Color3.fromRGB(240, 240, 245), Color3.fromRGB(200, 70, 200) }
	for i = 1, 5 do
		local a = i / 5 * math.pi * 2
		local cf = treeBase * CFrame.new(math.cos(a) * 3, 0.1, math.sin(a) * 3) * CFrame.Angles(0, a, 0)
		Props.present(m, cf, Vector3.new(1.6, 1.3, 1.6) * rng:NextNumber(0.8, 1.4), giftColors[i])
		HP.presentSpot(spots, cf, "Living")
	end
	-- Garland across the living-room front window.
	B.stringLights(m, (at(-24, 10.8, -19.2)).Position, (at(-10, 10.8, -19.2)).Position, 1.4, 0.7, 0)

	---------------------------------------------------------------- Hallway
	box("Runner", Vector3.new(4, 0.08, 34), at(-2, 0.04, 0), Color3.fromRGB(120, 40, 50), Enum.Material.Fabric, false)
	box("HallTable", Vector3.new(1.6, 0.3, 4), at(1, 3, 2), wood, Enum.Material.Wood)
	box("HallTableLegs", Vector3.new(1.2, 2.9, 3.6), at(1, 1.45, 2), P.DarkWood, Enum.Material.Wood)
	local lamp = box("HallLamp", Vector3.new(1, 1.2, 1), at(1, 4.2, 2), Color3.fromRGB(255, 220, 160), Enum.Material.Neon, false)
	B.pointLight(lamp, P.WarmLight, 10, 0.6)
	box("CoatRack", Vector3.new(0.4, 6, 0.4), at(1, 3, -18), P.DarkWood, Enum.Material.Wood)
	B.ball(m, "Hat", (at(1, 6.3, -18)).Position, 1.2, P.Red, Enum.Material.Fabric, false)
	for i, z in { -15, -1, 6 } do
		local frame = box("Picture", Vector3.new(0.2, 3, 2.4), at(1.5, 7, z), P.Gold, Enum.Material.Metal, false)
		box("Canvas", Vector3.new(0.1, 2.4, 1.8), frame.CFrame * CFrame.new(-0.12, 0, 0), ({ Color3.fromRGB(90, 140, 200), Color3.fromRGB(200, 120, 90), Color3.fromRGB(110, 170, 110) })[i], Enum.Material.SmoothPlastic, false)
	end
	HP.presentSpot(spots, at(-2, 0, 17), "Hallway")

	---------------------------------------------------------------- Kitchen
	local counter = Color3.fromRGB(245, 245, 248)
	local cabinet = Color3.fromRGB(90, 140, 120)
	-- Counters along the front wall (under the window) and the east wall.
	box("CounterFront", Vector3.new(16, 3.4, 2.6), at(18, 1.7, -18.4), cabinet, Enum.Material.Wood)
	box("CounterFrontTop", Vector3.new(16.4, 0.3, 3), at(18, 3.55, -18.3), counter, Enum.Material.Marble)
	box("CounterEast", Vector3.new(2.6, 3.4, 12), at(26.4, 1.7, -10), cabinet, Enum.Material.Wood)
	box("CounterEastTop", Vector3.new(3, 0.3, 12.4), at(26.3, 3.55, -10), counter, Enum.Material.Marble)
	box("Sink", Vector3.new(4, 0.2, 2), at(15, 3.65, -18.3), Color3.fromRGB(170, 175, 185), Enum.Material.Metal, false)
	box("Faucet", Vector3.new(0.3, 1.2, 0.3), at(15, 4.3, -19.2), Color3.fromRGB(200, 200, 210), Enum.Material.Metal, false)
	-- Stove with oven window glow.
	box("Stove", Vector3.new(5, 3.6, 2.8), at(7, 1.8, -18.4), Color3.fromRGB(40, 40, 46), Enum.Material.Metal)
	local oven = box("OvenWindow", Vector3.new(3, 1.4, 0.1), at(7, 1.6, -16.95), Color3.fromRGB(255, 150, 60), Enum.Material.Neon, false)
	oven.Transparency = 0.3
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			B.vcyl(m, "Burner", at(7 + sx * 1.2, 3.65, -18.4 + sz * 0.6), 0.1, 0.9, Color3.fromRGB(20, 20, 20), nil, false)
		end
	end
	B.vcyl(m, "Pot", at(5.8, 4.3, -18.4), 1.2, 1.4, Color3.fromRGB(180, 60, 50), Enum.Material.Metal, false)
	-- Fridge in the corner by the bedroom wall.
	box("Fridge", Vector3.new(4, 9, 3.4), at(25.6, 4.5, 1.6), Color3.fromRGB(235, 238, 242), Enum.Material.SmoothPlastic)
	box("FridgeHandle", Vector3.new(0.2, 3, 0.3), at(23.5, 5.5, 0.6), Color3.fromRGB(180, 180, 190), Enum.Material.Metal, false)
	-- Upper cabinets.
	box("UpperCabinets", Vector3.new(5, 3, 1.8), at(24.5, 9.5, -19), cabinet, Enum.Material.Wood)
	-- Kitchen table with chairs and a plate of cookies.
	box("TableTop", Vector3.new(8, 0.4, 5), at(14, 3, -7), wood, Enum.Material.Wood)
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			box("TableLeg", Vector3.new(0.4, 2.8, 0.4), at(14 + sx * 3.5, 1.4, -7 + sz * 2), P.DarkWood, Enum.Material.Wood)
		end
	end
	for _, c in { { 14 - 2, -10.2, 0 }, { 14 + 2, -10.2, 0 }, { 14 - 2, -3.8, math.pi }, { 14 + 2, -3.8, math.pi } } do
		local cf = at(c[1], 0, c[2], c[3])
		box("ChairSeat", Vector3.new(2.2, 0.3, 2.2), cf * CFrame.new(0, 2, 0), wood, Enum.Material.Wood)
		box("ChairBack", Vector3.new(2.2, 2.6, 0.3), cf * CFrame.new(0, 3.3, -1), wood, Enum.Material.Wood)
		box("ChairLegs", Vector3.new(1.8, 1.9, 1.8), cf * CFrame.new(0, 0.95, 0), P.DarkWood, Enum.Material.Wood, false)
	end
	B.vcyl(m, "Plate", at(14, 3.25, -7), 0.1, 2, P.Snow, nil, false)
	for i = 0, 4 do
		local a = i / 5 * math.pi * 2
		B.vcyl(m, "Cookie", at(14 + math.cos(a) * 0.5, 3.35, -7 + math.sin(a) * 0.5), 0.12, 0.6, Color3.fromRGB(200, 140, 80), nil, false)
	end
	HP.presentSpot(spots, at(10, 3.2, -7), "Kitchen")
	HP.presentSpot(spots, at(20, 0, -2), "Kitchen")

	---------------------------------------------------------------- Bedroom
	local bedCf = at(17, 0, 14) -- head against the back wall
	box("BedFrame", Vector3.new(8, 1.6, 11), bedCf * CFrame.new(0, 0.8, 0), wood, Enum.Material.Wood)
	box("Mattress", Vector3.new(7.6, 1.2, 10.4), bedCf * CFrame.new(0, 2.2, 0), Color3.fromRGB(245, 245, 250), Enum.Material.Fabric)
	box("Blanket", Vector3.new(7.8, 0.4, 7), bedCf * CFrame.new(0, 2.9, -1.6), Color3.fromRGB(80, 70, 150), Enum.Material.Fabric)
	box("Headboard", Vector3.new(8, 5, 0.6), bedCf * CFrame.new(0, 2.5, 5.3), P.DarkWood, Enum.Material.Wood)
	for _, sx in { -1.8, 1.8 } do
		box("Pillow", Vector3.new(3, 0.8, 1.8), bedCf * CFrame.new(sx, 3.1, 3.8), P.Snow, Enum.Material.Fabric, false)
	end
	for _, sx in { -6.5, 6.5 } do
		box("Nightstand", Vector3.new(3, 2.8, 2.6), at(17 + sx, 1.4, 18.4), wood, Enum.Material.Wood)
		local l = box("BedsideLamp", Vector3.new(1, 1.4, 1), at(17 + sx, 3.5, 18.4), Color3.fromRGB(255, 220, 170), Enum.Material.Neon, false)
		B.pointLight(l, P.WarmLight, 9, 0.5)
	end
	box("Dresser", Vector3.new(2.6, 4.4, 7), at(26.4, 2.2, 9), wood, Enum.Material.Wood)
	for i = 0, 2 do
		box("Drawer", Vector3.new(0.1, 1, 6), at(25.05, 0.9 + i * 1.4, 9), P.DarkWood, Enum.Material.Wood, false)
	end
	box("BedRug", Vector3.new(10, 0.08, 6), at(17, 0.04, 7.5), Color3.fromRGB(230, 200, 120), Enum.Material.Fabric, false)
	HP.presentSpot(spots, at(17, 0, 8), "Bedroom")
	HP.presentSpot(spots, at(26.4, 4.4, 9), "Bedroom")

	---------------------------------------------------------------- Den
	box("Bookshelf", Vector3.new(10, 9, 2), at(-17, 4.5, 7.4), P.DarkWood, Enum.Material.Wood)
	local bookColors = { P.Red, P.Green, Color3.fromRGB(70, 110, 210), P.Gold, Color3.fromRGB(150, 90, 160) }
	for shelf = 0, 2 do
		box("Shelf", Vector3.new(9.6, 0.25, 1.8), at(-17, 1.4 + shelf * 2.8, 7.6), wood, Enum.Material.Wood, false)
		local x = -21.2
		local k = 0
		while x < -13 do
			local w = 0.4 + (k % 3) * 0.15
			box("Book", Vector3.new(w, 2, 1.4), at(x + w / 2, 2.5 + shelf * 2.8, 7.8), bookColors[(k + shelf) % #bookColors + 1], Enum.Material.SmoothPlastic, false)
			x += w + 0.05
			k += 1
		end
	end
	for _, c in { { -21, 15.5, math.rad(-30) }, { -13, 15.5, math.rad(30) } } do
		local cf = at(c[1], 0, c[2], c[3])
		box("ArmchairSeat", Vector3.new(3.6, 1.8, 3.6), cf * CFrame.new(0, 1.2, 0), Color3.fromRGB(60, 110, 90), Enum.Material.Fabric)
		box("ArmchairBack", Vector3.new(3.6, 3, 1), cf * CFrame.new(0, 3.3, 1.4), Color3.fromRGB(60, 110, 90), Enum.Material.Fabric)
	end
	B.vcyl(m, "SideTable", at(-17, 1.3, 15.5), 2.6, 3, wood, Enum.Material.Wood)
	HP.presentSpot(spots, at(-17, 2.6, 15.5), "Den")
	box("ToyChest", Vector3.new(4, 2.4, 2.6), at(-25.5, 1.2, 18), fabricRed, Enum.Material.Wood)
	box("ToyChestLid", Vector3.new(4.2, 0.4, 2.8), at(-25.5, 2.6, 18), P.Gold, Enum.Material.Wood)
	B.ball(m, "ToyBall", (at(-23, 0.8, 9)).Position, 1.6, Color3.fromRGB(80, 150, 255), nil, true)
	HP.presentSpot(spots, at(-25.5, 2.8, 18), "Den")

	return m
end

return Interior
