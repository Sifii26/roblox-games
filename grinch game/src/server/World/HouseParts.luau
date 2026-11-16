--!strict
-- Shared house details: windows, doors, chimneys, eave lights, yards.
local B = require(script.Parent.Builder)
local Props = require(script.Parent.Props)
local P = B.Palette

local HouseParts = {}

-- Window centered on `cf` (cf faces outward along its LookVector).
-- `lit` = glowing neon pane (exterior-only houses). Otherwise glass that lets
-- interior light show through.
function HouseParts.window(parent: Instance, cf: CFrame, w: number, h: number, trim: Color3, lit: boolean, round: boolean?)
	local m = B.model("Window", parent)
	if round then
		local d = math.min(w, h)
		B.hcyl(m, "Frame", cf * CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0.15, 0, 0), 1.2, d + 0.8, trim, Enum.Material.Wood)
		B.hcyl(m, "Pane", cf * CFrame.Angles(0, math.pi / 2, 0) * CFrame.new(0.5, 0, 0), 1.2, d, P.Window, if lit then Enum.Material.Neon else Enum.Material.Glass)
		B.part({ Name = "Mullion", Size = Vector3.new(0.25, d, 0.3), CFrame = cf * CFrame.new(0, 0, -0.3), Color = trim, CanCollide = false, Parent = m })
		B.part({ Name = "Mullion", Size = Vector3.new(d, 0.25, 0.3), CFrame = cf * CFrame.new(0, 0, -0.3), Color = trim, CanCollide = false, Parent = m })
		return m
	end
	local pane = B.part({
		Name = "Pane",
		Size = Vector3.new(w, h, 0.3),
		CFrame = cf,
		Color = P.Window,
		Material = if lit then Enum.Material.Neon else Enum.Material.Glass,
		Transparency = if lit then 0 else 0.45,
		CastShadow = false,
		Parent = m,
	})
	pane:SetAttribute("WindowPane", true)
	local t = 0.6
	for _, side in { -1, 1 } do
		B.part({ Name = "FrameSide", Size = Vector3.new(t, h + t * 2, 1), CFrame = cf * CFrame.new(side * (w / 2 + t / 2), 0, -0.2), Color = trim, Material = Enum.Material.Wood, Parent = m })
		B.part({ Name = "Shutter", Size = Vector3.new(w * 0.32, h + 0.4, 0.3), CFrame = cf * CFrame.new(side * (w / 2 + t + w * 0.17), 0, -0.45), Color = trim:Lerp(Color3.new(0, 0, 0), 0.35), Material = Enum.Material.Wood, Parent = m })
	end
	B.part({ Name = "FrameTop", Size = Vector3.new(w + t * 2, t, 1), CFrame = cf * CFrame.new(0, h / 2 + t / 2, -0.2), Color = trim, Material = Enum.Material.Wood, Parent = m })
	local sill = B.part({ Name = "Sill", Size = Vector3.new(w + 1.6, 0.4, 1.6), CFrame = cf * CFrame.new(0, -h / 2 - 0.2, -0.5), Color = trim, Material = Enum.Material.Wood, Parent = m })
	B.snowCap(m, sill, 0.3, -0.2)
	B.part({ Name = "MullionV", Size = Vector3.new(0.25, h, 0.35), CFrame = cf * CFrame.new(0, 0, -0.05), Color = trim, CanCollide = false, Parent = m })
	B.part({ Name = "MullionH", Size = Vector3.new(w, 0.25, 0.35), CFrame = cf * CFrame.new(0, 0, -0.05), Color = trim, CanCollide = false, Parent = m })
	return m
end

