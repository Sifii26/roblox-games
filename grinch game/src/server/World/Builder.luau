--!strict
-- Small helpers for building anchored geometry from code.
-- Every world module uses these so the art style stays consistent.
local CollectionService = game:GetService("CollectionService")

local Builder = {}

export type PartProps = {
	Name: string?,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3?,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
	Transparency: number?,
	CanCollide: boolean?,
	CastShadow: boolean?,
	Reflectance: number?,
	Parent: Instance?,
	Class: string?, -- "Part" (default) | "WedgePart" | "CornerWedgePart"
}

function Builder.part(p: PartProps): BasePart
	local part: BasePart = Instance.new((p.Class or "Part") :: any)
	part.Name = p.Name or "Part"
	part.Anchored = true
	if p.Shape and part:IsA("Part") then
		(part :: Part).Shape = p.Shape
	end
	part.Size = p.Size
	part.CFrame = p.CFrame
	part.Color = p.Color or Color3.new(1, 1, 1)
	part.Material = p.Material or Enum.Material.SmoothPlastic
	part.Transparency = p.Transparency or 0
	part.Reflectance = p.Reflectance or 0
	part.CanCollide = if p.CanCollide == nil then true else p.CanCollide
	part.CastShadow = if p.CastShadow == nil then true else p.CastShadow
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = p.Parent
	return part
end

function Builder.model(name: string, parent: Instance?): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent
	return m
end

function Builder.folder(name: string, parent: Instance?): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

-- Cylinder standing upright (Roblox cylinders run along X, so rotate them).
function Builder.vcyl(parent: Instance, name: string, center: CFrame, height: number, diameter: number, color: Color3, material: Enum.Material?, collide: boolean?): BasePart
	return Builder.part({
		Name = name,
		Size = Vector3.new(height, diameter, diameter),
		CFrame = center * CFrame.Angles(0, 0, math.pi / 2),
		Color = color,
		Material = material,
		Shape = Enum.PartType.Cylinder,
		CanCollide = collide,
		Parent = parent,
	})
end

-- Cylinder lying along the given CFrame's X axis.
function Builder.hcyl(parent: Instance, name: string, cf: CFrame, length: number, diameter: number, color: Color3, material: Enum.Material?, collide: boolean?): BasePart
	return Builder.part({
		Name = name,
		Size = Vector3.new(length, diameter, diameter),
		CFrame = cf,
		Color = color,
		Material = material,
		Shape = Enum.PartType.Cylinder,
		CanCollide = collide,
		Parent = parent,
	})
end

function Builder.ball(parent: Instance, name: string, pos: Vector3, diameter: number, color: Color3, material: Enum.Material?, collide: boolean?): BasePart
	return Builder.part({
		Name = name,
		Size = Vector3.new(diameter, diameter, diameter),
		CFrame = CFrame.new(pos),
		Color = color,
		Material = material,
		Shape = Enum.PartType.Ball,
		CanCollide = collide,
		Parent = parent,
	})
end

-- Non-uniform rounded blob (ellipsoid) using a Sphere SpecialMesh.
-- Good for snow mounds, bushes and stylized pine tiers.
function Builder.blob(parent: Instance, name: string, cf: CFrame, size: Vector3, color: Color3, material: Enum.Material?, collide: boolean?): BasePart
	local part = Builder.part({
		Name = name,
		Size = size,
		CFrame = cf,
		Color = color,
		Material = material,
		CanCollide = collide,
		Parent = parent,
	})
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = part
	return part
end

-- A thin layer of snow resting on top of a block.
function Builder.snowCap(parent: Instance, onto: BasePart, thickness: number?, overhang: number?)
	local t = thickness or 0.6
	local o = overhang or 0.4
	local size = onto.Size
	return Builder.part({
		Name = "Snow",
		Size = Vector3.new(size.X + o, t, size.Z + o),
		CFrame = onto.CFrame * CFrame.new(0, size.Y / 2 + t / 2, 0),
		Color = Builder.Palette.Snow,
		Material = Enum.Material.Snow,
		CastShadow = false,
		Parent = parent,
	})
end

function Builder.tag(inst: Instance, tag: string)
	CollectionService:AddTag(inst, tag)
end

function Builder.pointLight(part: BasePart, color: Color3, range: number, brightness: number, shadows: boolean?)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Shadows = shadows or false
	l.Parent = part
	return l
end

function Builder.surfaceLight(part: BasePart, face: Enum.NormalId, color: Color3, range: number, brightness: number, angle: number?)
	local l = Instance.new("SurfaceLight")
	l.Face = face
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Angle = angle or 120
	l.Parent = part
	return l
end

-- Builds a straight wall along the local X axis of `origin` (origin = left
-- bottom corner, wall grows toward +X and +Y, thickness centered on Z).
-- `openings` cut doors/windows: { x = offset from left, w = width, y = bottom, h = height }.
export type Opening = { x: number, w: number, y: number, h: number }
function Builder.wall(parent: Instance, name: string, origin: CFrame, length: number, height: number, thickness: number, color: Color3, material: Enum.Material?, openings: { Opening }?)
	local ops = table.clone(openings or {})
	table.sort(ops, function(a, b)
		return a.x < b.x
	end)

	local function seg(x0: number, x1: number, y0: number, y1: number)
		if x1 - x0 < 0.05 or y1 - y0 < 0.05 then
			return
		end
		Builder.part({
			Name = name,
			Size = Vector3.new(x1 - x0, y1 - y0, thickness),
			CFrame = origin * CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, 0),
			Color = color,
			Material = material,
			Parent = parent,
		})
	end

	local cursor = 0
	for _, o in ops do
		seg(cursor, o.x, 0, height) -- solid wall before the opening
		seg(o.x, o.x + o.w, 0, o.y) -- below the opening
		seg(o.x, o.x + o.w, o.y + o.h, height) -- above the opening
		cursor = o.x + o.w
	end
	seg(cursor, length, 0, height)
