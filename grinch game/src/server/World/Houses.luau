--!strict
-- The five starter-neighborhood houses. Each builder takes `lot`: a point on
-- the sidewalk edge in front of the property whose LookVector faces the road.
-- In each house's local frame, local -Z is the front (toward the road).
local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local HP = require(script.Parent.HouseParts)
local Interior = require(script.Parent.Interior)
local P = B.Palette

local Houses = {}

local function foundation(m: Instance, H: CFrame, w: number, d: number, color: Color3?)
	B.part({ Name = "Foundation", Size = Vector3.new(w + 1, 1.2, d + 1), CFrame = H * CFrame.new(0, 0.5, 0), Color = color or P.Stone, Material = Enum.Material.Cobblestone, Parent = m })
end

-------------------------------------------------------------------------------
-- 1. Holly Cottage: brick cottage with a full, furnished interior.
-------------------------------------------------------------------------------
function Houses.hollyCottage(parent: Instance, lot: CFrame): Model
	local m = B.model("HollyCottage", parent)
	m:SetAttribute("HasInterior", true)
	local W, D, WH = 56, 40, 14 -- width, depth, wall height
	local setback = 34
	local H = lot * CFrame.new(0, 0, setback + D / 2)
	local wallColor = Color3.fromRGB(168, 74, 62)
	local trim = Color3.fromRGB(245, 238, 222)
	local exterior = B.model("Exterior", m)

	foundation(exterior, H, W, D)
	local floorY = 1.1
	local function wallOrigin(x: number, z: number, alongZ: boolean): CFrame
		local cf = H * CFrame.new(x, floorY, z)
		return if alongZ then cf * CFrame.Angles(0, -math.pi / 2, 0) else cf
	end

	-- Exterior walls with openings (offsets from the wall's start).
	local doorOpening = { x = 22, w = 6, y = 0, h = 9 } -- x -6..0, lines up with the hallway
	B.wall(exterior, "WallFront", wallOrigin(-W / 2, -D / 2, false), W, WH, 1, wallColor, Enum.Material.Brick, {
		doorOpening,
		{ x = 4, w = 10, y = 4, h = 6 },
		{ x = 38, w = 10, y = 4, h = 6 },
	})
	B.wall(exterior, "WallBack", wallOrigin(-W / 2, D / 2, false), W, WH, 1, wallColor, Enum.Material.Brick, {
		{ x = 6, w = 8, y = 4, h = 6 },
		{ x = 38, w = 10, y = 4, h = 6 },
	})
	B.wall(exterior, "WallLeft", wallOrigin(-W / 2, -D / 2, true), D, WH, 1, wallColor, Enum.Material.Brick, {
		{ x = 30, w = 6, y = 4, h = 6 },
	})
	B.wall(exterior, "WallRight", wallOrigin(W / 2, -D / 2, true), D, WH, 1, wallColor, Enum.Material.Brick, {
		{ x = 6, w = 8, y = 4, h = 6 },
		{ x = 30, w = 6, y = 4, h = 6 },
	})
	-- Corner trim posts.
	for _, sx in { -1, 1 } do
		for _, sz in { -1, 1 } do
			B.part({ Name = "CornerTrim", Size = Vector3.new(1.4, WH, 1.4), CFrame = H * CFrame.new(sx * W / 2, floorY + WH / 2, sz * D / 2), Color = trim, Material = Enum.Material.Wood, Parent = exterior })
		end
	end
	-- Fascia board under the eaves.
	for _, sz in { -1, 1 } do
		B.part({ Name = "Fascia", Size = Vector3.new(W + 2, 1, 1.4), CFrame = H * CFrame.new(0, floorY + WH - 0.5, sz * (D / 2 + 0.2)), Color = trim, Material = Enum.Material.Wood, Parent = exterior })
	end

	-- Windows (glass, so the warm interior light shows).
	local function win(x: number, y: number, z: number, faceYaw: number, w: number, h: number)
		HP.window(exterior, H * CFrame.new(x, floorY + y, z) * CFrame.Angles(0, faceYaw, 0), w, h, trim, false)
	end
	-- Window panes sit in the wall plane; frames stick outward (local -Z of the window cf).
	win(-W / 2 + 9, 7, -D / 2, 0, 10, 6)
	win(-W / 2 + 43, 7, -D / 2, 0, 10, 6)
	win(-W / 2 + 10, 7, D / 2, math.pi, 8, 6)
	win(-W / 2 + 43, 7, D / 2, math.pi, 10, 6)
	win(-W / 2, 7, -D / 2 + 33, math.pi / 2, 6, 6)
	win(W / 2, 7, -D / 2 + 10, -math.pi / 2, 8, 6)
	win(W / 2, 7, -D / 2 + 33, -math.pi / 2, 6, 6)

	-- Front door, swung open so players can walk in during Free Roam.
	HP.door(exterior, H * CFrame.new(-W / 2 + doorOpening.x + doorOpening.w / 2, floorY, -D / 2), 6, 9, Color3.fromRGB(40, 100, 70), trim, true)

	-- Ceiling / attic floor and roof.
	B.part({ Name = "Ceiling", Size = Vector3.new(W, 0.6, D), CFrame = H * CFrame.new(0, floorY + WH + 0.3, 0), Color = Color3.fromRGB(240, 232, 215), Material = Enum.Material.SmoothPlastic, Parent = exterior })
	B.gableRoof(exterior, H * CFrame.new(0, floorY + WH + 0.6, 0), W, D, 12, 2.5, Color3.fromRGB(60, 70, 90), wallColor)
	HP.chimney(exterior, H * CFrame.new(-W / 2 - 3, floorY, -8), WH + 16, 5) -- outside the wall, behind the fireplace

	-- Eave lights along the front and back.
	HP.eaveLights(exterior, H, Vector3.new(-W / 2 - 1, floorY + WH - 1.2, -D / 2 - 1.2), Vector3.new(W / 2 + 1, floorY + WH - 1.2, -D / 2 - 1.2))
	HP.eaveLights(exterior, H, Vector3.new(-W / 2 - 1, floorY + WH - 1.2, D / 2 + 1.2), Vector3.new(W / 2 + 1, floorY + WH - 1.2, D / 2 + 1.2), 0)

	Interior.build(m, H, { width = W, depth = D, wallHeight = WH, floorY = floorY, trim = trim })

	HP.yard(m, lot, { width = 84, depth = setback + D + 14, doorX = -3, doorZ = setback, driveX = 32, mailboxColor = P.Red, decoration = "snowman", seed = 11 })
	return m
end

-------------------------------------------------------------------------------
-- 2. Crooked Spire: round two-storey tower with a leaning, curling spire.
-------------------------------------------------------------------------------
function Houses.crookedSpire(parent: Instance, lot: CFrame): Model
	local m = B.model("CrookedSpire", parent)
	local setback = 34
	local R = 17
	local H = lot * CFrame.new(-6, 0, setback + R)
	local body = Color3.fromRGB(60, 150, 160)
	local trim = Color3.fromRGB(250, 220, 120)
	B.vcyl(m, "Foundation", H * CFrame.new(0, 0.5, 0), 1.2, R * 2 + 1.5, P.Stone, Enum.Material.Cobblestone)
	local tower = B.vcyl(m, "Tower", H * CFrame.new(0, 1.1 + 13, 0), 26, R * 2, body, Enum.Material.Plaster)
	-- Band between storeys and a snowy ledge.
	B.vcyl(m, "Band", H * CFrame.new(0, 13, 0), 1, R * 2 + 1.2, trim, Enum.Material.Wood)
	B.vcyl(m, "Eave", H * CFrame.new(0, 27.4, 0), 1, R * 2 + 4, trim, Enum.Material.Wood)
	B.vcyl(m, "EaveSnow", H * CFrame.new(0, 28.2, 0), 0.6, R * 2 + 3.6, P.Snow, Enum.Material.Snow)
	-- Windows around the tower on both storeys.
	for storey = 0, 1 do
		for i = 0, 5 do
			local a = i / 6 * math.pi * 2 + storey * 0.5
			if not (storey == 0 and i == 0) then
				local cf = H * CFrame.Angles(0, a, 0) * CFrame.new(0, 7 + storey * 12, -R - 0.1)
				HP.window(m, cf, 4, 5.5, trim, true)
			end
		end
	end
	HP.door(m, H * CFrame.new(0, 1.1, -R + 0.2), 6, 9, Color3.fromRGB(120, 40, 90), trim, false)
	-- Leaning spire: stacked tapering drums, each tilted a bit more.
	local cf = H * CFrame.new(0, 28.5, 0)
	local d = R * 2 + 2
	local tiers = 8
	for i = 1, tiers do
		local h = 3.4
		d *= 0.78
		cf = cf * CFrame.new(0, h / 2, 0)
		local drum = B.vcyl(m, "Spire", cf, h, d, if i % 2 == 0 then Color3.fromRGB(110, 60, 140) else Color3.fromRGB(140, 80, 170), Enum.Material.Slate)
		if i <= 5 then
			B.vcyl(m, "SpireSnow", cf * CFrame.new(0, h / 2 + 0.2, 0), 0.5, d * 0.92, P.Snow, Enum.Material.Snow, false)
		end
		drum.CanCollide = i <= 3
		cf = cf * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, 0, math.rad(7)) * CFrame.new(0.6, 0, 0)
	end
	local star = B.ball(m, "SpireOrnament", (cf * CFrame.new(0, 1.4, 0)).Position, 2.4, P.Gold, Enum.Material.Neon, false)
	B.pointLight(star, P.Gold, 18, 1)
	B.tag(star, "XmasBulb")
	-- Garland spiral of lights around the tower.
	local prev: Vector3? = nil
	for i = 0, 24 do
		local a = i / 24 * math.pi * 2
		local p = (H * CFrame.Angles(0, a, 0) * CFrame.new(0, 26.4, -R - 1.2)).Position
		if prev then
			B.stringLights(m, prev, p, 2.4, 0.5, if i % 4 == 0 then 4 else 0)
		end
		prev = p
	end
	-- Single-storey annex with a flat snowy roof.
	local annex = B.part({ Name = "Annex", Size = Vector3.new(18, 12, 16), CFrame = H * CFrame.new(R + 6, 7.1, 2), Color = body:Lerp(Color3.new(1, 1, 1), 0.15), Material = Enum.Material.Plaster, Parent = m })
	local annexRoof = B.part({ Name = "AnnexRoof", Size = Vector3.new(20, 1, 18), CFrame = annex.CFrame * CFrame.new(0, 6.5, 0), Color = trim, Material = Enum.Material.Wood, Parent = m })
	B.blob(m, "AnnexSnow", annexRoof.CFrame * CFrame.new(0, 0.6, 0), Vector3.new(19, 2.2, 17), P.Snow, Enum.Material.Snow, false)
	HP.window(m, annex.CFrame * CFrame.new(1, 0.5, -8.05), 6, 5, trim, true)
	HP.chimney(m, H * CFrame.new(R + 11, 1, 6), 18, 3.5)
	HP.yard(m, lot, { width = 84, depth = setback + R * 2 + 12, doorX = -6, doorZ = setback + 1, driveX = 28, mailboxColor = Color3.fromRGB(60, 150, 160), decoration = "presents", seed = 22 })
	return m