-- Front door. `cf` = bottom center of the doorway, facing outward.
-- When `open` is true the door is swung inward so players can walk in
-- (interactive doors come in a later phase; the model is tagged for it).
function HouseParts.door(parent: Instance, cf: CFrame, w: number, h: number, color: Color3, trim: Color3, open: boolean?): Model
	local m = B.model("FrontDoor", parent)
	B.tag(m, "FutureDoor")
	for _, side in { -1, 1 } do
		B.part({ Name = "Jamb", Size = Vector3.new(0.7, h + 0.7, 1.4), CFrame = cf * CFrame.new(side * (w / 2 + 0.35), h / 2 + 0.35, -0.1), Color = trim, Material = Enum.Material.Wood, Parent = m })
	end
	B.part({ Name = "Header", Size = Vector3.new(w + 1.4, 0.8, 1.4), CFrame = cf * CFrame.new(0, h + 0.4, -0.1), Color = trim, Material = Enum.Material.Wood, Parent = m })
	local slabCf
	if open then
		-- Hinged on the right, swung ~100 degrees inward and out of the way.
		slabCf = cf * CFrame.new(w / 2, 0, 0.3) * CFrame.Angles(0, math.rad(100), 0) * CFrame.new(-w / 2, h / 2, 0)
	else
		slabCf = cf * CFrame.new(0, h / 2, 0.3)
	end
	local slab = B.part({ Name = "Slab", Size = Vector3.new(w, h, 0.4), CFrame = slabCf, Color = color, Material = Enum.Material.Wood, Parent = m })
	for _, py in { -0.25, 0.25 } do
		B.part({ Name = "Panel", Size = Vector3.new(w * 0.65, h * 0.3, 0.1), CFrame = slab.CFrame * CFrame.new(0, py * h, -0.22), Color = color:Lerp(Color3.new(0, 0, 0), 0.15), CanCollide = false, Parent = m })
	end
	B.ball(m, "Knob", (slab.CFrame * CFrame.new(w / 2 - 0.6, 0, -0.35)).Position, 0.35, P.Gold, Enum.Material.Metal, false)
	Props.wreath(m, slab.CFrame * CFrame.new(0, h * 0.27, -0.45), 2.2)
	-- Step and welcome light.
	local step = B.part({ Name = "Step", Size = Vector3.new(w + 3, 1, 3), CFrame = cf * CFrame.new(0, -0.5, -1.8), Color = P.Stone, Material = Enum.Material.Cobblestone, Parent = m })
	B.snowCap(m, step, 0.2, -0.6)
	local lamp = B.part({ Name = "PorchLamp", Size = Vector3.new(0.8, 1.2, 0.8), CFrame = cf * CFrame.new(w / 2 + 1.6, h * 0.75, -0.7), Color = P.Window, Material = Enum.Material.Neon, CanCollide = false, Parent = m })
	B.pointLight(lamp, P.WarmLight, 14, 1)
	m:SetAttribute("Width", w)
	m:SetAttribute("Height", h)
	return m
end

-- Brick chimney from `base` (ground point) up to `height`, with snow and a
-- marker attachment at the top for future chimney entry.
function HouseParts.chimney(parent: Instance, base: CFrame, height: number, width: number?, color: Color3?)
	local w = width or 4
	local m = B.model("Chimney", parent)
	local stack = B.part({ Name = "Stack", Size = Vector3.new(w, height, w), CFrame = base * CFrame.new(0, height / 2, 0), Color = color or Color3.fromRGB(150, 70, 60), Material = Enum.Material.Brick, Parent = m })
	local cap = B.part({ Name = "Cap", Size = Vector3.new(w + 1, 0.8, w + 1), CFrame = stack.CFrame * CFrame.new(0, height / 2 + 0.4, 0), Color = P.Stone, Material = Enum.Material.Concrete, Parent = m })
	B.part({ Name = "Snow", Size = Vector3.new(w + 1.2, 0.5, w + 1.2), CFrame = cap.CFrame * CFrame.new(0, 0.6, 0), Color = P.Snow, Material = Enum.Material.Snow, CastShadow = false, Parent = m })
	local entry = Instance.new("Attachment")
	entry.Name = "ChimneyEntry"
	entry.Parent = cap
	entry.Position = Vector3.new(0, 1, 0)
	B.tag(cap, "ChimneyEntry")
	return m
end

