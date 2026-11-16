--!strict
-- Cinematic camera for the main menu: slow glides between shots over town.
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Layout = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config.Layout)

local MenuCamera = {}

local SHOTS = {
	{ from = Layout.MenuCamera.Position, to = Layout.MenuCamera.Position + Vector3.new(90, -10, -30), look = Layout.MenuCamera.LookAt },
	{ from = Vector3.new(70, 45, 90), to = Vector3.new(-60, 55, 95), look = Vector3.new(0, 30, 0) },
	{ from = Vector3.new(-300, 40, 70), to = Vector3.new(-200, 35, 75), look = Vector3.new(-260, 12, -40) },
	{ from = Vector3.new(80, 170, 560), to = Vector3.new(-60, 175, 570), look = Vector3.new(-80, 0, 0) },
}
local SHOT_TIME = 14

local running = false
local current: Tween? = nil

function MenuCamera.start()
	if running then
		return
	end
	running = true
	local cam = Workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	cam.FieldOfView = 60
	task.spawn(function()
		local i = 1
		while running do
			local shot = SHOTS[i]
			cam.CFrame = CFrame.lookAt(shot.from, shot.look)
			current = TweenService:Create(cam, TweenInfo.new(SHOT_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { CFrame = CFrame.lookAt(shot.to, shot.look) })
			current:Play()
			local elapsed = 0
			while running and elapsed < SHOT_TIME do
				elapsed += task.wait(0.1)
			end
			i = i % #SHOTS + 1
		end
	end)
end

function MenuCamera.stop()
	running = false
	if current then
		current:Cancel()
		current = nil
	end
	local cam = Workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	cam.FieldOfView = 70
end

return MenuCamera
