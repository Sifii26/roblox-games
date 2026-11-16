--!strict
-- Area A: the town square with its giant tree, shops, benches and lights.
local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local HP = require(script.Parent.HouseParts)
local Layout = require(game:GetService("ReplicatedStorage").Shared.Config.Layout)
local P = B.Palette

local TownCenter = {}

local function giantTree(parent: Instance, base: CFrame, height: number)
	local m = B.model("GiantTree", parent)
	B.vcyl(m, "Planter", base * CFrame.new(0, 1.2, 0), 2.4, 30, P.Stone, Enum.Material.Cobblestone)
	B.vcyl(m, "PlanterSnow", base * CFrame.new(0, 2.6, 0), 0.6, 28, P.Snow, Enum.Material.Snow)
	B.vcyl(m, "PlanterRim", base * CFrame.new(0, 2.5, 0), 0.5, 31, P.Gold, Enum.Material.Metal)
	local trunkH = height * 0.12
	B.vcyl(m, "Trunk", base * CFrame.new(0, 2.4 + trunkH / 2, 0), trunkH, 5, P.DarkWood, Enum.Material.Wood)
	local tiers = 7
	local rng = Random.new(12)
	local ornamentColors = { P.Red, P.Gold, Color3.fromRGB(80, 150, 255), Color3.fromRGB(240, 240, 250), Color3.fromRGB(200, 70, 200) }
	local y = 2.4 + trunkH * 0.6
	local tierH = (height - trunkH) / tiers * 1.3
	for i = 1, tiers do
		local w = height * 0.55 * (1 - (i - 1) / (tiers + 0.5))
		local tierCf = base * CFrame.new(0, y + tierH / 2, 0) * CFrame.Angles(0, i * 0.7, 0)
		B.blob(m, "Tier", tierCf, Vector3.new(w, tierH, w), if i % 2 == 0 then P.Pine else P.PineDark, Enum.Material.Grass, i <= 2)
		B.blob(m, "TierSnow", tierCf * CFrame.new(0, tierH * 0.3, 0), Vector3.new(w * 0.72, tierH * 0.4, w * 0.72), P.Snow, Enum.Material.Snow, false)
		-- Big glass ornaments around the tier's widest ring.
		local count = math.max(4, math.floor(w / 3.5))
		for k = 1, count do
			local a = (k / count) * math.pi * 2 + i
			local r = w * 0.47
			local pos = (base * CFrame.new(math.cos(a) * r, y + tierH * 0.45, math.sin(a) * r)).Position
			local orb = B.ball(m, "Ornament", pos, rng:NextNumber(1.4, 2.2), ornamentColors[(k + i) % #ornamentColors + 1], Enum.Material.Glass, false)
			orb.Reflectance = 0.25
			orb.CastShadow = false
		end
		y += tierH * 0.66
	end
	-- Spiral of lights wound around the tree.
	local prev: Vector3? = nil
	local turns, steps = 4, 48
	local bottom, top = 2.4 + trunkH, y
	for s = 0, steps do
		local t = s / steps
		local yy = bottom + (top - bottom) * t
		local radius = height * 0.29 * (1 - t) + 1
		local a = t * turns * math.pi * 2
		local p = (base * CFrame.new(math.cos(a) * radius, yy, math.sin(a) * radius)).Position
		if prev then
			B.stringLights(m, prev, p, 2.2, 0.1, if s % 6 == 0 then 1 else 0)
		end
		prev = p
	end
	-- Star.
	local starCf = base * CFrame.new(0, top + 3, 0)
	local star = B.part({ Name = "Star", Size = Vector3.new(5, 5, 1), CFrame = starCf * CFrame.Angles(0, 0, math.rad(45)), Color = P.Gold, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	local star2 = B.part({ Name = "Star", Size = Vector3.new(5, 5, 1), CFrame = starCf, Color = P.Gold, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	B.tag(star2, "SpinSlow")
	B.pointLight(star, P.Gold, 50, 2)
	B.tag(star, "SpinSlow")
	return m, top
end

export type ShopSpec = {
	name: string,
	sign: string,
	body: Color3,
	trim: Color3,
	awning: { Color3 },
	roof: string, -- "gable" | "dome" | "curl" | "flat"
	height: number,
}

-- `cf` = center of the shop's front edge on the ground, LookVector toward the street.
local function shop(parent: Instance, cf: CFrame, spec: ShopSpec)
	local m = B.model(spec.name, parent)
	local W, D, Ht = 34, 24, spec.height
	local H = cf * CFrame.new(0, 0, D / 2 + 6)
	-- Shop sidewalk.
	local walk = B.part({ Name = "ShopWalk", Size = Vector3.new(W + 8, 1.2, 8), CFrame = cf * CFrame.new(0, 0.2, 2.5), Color = P.Sidewalk, Material = Enum.Material.Concrete, Parent = m })
	B.part({ Name = "WalkSnow", Size = Vector3.new(W + 8, 0.3, 1.6), CFrame = walk.CFrame * CFrame.new(0, 0.75, -3.2), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
	B.part({ Name = "Foundation", Size = Vector3.new(W + 1, 1.2, D + 1), CFrame = H * CFrame.new(0, 0.5, 0), Color = P.Stone, Material = Enum.Material.Cobblestone, Parent = m })
	B.part({ Name = "Body", Size = Vector3.new(W, Ht, D), CFrame = H * CFrame.new(0, 1.1 + Ht / 2, 0), Color = spec.body, Material = Enum.Material.Plaster, Parent = m })
	-- Big glowing display windows and a door between them.
	for _, sx in { -1, 1 } do
		local win = B.part({ Name = "Display", Size = Vector3.new(11, 7, 0.3), CFrame = H * CFrame.new(sx * 9.5, 5.6, -D / 2 - 0.1), Color = P.Window, Material = Enum.Material.Neon, CastShadow = false, Parent = m })
		B.part({ Name = "DisplayFrame", Size = Vector3.new(12, 8, 0.6), CFrame = win.CFrame * CFrame.new(0, 0, 0.25), Color = spec.trim, Material = Enum.Material.Wood, Parent = m })
		local sill = B.part({ Name = "DisplaySill", Size = Vector3.new(12.6, 0.5, 1.4), CFrame = win.CFrame * CFrame.new(0, -4, -0.5), Color = spec.trim, Material = Enum.Material.Wood, Parent = m })
		B.snowCap(m, sill, 0.3, -0.2)
		-- Little wrapped gifts displayed in the window.
		for k = -1, 1 do
			Props.present(m, H * CFrame.new(sx * 9.5 + k * 3, 2.1, -D / 2 - 1.4), Vector3.new(1.4, 1.2, 1.2), spec.awning[(k + 2) % #spec.awning + 1])
		end
	end
	HP.door(m, H * CFrame.new(0, 1.1, -D / 2), 5, 8.5, spec.trim, spec.trim:Lerp(Color3.new(1, 1, 1), 0.5), false)
	-- Striped awning tilted out over the windows.
	local stripes = 12
	for i = 0, stripes - 1 do
		local x = -W / 2 + (i + 0.5) * (W / stripes)
		local stripe = B.part({ Name = "Awning", Size = Vector3.new(W / stripes, 0.3, 5), CFrame = H * CFrame.new(x, 11.4, -D / 2 - 2.3) * CFrame.Angles(math.rad(-22), 0, 0), Color = spec.awning[i % #spec.awning + 1], Material = Enum.Material.Fabric, Parent = m })
		B.part({ Name = "AwningSnow", Size = Vector3.new(W / stripes, 0.3, 3.2), CFrame = stripe.CFrame * CFrame.new(0, 0.3, 0.6), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
	end
	-- Sign board with the shop name.
	local signBoard = B.part({ Name = "Sign", Size = Vector3.new(20, 3, 0.5), CFrame = H * CFrame.new(0, 14.2, -D / 2 - 0.4), Color = spec.trim, Material = Enum.Material.Wood, Parent = m })
	B.snowCap(m, signBoard, 0.3, 0)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.LightInfluence = 0
	gui.Parent = signBoard
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = spec.sign
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.fromRGB(255, 240, 200)
	label.Parent = gui
	-- Upper floor windows if tall enough.
	if Ht > 18 then
		for _, sx in { -1, 0, 1 } do
			HP.window(m, H * CFrame.new(sx * 10, Ht - 3, -D / 2 - 0.1), 4, 4.5, spec.trim, true)
		end
	end
	-- Roof variants.
	local top = H * CFrame.new(0, 1.1 + Ht, 0)
	if spec.roof == "gable" then
		B.gableRoof(m, top, W, D, 9, 2, spec.trim:Lerp(Color3.new(0, 0, 0), 0.3), spec.body)
	elseif spec.roof == "dome" then
		local slab = B.part({ Name = "RoofSlab", Size = Vector3.new(W + 2, 1, D + 2), CFrame = top * CFrame.new(0, 0.5, 0), Color = spec.trim, Parent = m })
		B.snowCap(m, slab, 0.6, -0.4)
		local dome = B.blob(m, "Dome", top * CFrame.new(0, 4, 2), Vector3.new(16, 12, 16), spec.awning[1], Enum.Material.SmoothPlastic, true)
		B.blob(m, "DomeSnow", dome.CFrame * CFrame.new(0, 3, 0), Vector3.new(12, 6, 12), P.Snow, Enum.Material.Snow, false)
		local orb = B.ball(m, "Orb", (top * CFrame.new(0, 11, 2)).Position, 1.8, P.Gold, Enum.Material.Neon, false)
		B.tag(orb, "XmasBulb")
	elseif spec.roof == "curl" then
		local c = top
		local w, d = W + 2, D + 2
		for i = 1, 6 do
			c = c * CFrame.new(0, 1.2, 0)
			local tier = B.part({ Name = "RoofTier", Size = Vector3.new(w, 2.4, d), CFrame = c, Color = if i % 2 == 0 then spec.trim else spec.awning[1], Material = Enum.Material.Slate, CanCollide = i <= 2, Parent = m })
			B.part({ Name = "RoofSnow", Size = Vector3.new(w * 0.9, 0.4, d * 0.9), CFrame = tier.CFrame * CFrame.new(0, 1.4, 0), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
			w *= 0.8
			d *= 0.8
			c = c * CFrame.new(0, 1.2, 0) * CFrame.Angles(math.rad(5 + i * 2), 0, 0)
		end
	else
		local slab = B.part({ Name = "RoofSlab", Size = Vector3.new(W + 2, 1, D + 2), CFrame = top * CFrame.new(0, 0.5, 0), Color = spec.trim, Parent = m })
		B.snowCap(m, slab, 0.8, -0.4)
		-- Parapet with crenellations for a little whimsy.
		for i = 0, 8 do
			local x = -W / 2 + i * (W / 8)
			local block = B.part({ Name = "Parapet", Size = Vector3.new(2, 2, 2), CFrame = top * CFrame.new(x, 2, -D / 2), Color = spec.trim, Parent = m })
			B.snowCap(m, block, 0.4, 0)
		end
	end
	HP.chimney(m, H * CFrame.new(W / 2 - 4, 1.1, D / 2 - 4), Ht + 9, 3)
	-- Lights along the shop front.
	B.stringLights(m, (H * CFrame.new(-W / 2, 12.8, -D / 2 - 0.6)).Position, (H * CFrame.new(W / 2, 12.8, -D / 2 - 0.6)).Position, 2.2, 0.7, 6)
	-- Bench and lamppost out front.
	Props.bench(m, cf * CFrame.new(-W / 2 + 4, 0.8, 4.5) * CFrame.Angles(0, math.pi, 0))
	Props.lamppost(m, cf * CFrame.new(W / 2 + 2, 0.8, 4) * CFrame.Angles(0, math.pi / 2, 0), true)
	return m
end

local SHOPS: { ShopSpec } = {
	{ name = "CocoaCafe", sign = "Cocoa Cafe", body = Color3.fromRGB(150, 95, 70), trim = Color3.fromRGB(245, 230, 200), awning = { Color3.fromRGB(190, 50, 50), Color3.fromRGB(245, 240, 230) }, roof = "gable", height = 16 },
	{ name = "ToyShoppe", sign = "Toy Shoppe", body = Color3.fromRGB(90, 130, 200), trim = Color3.fromRGB(250, 210, 80), awning = { Color3.fromRGB(250, 210, 80), Color3.fromRGB(230, 70, 70) }, roof = "curl", height = 20 },
	{ name = "Bakery", sign = "Sugarplum Bakery", body = Color3.fromRGB(245, 190, 200), trim = Color3.fromRGB(140, 70, 100), awning = { Color3.fromRGB(240, 120, 160), Color3.fromRGB(255, 245, 250) }, roof = "dome", height = 16 },
	{ name = "OrnamentEmporium", sign = "Ornaments", body = Color3.fromRGB(70, 120, 90), trim = Color3.fromRGB(230, 200, 120), awning = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(230, 200, 120) }, roof = "flat", height = 22 },
	{ name = "PostOffice", sign = "Post Office", body = Color3.fromRGB(200, 70, 60), trim = Color3.fromRGB(240, 240, 240), awning = { Color3.fromRGB(40, 90, 160), Color3.fromRGB(240, 240, 240) }, roof = "gable", height = 18 },
	{ name = "SweetShop", sign = "Sweet Shop", body = Color3.fromRGB(180, 140, 220), trim = Color3.fromRGB(255, 255, 255), awning = { Color3.fromRGB(120, 210, 170), Color3.fromRGB(255, 255, 255) }, roof = "curl", height = 18 },
	{ name = "Bookshop", sign = "Books & Tales", body = Color3.fromRGB(110, 80, 60), trim = Color3.fromRGB(220, 180, 120), awning = { Color3.fromRGB(60, 100, 70), Color3.fromRGB(220, 180, 120) }, roof = "flat", height = 20 },
	{ name = "Tailor", sign = "Warm Woolens", body = Color3.fromRGB(230, 220, 160), trim = Color3.fromRGB(150, 50, 60), awning = { Color3.fromRGB(150, 50, 60), Color3.fromRGB(240, 230, 210) }, roof = "dome", height = 16 },
}

function TownCenter.build(map: Instance)
	local area = B.folder("TownCenter", map)
	local center = Layout.TownCenter
	local half = Layout.PlazaHalf
	local base = CFrame.new(center)

	-- Plaza paving with a raised round center and four diagonal paths.
	B.part({ Name = "Plaza", Size = Vector3.new(half * 2 + 8, 1, half * 2 + 8), CFrame = base * CFrame.new(0, 0.2, 0), Color = P.Cobble, Material = Enum.Material.Cobblestone, Parent = area })
	B.part({ Name = "PlazaBorder", Size = Vector3.new(half * 2 + 10, 1.2, half * 2 + 10), CFrame = base * CFrame.new(0, 0.1, 0), Color = P.Sidewalk, Material = Enum.Material.Concrete, Parent = area })
	B.vcyl(area, "Dais", base * CFrame.new(0, 0.9, 0), 0.6, 60, Color3.fromRGB(150, 140, 140), Enum.Material.Cobblestone)
	B.vcyl(area, "DaisRing", base * CFrame.new(0, 0.95, 0), 0.6, 62, P.Gold, Enum.Material.Metal)
	-- Snowy lawn quadrants with bushes and small trees.
	local rng = Random.new(21)
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			local q = base * CFrame.new(sx * 46, 0, sz * 46)
			B.part({ Name = "Lawn", Size = Vector3.new(34, 0.6, 34), CFrame = q * CFrame.new(0, 0.9, 0), Color = P.Snow, Material = Enum.Material.Snow, Parent = area })
			B.part({ Name = "LawnEdge", Size = Vector3.new(35, 0.8, 35), CFrame = q * CFrame.new(0, 0.75, 0), Color = P.Stone, Material = Enum.Material.Cobblestone, Parent = area })
			Props.pine(area, q * CFrame.new(sx * 8, 1.2, sz * 8), rng:NextNumber(18, 24), rng)
			Props.bush(area, q * CFrame.new(-sx * 8, 1.2, sz * 8), 4)
			Props.bush(area, q * CFrame.new(sx * 8, 1.2, -sz * 8), 4)
			B.blob(area, "SnowMound", q * CFrame.new(-sx * 4, 1.2, -sz * 4), Vector3.new(10, 2.2, 8), P.Snow, Enum.Material.Snow, false)
		end
	end
	-- Snowman family near the tree.
	Props.snowman(area, base * CFrame.new(-20, 1.2, 20) * CFrame.Angles(0, math.rad(-135), 0), 1.2)
	Props.snowman(area, base * CFrame.new(-25, 1.2, 16) * CFrame.Angles(0, math.rad(-120), 0), 0.7)

	local _, treeTop = giantTree(area, base * CFrame.new(0, 1.2, 0), 64)

	-- Benches facing the tree.
	for i = 0, 7 do
		local a = (i + 0.5) / 8 * math.pi * 2
		local pos = center + Vector3.new(math.cos(a) * 26, 1.2, math.sin(a) * 26)
		Props.bench(area, CFrame.lookAt(pos, Vector3.new(center.X, pos.Y, center.Z)) * CFrame.Angles(0, math.pi, 0))
	end
	-- Light poles around the plaza edge; garlands run from the tree top to them.
	local poleTops = {}
	for i = 0, 7 do
		local a = i / 8 * math.pi * 2
		local pos = center + Vector3.new(math.cos(a) * 60, 0.7, math.sin(a) * 60)
		local pole = B.model("GarlandPole", area)
		B.vcyl(pole, "Pole", CFrame.new(pos + Vector3.new(0, 9, 0)), 18, 0.8, P.Red, Enum.Material.SmoothPlastic)
		for s = 0, 5 do
			B.vcyl(pole, "Stripe", CFrame.new(pos + Vector3.new(0, 1.5 + s * 3, 0)), 0.8, 0.85, P.Snow, nil, false)
		end
		local cap = B.ball(pole, "Cap", pos + Vector3.new(0, 18.4, 0), 1.6, P.Gold, Enum.Material.Metal)
		table.insert(poleTops, cap.Position)
		local lampPos = pos + (Vector3.new(center.X, pos.Y, center.Z) - pos).Unit * 4
		Props.lamppost(area, CFrame.lookAt(lampPos, Vector3.new(center.X, pos.Y, center.Z)), i % 2 == 0)
	end
	local apex = center + Vector3.new(0, treeTop - 6, 0)
	for _, p in poleTops do
		B.stringLights(area, apex, p, 3, 3, 6)
	end

	-- Shops around the outside of the ring road.
	local R = Layout.RingRoad
	local W = Layout.RoadWidth
	local front = R + W / 2 + 2
	local placements = {
		CFrame.lookAt(Vector3.new(-52, 0, -front), Vector3.new(-52, 0, 0)),
		CFrame.lookAt(Vector3.new(52, 0, -front), Vector3.new(52, 0, 0)),
		CFrame.lookAt(Vector3.new(-52, 0, front), Vector3.new(-52, 0, 0)),
		CFrame.lookAt(Vector3.new(52, 0, front), Vector3.new(52, 0, 0)),
		CFrame.lookAt(Vector3.new(front, 0, -56), Vector3.new(0, 0, -56)),
		CFrame.lookAt(Vector3.new(front, 0, 56), Vector3.new(0, 0, 56)),
		CFrame.lookAt(Vector3.new(-front, 0, -56), Vector3.new(0, 0, -56)),
		CFrame.lookAt(Vector3.new(-front, 0, 56), Vector3.new(0, 0, 56)),
	}
	local shops = B.folder("Shops", area)
	for i, cf in placements do
		-- lookAt faces the street; shops expect LookVector toward the street, so the
		-- building extends backward (local +Z) away from the plaza.
		shop(shops, cf, SHOPS[i])
	end

	-- Street lights strung across the side streets where they leave the ring.
	local arches = B.folder("StreetArches", area)
	local function arch(a: Vector3, b: Vector3)
		Props.lamppost(arches, CFrame.lookAt(a, b))
		Props.lamppost(arches, CFrame.lookAt(b, a))
		B.stringLights(arches, a + Vector3.new(0, 13, 0), b + Vector3.new(0, 13, 0), 2.4, 3, 5)
	end
	local edge = W / 2 + 3
	arch(Vector3.new(-R - W / 2 - 10, 0.7, -edge), Vector3.new(-R - W / 2 - 10, 0.7, edge)) -- Holly Lane
	arch(Vector3.new(R + W / 2 + 10, 0.7, -edge), Vector3.new(R + W / 2 + 10, 0.7, edge)) -- Evergreen Way
	arch(Vector3.new(-edge, 0.7, -R - W / 2 - 10), Vector3.new(edge, 0.7, -R - W / 2 - 10)) -- Mansion Row
	arch(Vector3.new(-edge, 0.7, R + W / 2 + 10), Vector3.new(edge, 0.7, R + W / 2 + 10)) -- Summit Road

	-- Street signs at each junction.
	Props.streetSign(area, CFrame.new(-R - W / 2 - 4, 0.7, -edge - 6), "Holly Lane")
	Props.streetSign(area, CFrame.new(R + W / 2 + 4, 0.7, -edge - 6), "Evergreen Way")
	Props.streetSign(area, CFrame.new(edge + 6, 0.7, -R - W / 2 - 4) * CFrame.Angles(0, math.pi / 2, 0), "Mansion Row")
	Props.streetSign(area, CFrame.new(edge + 6, 0.7, R + W / 2 + 4) * CFrame.Angles(0, math.pi / 2, 0), "Summit Trail")
	return area
end

return TownCenter