-- Front yard: walkway, driveway, mailbox, fence, trees and a decoration.
-- `lot` = point on the sidewalk edge in front of the house, LookVector toward the road.
-- `walkTo` = local Z where the front door is (negative = toward road from house center).
export type YardOpts = {
	width: number,
	depth: number,
	doorX: number,
	doorZ: number,
	driveX: number,
	mailboxColor: Color3,
	fenceColor: Color3?,
	decoration: string?, -- "snowman" | "candycanes" | "presents"
	seed: number,
}
function HouseParts.yard(parent: Instance, lot: CFrame, o: YardOpts)
	local m = B.model("Yard", parent)
	local rng = Random.new(o.seed)
	-- Local frame: LookVector toward road, so "toward road" is local -Z.
	-- Walkway from sidewalk to front door.
	local walkLen = o.doorZ
	B.part({ Name = "Walkway", Size = Vector3.new(5, 1, walkLen), CFrame = lot * CFrame.new(o.doorX, 0.15, walkLen / 2), Color = P.Stone, Material = Enum.Material.Cobblestone, Parent = m })
	-- Driveway.
	local driveLen = o.doorZ - 1
	local drive = B.part({ Name = "Driveway", Size = Vector3.new(16, 1, driveLen), CFrame = lot * CFrame.new(o.driveX, 0.12, driveLen / 2), Color = Color3.fromRGB(95, 95, 102), Material = Enum.Material.Concrete, Parent = m })
	drive:SetAttribute("SleighPath", true)
	for _, side in { -1, 1 } do
		B.part({ Name = "DriveSnow", Size = Vector3.new(1.5, 1.05, drive.Size.Z), CFrame = drive.CFrame * CFrame.new(side * 7.25, 0.03, 0), Color = P.Ice, Material = Enum.Material.Snow, CastShadow = false, Parent = m })
	end
	-- Mailbox beside the walkway.
	Props.mailbox(m, lot * CFrame.new(o.doorX + 5, 0, 2) * CFrame.Angles(0, math.pi, 0), o.mailboxColor)
	-- Low fence along the front, gapped for the walkway and driveway.
	local half = o.width / 2
	local gaps = { { o.doorX - 3, o.doorX + 3 }, { o.driveX - 9, o.driveX + 9 } }
	table.sort(gaps, function(a, b)
		return a[1] < b[1]
	end)
	local cursor = -half
	for _, g in gaps do
		local len = g[1] - cursor
		if len > 2 then
			Props.fence(m, lot * CFrame.new(cursor + len / 2, 0, 1.5), len, o.fenceColor)
		end
		cursor = g[2]
	end
	if half - cursor > 2 then
		Props.fence(m, lot * CFrame.new(cursor + (half - cursor) / 2, 0, 1.5), half - cursor, o.fenceColor)
	end
	-- Trees in the back corners and along the sides.
	for _, sx in { -1, 1 } do
		Props.pine(m, lot * CFrame.new(sx * (half - 6), 0, o.depth - 6), rng:NextNumber(20, 30), rng)
		if math.abs(sx * (half - 7) - o.driveX) > 14 then
			Props.pine(m, lot * CFrame.new(sx * (half - 7), 0, 12), rng:NextNumber(12, 16), rng)
		end
	end
	-- Bushes along the walkway.
	for i = 1, 2 do
		Props.bush(m, lot * CFrame.new(o.doorX - 5, 0, o.doorZ * (i / 3)), 3.2)
		Props.bush(m, lot * CFrame.new(o.doorX + 5, 0, o.doorZ * (i / 3) + 3), 3)
	end
	-- Yard decoration.
	local decoX = if o.driveX > o.doorX then o.doorX - 13 else o.doorX + 13
	if o.decoration == "snowman" then
		Props.snowman(m, lot * CFrame.new(decoX, 0, o.doorZ * 0.45) * CFrame.Angles(0, math.pi, 0))
	elseif o.decoration == "candycanes" then
		for i = 0, 3 do
			Props.candyCane(m, lot * CFrame.new(o.doorX - 3.4, 0, 4 + i * (o.doorZ - 6) / 3), 4)
			Props.candyCane(m, lot * CFrame.new(o.doorX + 3.4, 0, 4 + i * (o.doorZ - 6) / 3) * CFrame.Angles(0, math.pi, 0), 4)
		end
	elseif o.decoration == "presents" then
		local colors = { P.Red, P.Green, Color3.fromRGB(70, 110, 210), P.Gold }
		for i = 1, 4 do
			Props.present(m, lot * CFrame.new(decoX + rng:NextNumber(-3, 3), 0, o.doorZ * 0.45 + rng:NextNumber(-3, 3)) * CFrame.Angles(0, rng:NextNumber(0, 3), 0), Vector3.new(2.5, 2, 2.5) * rng:NextNumber(0.9, 1.6), colors[i])
		end
	end
	-- Snow mounds for a natural, uneven yard.
	for _ = 1, 4 do
		local x = rng:NextNumber(-half + 4, half - 4)
		if math.abs(x - o.driveX) > 10 and math.abs(x - o.doorX) > 5 then
			B.blob(m, "SnowMound", lot * CFrame.new(x, 0, rng:NextNumber(6, o.doorZ - 6)), Vector3.new(rng:NextNumber(6, 12), 2, rng:NextNumber(5, 9)), P.Snow, Enum.Material.Snow, false)
		end
	end
	return m
end

-- String lights along a horizontal edge given in the house's local frame.
function HouseParts.eaveLights(parent: Instance, house: CFrame, a: Vector3, b: Vector3, lightEvery: number?)
	return B.stringLights(parent, (house * CFrame.new(a)).Position, (house * CFrame.new(b)).Position, 2.4, 0.5, lightEvery or 8)
end

-- Invisible marker where a future present can spawn.
function HouseParts.presentSpot(parent: Instance, cf: CFrame, room: string)
	local spot = B.part({ Name = "PresentSpot", Size = Vector3.new(2, 0.2, 2), CFrame = cf * CFrame.new(0, 0.1, 0), Transparency = 1, CanCollide = false, CastShadow = false, Parent = parent })
	spot.CanQuery = false
	spot.CanTouch = false
	spot:SetAttribute("Room", room)
	B.tag(spot, "PresentSpot")
	return spot
end

return HouseParts