end

-------------------------------------------------------------------------------
-- 3. Gingerbread Lodge: steep A-frame with frosting trim and gumdrops.
-------------------------------------------------------------------------------
function Houses.gingerbreadLodge(parent: Instance, lot: CFrame): Model
	local m = B.model("GingerbreadLodge", parent)
	local W, D = 34, 36
	local setback = 32
	local H = lot * CFrame.new(-4, 0, setback + D / 2)
	local ginger = Color3.fromRGB(176, 104, 54)
	local frosting = Color3.fromRGB(255, 250, 245)
	foundation(m, H, W, D, Color3.fromRGB(120, 80, 60))
	-- Short knee walls; the roof does most of the work.
	local body = B.part({ Name = "Body", Size = Vector3.new(W, 8, D), CFrame = H * CFrame.new(0, 5.1, 0), Color = ginger, Material = Enum.Material.Wood, Parent = m })
	-- Steep roof: ridge runs front-to-back, so rotate the gable builder 90 degrees.
	local roofBase = H * CFrame.new(0, 9.1, 0) * CFrame.Angles(0, math.pi / 2, 0)
	B.gableRoof(m, roofBase, D, W, 24, 3, Color3.fromRGB(110, 60, 35), ginger)
	-- Frosting drips along both roof edges (a row of small balls).
	for _, side in { -1, 1 } do
		for i = 0, 14 do
			local z = -D / 2 - 2 + i * ((D + 4) / 14)
			B.ball(m, "Frosting", (H * CFrame.new(side * (W / 2 + 2.6), 8.6, z)).Position, 1.4, frosting, Enum.Material.SmoothPlastic, false)
		end
	end
	-- Gumdrops along the ridge.
	local gum = { P.Red, P.Green, Color3.fromRGB(250, 200, 60), Color3.fromRGB(200, 90, 200), Color3.fromRGB(80, 150, 255) }
	for i = 0, 6 do
		local z = -D / 2 + 1 + i * ((D - 2) / 6)
		local g = B.ball(m, "Gumdrop", (H * CFrame.new(0, 9.1 + 24 + 1.4, z)).Position, 2.2, gum[(i % #gum) + 1], Enum.Material.Glass, false)
		g.Transparency = 0.1
	end
	-- Front gable face: big round window and frosting outline.
	HP.window(m, H * CFrame.new(0, 20, -D / 2 - 0.5), 7, 7, frosting, true, true)
	-- Gable trim: frosting balls along the two rake edges.
	for _, side in { -1, 1 } do
		for i = 0, 10 do
			local t = i / 10
			local x = side * (W / 2 + 1) * (1 - t)
			local y = 9.1 + 24 * t
			B.ball(m, "Frosting", (H * CFrame.new(x, y, -D / 2 - 2.2)).Position, 1.1, frosting, nil, false)
		end
	end
	HP.door(m, H * CFrame.new(0, 1.1, -D / 2), 6, 8, Color3.fromRGB(220, 60, 70), frosting, false)
	for _, sx in { -1, 1 } do
		HP.window(m, H * CFrame.new(sx * 10, 5.5, -D / 2 - 0.1), 5, 4, frosting, true)
		HP.window(m, H * CFrame.new(sx * (W / 2 + 0.1), 5.5, 4) * CFrame.Angles(0, -sx * math.pi / 2, 0), 6, 4, frosting, true)
	end
	-- Peppermint discs beside the door.
	for _, sx in { -1, 1 } do
		local disc = B.hcyl(m, "Peppermint", H * CFrame.new(sx * 5.5, 4.5, -D / 2 - 0.4) * CFrame.Angles(0, math.pi / 2, 0), 0.4, 3, P.Snow, nil, false)
		B.part({ Name = "Stripe", Size = Vector3.new(0.45, 2.8, 0.6), CFrame = disc.CFrame, Color = P.Red, CanCollide = false, Parent = m })
		B.part({ Name = "Stripe", Size = Vector3.new(0.45, 0.6, 2.8), CFrame = disc.CFrame, Color = P.Red, CanCollide = false, Parent = m })
	end
	HP.chimney(m, H * CFrame.new(W / 4, 1, D / 4), 34, 3.5, Color3.fromRGB(240, 240, 240))
	HP.eaveLights(m, H, Vector3.new(-W / 2 - 3, 8.2, -D / 2 - 2), Vector3.new(-W / 2 - 3, 8.2, D / 2 + 2))
	HP.eaveLights(m, H, Vector3.new(W / 2 + 3, 8.2, -D / 2 - 2), Vector3.new(W / 2 + 3, 8.2, D / 2 + 2))
	HP.yard(m, lot, { width = 84, depth = setback + D + 12, doorX = -4, doorZ = setback, driveX = -30, mailboxColor = Color3.fromRGB(176, 104, 54), fenceColor = Color3.fromRGB(240, 120, 130), decoration = "candycanes", seed = 33 })
	return m
end

-------------------------------------------------------------------------------
-- 4. Twin Domes: mint house with two snowy onion domes.
-------------------------------------------------------------------------------
function Houses.twinDomes(parent: Instance, lot: CFrame): Model
	local m = B.model("TwinDomes", parent)
	local W, D, WH = 50, 32, 16
	local setback = 34
	local H = lot * CFrame.new(4, 0, setback + D / 2)
	local body = Color3.fromRGB(150, 210, 180)
	local domeColor = Color3.fromRGB(230, 120, 150)
	local trim = Color3.fromRGB(255, 255, 255)
	foundation(m, H, W, D)
	B.part({ Name = "Body", Size = Vector3.new(W, WH, D), CFrame = H * CFrame.new(0, 1.1 + WH / 2, 0), Color = body, Material = Enum.Material.Plaster, Parent = m })
	local roof = B.part({ Name = "Roof", Size = Vector3.new(W + 3, 1.2, D + 3), CFrame = H * CFrame.new(0, 1.1 + WH + 0.6, 0), Color = trim, Material = Enum.Material.Wood, Parent = m })
	B.snowCap(m, roof, 0.8, -0.5)
	for _, sx in { -1, 1 } do
		local base = H * CFrame.new(sx * 12, 1.1 + WH + 1.2, 0)
		B.vcyl(m, "Drum", base * CFrame.new(0, 2, 0), 4, 18, body:Lerp(Color3.new(1, 1, 1), 0.3), Enum.Material.Plaster)
		local dome = B.blob(m, "Dome", base * CFrame.new(0, 9, 0), Vector3.new(19, 18, 19), domeColor, Enum.Material.SmoothPlastic, true)
		B.blob(m, "DomeSnow", dome.CFrame * CFrame.new(0, 4.5, 0), Vector3.new(15, 9, 15), P.Snow, Enum.Material.Snow, false)
		B.vcyl(m, "Finial", base * CFrame.new(0, 20, 0), 4, 0.8, P.Gold, Enum.Material.Metal, false)
		local orb = B.ball(m, "FinialOrb", (base * CFrame.new(0, 22.5, 0)).Position, 1.6, P.Gold, Enum.Material.Neon, false)
		B.tag(orb, "XmasBulb")
		-- Round windows on each drum.
		HP.window(m, base * CFrame.new(0, 2, -9.1), 3, 3, trim, true, true)
		-- Lights around the drum base.
		local prev: Vector3? = nil
		for i = 0, 12 do
			local a = i / 12 * math.pi * 2
			local p = (base * CFrame.Angles(0, a, 0) * CFrame.new(0, 4.2, -9.6)).Position
			if prev then
				B.stringLights(m, prev, p, 2.2, 0.3, if i % 4 == 0 then 4 else 0)
			end
			prev = p
		end
	end
	-- Arched windows (round tops) along the front.
	for _, x in { -18, -9, 9, 18 } do
		HP.window(m, H * CFrame.new(x, 8, -D / 2 - 0.1), 5, 6, trim, true)
		B.hcyl(m, "Arch", H * CFrame.new(x, 11.2, -D / 2 - 0.1) * CFrame.Angles(0, math.pi / 2, 0), 0.35, 5, P.Window, Enum.Material.Neon, false)
	end
	HP.door(m, H * CFrame.new(0, 1.1, -D / 2), 7, 10, Color3.fromRGB(230, 120, 150), trim, false)
	HP.eaveLights(m, H, Vector3.new(-W / 2 - 1.5, 1.1 + WH - 0.4, -D / 2 - 1.6), Vector3.new(W / 2 + 1.5, 1.1 + WH - 0.4, -D / 2 - 1.6))
	-- Side porch with posts.
	for _, sx in { -1, 1 } do
		HP.window(m, H * CFrame.new(sx * (W / 2 + 0.1), 8, 0) * CFrame.Angles(0, -sx * math.pi / 2, 0), 8, 6, trim, true)
	end
	HP.yard(m, lot, { width = 84, depth = setback + D + 14, doorX = 4, doorZ = setback, driveX = -28, mailboxColor = domeColor, decoration = "snowman", seed = 44 })
	return m
end

-------------------------------------------------------------------------------
-- 5. Curlicue Townhouse: tall, narrow, with a stacked roof that curls over.
-------------------------------------------------------------------------------
function Houses.curlicueTownhouse(parent: Instance, lot: CFrame): Model
	local m = B.model("CurlicueTownhouse", parent)
	local W, D, WH = 28, 26, 30
	local setback = 36
	local H = lot * CFrame.new(-8, 0, setback + D / 2)
	local body = Color3.fromRGB(235, 190, 70)
	local trim = Color3.fromRGB(60, 80, 160)
	foundation(m, H, W, D)
	B.part({ Name = "Body", Size = Vector3.new(W, WH, D), CFrame = H * CFrame.new(0, 1.1 + WH / 2, 0), Color = body, Material = Enum.Material.WoodPlanks, Parent = m })
	-- Storey bands.
	for _, y in { 11, 21 } do
		B.part({ Name = "Band", Size = Vector3.new(W + 0.8, 0.8, D + 0.8), CFrame = H * CFrame.new(0, 1.1 + y, 0), Color = trim, Material = Enum.Material.Wood, Parent = m })
	end
	-- Bay window on the front.
	local bay = B.part({ Name = "Bay", Size = Vector3.new(12, 8, 4), CFrame = H * CFrame.new(-5, 15.5, -D / 2 - 2), Color = body, Material = Enum.Material.WoodPlanks, Parent = m })
	B.snowCap(m, B.part({ Name = "BayRoof", Size = Vector3.new(13, 0.8, 5), CFrame = bay.CFrame * CFrame.new(0, 4.4, 0), Color = trim, Material = Enum.Material.Wood, Parent = m }), 0.5, 0)
	HP.window(m, bay.CFrame * CFrame.new(0, 0, -2.05), 9, 5, P.Snow, true)
	-- Other windows.
	for _, p in { Vector2.new(7, 16), Vector2.new(-6, 26), Vector2.new(6, 26), Vector2.new(7, 6) } do
		HP.window(m, H * CFrame.new(p.X, p.Y, -D / 2 - 0.1), 4.5, 5, P.Snow, true)
	end
	for _, sx in { -1, 1 } do
		for _, y in { 6, 16, 26 } do
			HP.window(m, H * CFrame.new(sx * (W / 2 + 0.1), y, 0) * CFrame.Angles(0, -sx * math.pi / 2, 0), 4.5, 5, P.Snow, true)
		end
	end
	HP.door(m, H * CFrame.new(-6, 1.1, -D / 2), 5, 9, trim, P.Snow, false)
	-- Curling roof: slabs stacked upward, each shifted and rotated so the
	-- top leans over like a floppy hat.
	local cf = H * CFrame.new(0, 1.1 + WH, 0)
	local w, d = W + 4, D + 4
	for i = 1, 9 do
		local h = 2.6
		cf = cf * CFrame.new(0, h / 2, 0)
		local slab = B.part({ Name = "RoofTier", Size = Vector3.new(w, h, d), CFrame = cf, Color = if i % 2 == 0 then trim else trim:Lerp(Color3.new(1, 1, 1), 0.2), Material = Enum.Material.Slate, CanCollide = i <= 4, Parent = m })
		B.part({ Name = "RoofSnow", Size = Vector3.new(w * 0.9, 0.5, d * 0.9), CFrame = slab.CFrame * CFrame.new(0, h / 2 + 0.25, 0), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, CanCollide = false, Parent = m })
		w *= 0.82
		d *= 0.82
		cf = cf * CFrame.new(0, h / 2, 0) * CFrame.Angles(0, 0, math.rad(-4 - i * 2.2)) * CFrame.new(-0.5, 0, 0)
	end
	local bell = B.ball(m, "Pompom", (cf * CFrame.new(0, 1.2, 0)).Position, 2.6, P.Snow, Enum.Material.Snow, false)
	B.pointLight(bell, Color3.fromRGB(200, 220, 255), 10, 0.5)
	HP.chimney(m, H * CFrame.new(W / 2 - 3, 1.1, D / 2 - 3), WH + 10, 3.5, Color3.fromRGB(110, 60, 55))
	HP.eaveLights(m, H, Vector3.new(-W / 2 - 2, 1.1 + WH, -D / 2 - 2.1), Vector3.new(W / 2 + 2, 1.1 + WH, -D / 2 - 2.1))
	HP.yard(m, lot, { width = 84, depth = setback + D + 14, doorX = -14, doorZ = setback, driveX = 26, mailboxColor = trim, decoration = "presents", seed = 55 })
	return m
end

return Houses
