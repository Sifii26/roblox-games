--!strict
-- World snowfall that follows the camera. Rate scales with the Snow Quality
-- setting so low-end devices can turn it down or off.
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Settings = require(script.Parent.Parent.Settings)

local Snowfall = {}

local RATES = { Off = 0, Low = 60, Medium = 160, High = 340 }

function Snowfall.start()
	local emitterPart = Instance.new("Part")
	emitterPart.Name = "SnowEmitter"
	emitterPart.Anchored = true
	emitterPart.CanCollide = false
	emitterPart.CanQuery = false
	emitterPart.CanTouch = false
	emitterPart.Transparency = 1
	emitterPart.Size = Vector3.new(180, 1, 180)
	emitterPart.Parent = Workspace.CurrentCamera

	local e = Instance.new("ParticleEmitter")
	e.Texture = "rbxasset://textures/particles/smoke_main.dds"
	e.Color = ColorSequence.new(Color3.new(1, 1, 1))
	e.LightEmission = 0.4
	e.LightInfluence = 0.6
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.25) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.1), NumberSequenceKeypoint.new(0.85, 0.2), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(7, 10)
	e.Speed = NumberRange.new(6, 9)
	e.EmissionDirection = Enum.NormalId.Bottom
	e.SpreadAngle = Vector2.new(15, 15)
	e.Acceleration = Vector3.new(1.5, 0, 0.8)
	e.RotSpeed = NumberRange.new(-40, 40)
	e.Rotation = NumberRange.new(0, 360)
	e.Shape = Enum.ParticleEmitterShape.Box
	e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	e.Parent = emitterPart

	local function apply()
		local rate = RATES[Settings.get("SnowQuality")] or 0
		e.Rate = rate
		e.Enabled = rate > 0
	end
	apply()
	Settings.Changed:Connect(function(key)
		if key == "SnowQuality" then
			apply()
		end
	end)

	RunService.RenderStepped:Connect(function()
		local cam = Workspace.CurrentCamera
		if cam then
			local p = cam.CFrame.Position
			emitterPart.CFrame = CFrame.new(p.X, p.Y + 45, p.Z) + cam.CFrame.LookVector * Vector3.new(40, 0, 40)
		end
	end)
end

return Snowfall
