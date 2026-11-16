--!strict
-- Builds the menu GUI, routes between screens with transitions, and hands
-- off to Free Roam (and back).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Theme)
local Remotes = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Remotes)
local Music = require(script.Parent.Parent.Audio.MusicController)
local MusicZones = require(script.Parent.Parent.Audio.MusicZones)
local MenuCamera = require(script.Parent.Parent.MenuCamera)

local MenuController = {}

local player = Players.LocalPlayer
local DESIGN = Vector2.new(1240, 720)

local gui: ScreenGui
local root: Frame
local overlay: Frame
local hud: ScreenGui
local snowLayer: Frame
local screens: { [string]: { frame: Frame, onShow: ((any?) -> ())? } } = {}
local currentName: string? = nil
local busy = false

local IN_INFO = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local OUT_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function groupOf(frame: Frame): CanvasGroup
	return frame:FindFirstChild("Group") :: CanvasGroup
end

local router = {}
function router.show(name: string, params: any?)
	local target = screens[name]
	if not target or busy then
		return
	end
	busy = true
	local old = if currentName then screens[currentName] else nil
	if old and old ~= target then
		local g = groupOf(old.frame)
		Theme.tween(g, OUT_INFO, { GroupTransparency = 1, Position = UDim2.new(0, -40, 0, 0) }).Completed:Wait()
		old.frame.Visible = false
	end
	currentName = name
	if target.onShow then
		target.onShow(params)
	end
	local g = groupOf(target.frame)
	g.GroupTransparency = 1
	g.Position = UDim2.new(0, 40, 0, 0)
	target.frame.Visible = true
	Theme.tween(g, IN_INFO, { GroupTransparency = 0, Position = UDim2.new() })
	busy = false
end

local function toast(text: string)
	local t = Instance.new("TextLabel")
	t.AnchorPoint = Vector2.new(0.5, 1)
	t.Position = UDim2.new(0.5, 0, 1, 40)
	t.Size = UDim2.new(0, 640, 0, 50)
	t.BackgroundColor3 = Theme.Colors.Night
	t.BackgroundTransparency = 0.1
	t.Text = text
	t.TextWrapped = true
	t.FontFace = Theme.Fonts.Body
	t.TextSize = 18
	t.TextColor3 = Theme.Colors.Snow
	t.ZIndex = 20
	Theme.corner(t, 12)
	Theme.stroke(t, Theme.Colors.Gold, 2, 0.4)
	t.Parent = root
	Theme.tween(t, IN_INFO, { Position = UDim2.new(0.5, 0, 1, -20) })
	task.delay(3, function()
		Theme.tween(t, OUT_INFO, { Position = UDim2.new(0.5, 0, 1, 60), TextTransparency = 1, BackgroundTransparency = 1 }).Completed:Wait()
		t:Destroy()
	end)
end

local function fade(to: number, time: number)
	overlay.Visible = true
	Theme.tween(overlay, TweenInfo.new(time, Enum.EasingStyle.Sine), { BackgroundTransparency = to }).Completed:Wait()
	if to >= 1 then
		overlay.Visible = false
	end
end

-- Decorative falling snowflakes in front of the menu backdrop.
local function startMenuSnow()
	snowLayer = Instance.new("Frame")
	snowLayer.Name = "MenuSnow"
	snowLayer.BackgroundTransparency = 1
	snowLayer.Size = UDim2.fromScale(1, 1)
	snowLayer.ZIndex = 0
	snowLayer.Parent = gui
	local flakes = {}
	local rng = Random.new()
	for i = 1, 45 do
		local f = Instance.new("Frame")
		local s = rng:NextNumber(3, 8)
		f.Size = UDim2.new(0, s, 0, s)
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		f.BackgroundTransparency = rng:NextNumber(0.2, 0.6)
		f.BorderSizePixel = 0
		Theme.corner(f, 8)
		f.Parent = snowLayer
		flakes[i] = { frame = f, x = rng:NextNumber(), y = rng:NextNumber(), speed = rng:NextNumber(0.03, 0.08), sway = rng:NextNumber(0, 6.28) }
	end
	local t = 0
	RunService.RenderStepped:Connect(function(dt)
		if not snowLayer.Visible then
			return
		end
		t += dt
		for _, fl in flakes do
			fl.y += fl.speed * dt
			if fl.y > 1.05 then
				fl.y = -0.05
				fl.x = rng:NextNumber()
			end
			fl.frame.Position = UDim2.fromScale(fl.x + math.sin(t + fl.sway) * 0.01, fl.y)
		end
	end)
