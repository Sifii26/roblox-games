--!strict
-- Client-side decoration animation:
--   XmasBulb  - parts cycle through bulb colors in a chasing pattern
--   Flicker   - lanterns/fires gently flicker their light brightness
--   SpinSlow  - slowly rotates (tree star)
-- Only parts near the camera are updated to keep it cheap.
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Settings = require(script.Parent.Parent.Settings)

local LightAnimator = {}

local COLORS = {
	Color3.fromRGB(255, 70, 70),
	Color3.fromRGB(80, 220, 110),
	Color3.fromRGB(255, 200, 60),
	Color3.fromRGB(80, 150, 255),
	Color3.fromRGB(255, 120, 220),
}
local RANGE = 300

function LightAnimator.start()
	local phase = 0
	local baseBrightness: { [Light]: number } = {}

	task.spawn(function()
		while true do
			task.wait(0.6)
			if Settings.get("AnimatedLights") then
				phase += 1
				local cam = Workspace.CurrentCamera
				local camPos = if cam then cam.CFrame.Position else Vector3.zero
				for _, bulb in CollectionService:GetTagged("XmasBulb") do
					if bulb:IsA("BasePart") and (bulb.Position - camPos).Magnitude < RANGE then
						local i = (bulb:GetAttribute("Index") :: number?) or 0
						local color = COLORS[((i + phase) % #COLORS) + 1]
						bulb.Color = color
						local light = bulb:FindFirstChildOfClass("PointLight")
						if light then
							light.Color = color
						end
					end
				end
			end
		end
	end)

	local t = 0
	RunService.Heartbeat:Connect(function(dt)
		t += dt
		local cam = Workspace.CurrentCamera
		local camPos = if cam then cam.CFrame.Position else Vector3.zero
		for _, part in CollectionService:GetTagged("Flicker") do
			if part:IsA("BasePart") and (part.Position - camPos).Magnitude < 150 then
				local light = part:FindFirstChildWhichIsA("Light")
				if light then
					local base = baseBrightness[light]
					if not base then
						base = light.Brightness
						baseBrightness[light] = base
					end
					local seed = part.Position.X * 0.37 + part.Position.Z * 0.11
					light.Brightness = base * (0.85 + 0.15 * math.noise(t * 3, seed))
				end
			end
		end
		for _, part in CollectionService:GetTagged("SpinSlow") do
			if part:IsA("BasePart") then
				-- Rotate about world Y so multi-part stars stay aligned.
				local pos = part.Position
				part.CFrame = CFrame.new(pos) * CFrame.Angles(0, dt * 0.4, 0) * (part.CFrame - pos)
			end
		end
	end)
end

return LightAnimator