end

-- Two-piece gable roof with ridge along local X of `base` (base = center of the
-- top of the walls). Includes snow layers that follow the slope and
-- triangular gable ends made from wedges.
function Builder.gableRoof(parent: Instance, base: CFrame, length: number, depth: number, rise: number, overhang: number, color: Color3, wallColor: Color3)
	local half = depth / 2
	local slopeLen = math.sqrt(half * half + rise * rise)
	local angle = math.atan2(rise, half)
	local thick = 1.2
	for _, side in { -1, 1 } do
		-- Slab centered halfway down the slope, tilted toward the side.
		local cf = base
			* CFrame.new(0, rise / 2, side * half / 2)
			* CFrame.Angles(side * angle, 0, 0)
			* CFrame.new(0, thick / 2, 0)
		local slab = Builder.part({
			Name = "RoofSlab",
			Size = Vector3.new(length + overhang * 2, thick, slopeLen + overhang),
			CFrame = cf,
			Color = color,
			Material = Enum.Material.Slate,
			Parent = parent,
		})
		Builder.part({
			Name = "RoofSnow",
			Size = Vector3.new(slab.Size.X - 0.6, 0.9, slab.Size.Z - 0.8),
			CFrame = slab.CFrame * CFrame.new(0, thick / 2 + 0.45, -side * 0.3),
			Color = Builder.Palette.Snow,
			Material = Enum.Material.Snow,
			CastShadow = false,
			Parent = parent,
		})
	end
	-- Gable ends: two wedges per end. A WedgePart's tall edge is on its +Z (back)
	-- side and its slope faces -Z, so the wedge on the -Z half points its tall
	-- edge toward the ridge unrotated, and the +Z half is turned 180 degrees.
	for _, endSide in { -1, 1 } do
		for _, side in { -1, 1 } do
			local rot = if side == -1 then CFrame.new() else CFrame.Angles(0, math.pi, 0)
			Builder.part({
				Class = "WedgePart",
				Name = "Gable",
				Size = Vector3.new(0.8, rise, half),
				CFrame = base * CFrame.new(endSide * (length / 2 - 0.4), rise / 2, side * half / 2) * rot,
				Color = wallColor,
				Material = Enum.Material.WoodPlanks,
				Parent = parent,
			})
		end
	end
end

-- A string of Christmas bulbs between two points. Bulbs are tagged so the
-- client can animate them; only every few bulbs gets a real light for performance.
local BULB_COLORS = {
	Color3.fromRGB(255, 70, 70),
	Color3.fromRGB(80, 220, 110),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(80, 150, 255),
	Color3.fromRGB(255, 120, 220),
}
function Builder.stringLights(parent: Instance, a: Vector3, b: Vector3, spacing: number?, sag: number?, lightEvery: number?)
	local folder = Builder.model("StringLights", parent)
	local dist = (b - a).Magnitude
	local count = math.max(2, math.floor(dist / (spacing or 2.5)))
	local s = sag or 0.6
	local every = lightEvery or 0
	local prev: Vector3? = nil
	for i = 0, count do
		local t = i / count
		local pos = a:Lerp(b, t) - Vector3.new(0, math.sin(t * math.pi) * s, 0)
		if prev then
			local mid = (prev + pos) / 2
			local len = (pos - prev).Magnitude
			Builder.part({
				Name = "Wire",
				Size = Vector3.new(0.12, 0.12, len),
				CFrame = CFrame.lookAt(mid, pos),
				Color = Color3.fromRGB(30, 50, 30),
				CanCollide = false,
				CastShadow = false,
				Parent = folder,
			})
		end
		local bulb = Builder.part({
			Name = "Bulb",
			Size = Vector3.new(0.45, 0.6, 0.45),
			CFrame = CFrame.new(pos - Vector3.new(0, 0.3, 0)),
			Color = BULB_COLORS[(i % #BULB_COLORS) + 1],
			Material = Enum.Material.Neon,
			CanCollide = false,
			CastShadow = false,
			Parent = folder,
		})
		bulb:SetAttribute("Index", i)
		Builder.tag(bulb, "XmasBulb")
		if every > 0 and i % every == 0 then
			Builder.pointLight(bulb, bulb.Color, 7, 0.8)
		end
		prev = pos
	end
	return folder
end

Builder.Palette = {
	Snow = Color3.fromRGB(242, 247, 255),
	Ice = Color3.fromRGB(200, 225, 245),
	Road = Color3.fromRGB(70, 74, 86),
	RoadLine = Color3.fromRGB(230, 200, 120),
	Sidewalk = Color3.fromRGB(165, 165, 175),
	Cobble = Color3.fromRGB(120, 112, 118),
	Wood = Color3.fromRGB(110, 72, 45),
	DarkWood = Color3.fromRGB(70, 45, 30),
	Pine = Color3.fromRGB(34, 92, 62),
	PineDark = Color3.fromRGB(24, 70, 48),
	Window = Color3.fromRGB(255, 196, 110),
	WarmLight = Color3.fromRGB(255, 180, 100),
	Iron = Color3.fromRGB(40, 40, 46),
	Gold = Color3.fromRGB(240, 196, 80),
	Red = Color3.fromRGB(190, 40, 45),
	Green = Color3.fromRGB(40, 130, 70),
	Stone = Color3.fromRGB(130, 128, 136),
	Rock = Color3.fromRGB(96, 98, 110),
}

return Builder