end

local function buildHud()
	hud = Instance.new("ScreenGui")
	hud.Name = "FreeRoamHUD"
	hud.ResetOnSpawn = false
	hud.IgnoreGuiInset = false
	hud.Enabled = false
	hud.Parent = player:WaitForChild("PlayerGui")
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(0, 70, 0, 8)
	holder.Size = UDim2.new(0, 120, 0, 46)
	holder.Parent = hud
	Theme.button(holder, { text = "MENU", color = Theme.Colors.Red, darkColor = Theme.Colors.RedDark, size = UDim2.fromScale(1, 1), textSize = 20 }, function()
		MenuController.returnToMenu()
	end)
	local tip = Theme.label(hud, "Free Roam: explore the town, Holly Lane, and the hideout up Summit Trail.", Theme.Fonts.Body, 16, Theme.Colors.Snow)
	tip.AnchorPoint = Vector2.new(0.5, 0)
	tip.Position = UDim2.new(0.5, 0, 0, 12)
	tip.Size = UDim2.new(0, 600, 0, 24)
	local s = Instance.new("UIStroke")
	s.Thickness = 2
	s.Color = Theme.Colors.Night
	s.Parent = tip
	task.delay(8, function()
		Theme.tween(tip, TweenInfo.new(1), { TextTransparency = 1 })
		Theme.tween(s, TweenInfo.new(1), { Transparency = 1 })
	end)
	-- Reserved: future sleigh speedometer (bottom center) and gift meter.
	local reserved = Instance.new("Frame")
	reserved.Name = "SleighHUDSlot"
	reserved.BackgroundTransparency = 1
	reserved.AnchorPoint = Vector2.new(0.5, 1)
	reserved.Position = UDim2.new(0.5, 0, 1, -16)
	reserved.Size = UDim2.new(0, 360, 0, 120)
	reserved.Parent = hud
end

function MenuController.startFreeRoam(missionId: string)
	if busy then
		return
	end
	busy = true
	fade(0, 0.5)
	Remotes.get("StartFreeRoam"):FireServer(missionId)
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("HumanoidRootPart", 10)
	MenuCamera.stop()
	gui.Enabled = false
	hud.Enabled = true
	Music.setState("Outside")
	MusicZones.start()
	task.wait(0.3)
	busy = false
	fade(1, 0.6)
end

function MenuController.returnToMenu()
	if busy then
		return
	end
	busy = true
	fade(0, 0.4)
	MusicZones.stop()
	Remotes.get("ReturnToMenu"):FireServer()
	hud.Enabled = false
	gui.Enabled = true
	MenuCamera.start()
	Music.setState("Menu")
	busy = false
	router.show("MainMenu")
	fade(1, 0.6)
end

function MenuController.start()
	gui = Instance.new("ScreenGui")
	gui.Name = "MainMenu"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Soft vignette so the UI reads over the bright town.
	local vignette = Instance.new("Frame")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.fromScale(1, 1)
	vignette.BackgroundColor3 = Theme.Colors.Night
	vignette.BorderSizePixel = 0
	local vg = Instance.new("UIGradient")
	vg.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(0.45, 0.8), NumberSequenceKeypoint.new(1, 0.35) })
	vg.Rotation = 90
	vg.Parent = vignette
	vignette.Parent = gui

	startMenuSnow()

	-- Fixed-size design container scaled to fit any screen (desktop, tablet, phone).
	root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(DESIGN.X, DESIGN.Y)
	root.Parent = gui
	local scale = Instance.new("UIScale")
	scale.Parent = root
	local function rescale()
		local vp = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.clamp(math.min(vp.X / DESIGN.X, vp.Y / DESIGN.Y), 0.35, 1.4)
	end
	rescale()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescale)

	overlay = Instance.new("Frame")
	overlay.Name = "Fade"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0
	overlay.ZIndex = 50
	overlay.Parent = gui

	local ctx = { root = root, router = router, toast = toast, startFreeRoam = MenuController.startFreeRoam }
	local Screens = script.Parent.Screens
	for _, name in { "MainMenu", "MissionSelect", "Party", "Upgrades", "SettingsScreen" } do
		local frame, onShow = require(Screens[name])(ctx)
		screens[if name == "SettingsScreen" then "Settings" else name] = { frame = frame, onShow = onShow }
	end

	buildHud()
	MenuCamera.start()
	Music.setState("Menu")
	router.show("MainMenu")
	fade(1, 1.2)
end

return MenuController
