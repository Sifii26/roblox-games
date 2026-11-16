--!strict
-- Settings: music on/off, music volume slider, snow quality, animated lights.
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Parent.Theme)
local Settings = require(script.Parent.Parent.Parent.Settings)
local Music = require(script.Parent.Parent.Parent.Audio.MusicController)

local function row(parent: Instance, label: string, order: number): Frame
	local r = Instance.new("Frame")
	r.BackgroundTransparency = 1
	r.Size = UDim2.new(1, 0, 0, 64)
	r.LayoutOrder = order
	r.Parent = parent
	local l = Theme.label(r, label, Theme.Fonts.Heading, 24, Theme.Colors.Snow)
	l.Size = UDim2.new(0.4, 0, 1, 0)
	l.TextXAlignment = Enum.TextXAlignment.Left
	return r
end

local function toggle(parent: Frame, key: string)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(1, 0.5)
	holder.Position = UDim2.new(1, 0, 0.5, 0)
	holder.Size = UDim2.new(0, 180, 0, 54)
	holder.Parent = parent
	local btn: TextButton
	local function refresh()
		local on = Settings.get(key)
		btn.Text = if on then "ON" else "OFF"
		btn.BackgroundColor3 = if on then Theme.Colors.Green else Theme.Colors.Disabled
		local baseFrame = (btn.Parent :: Instance):FindFirstChild("Base") :: Frame?
		if baseFrame then
			baseFrame.BackgroundColor3 = if on then Theme.Colors.GreenDark else Color3.fromRGB(60, 66, 84)
		end
	end
	btn = Theme.button(holder, { text = "ON", color = Theme.Colors.Green, darkColor = Theme.Colors.GreenDark, size = UDim2.fromScale(1, 1), textSize = 22 }, function()
		Settings.set(key, not Settings.get(key))
		refresh()
	end)
	refresh()
end

return function(ctx: any)
	local screen = Theme.screen(ctx.root, "Settings")
	local group = screen:FindFirstChild("Group") :: CanvasGroup
	Theme.header(group, "SETTINGS", function()
		ctx.router.show("MainMenu")
	end)

	local panel = Theme.panel(group, "Panel")
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 100)
	panel.Size = UDim2.new(0, 700, 0, 470)
	Theme.padding(panel, 28)
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 14)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = panel

	toggle(row(panel, "Music", 1), "MusicEnabled")

	-- Volume slider.
	local volRow = row(panel, "Music Volume", 2)
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -70, 0.5, 0)
	track.Size = UDim2.new(0.5, -40, 0, 14)
	track.BackgroundColor3 = Theme.Colors.Night
	Theme.corner(track, 7)
	track.Parent = volRow
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = Theme.Colors.Gold
	fill.Size = UDim2.fromScale(Settings.get("MusicVolume"), 1)
	Theme.corner(fill, 7)
	fill.Parent = track
	local knob = Instance.new("TextButton")
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(Settings.get("MusicVolume"), 0, 0.5, 0)
	knob.Size = UDim2.new(0, 30, 0, 30)
	knob.BackgroundColor3 = Theme.Colors.Snow
	Theme.corner(knob, 15)
	Theme.stroke(knob, Theme.Colors.Gold, 3)
	knob.Parent = track
	local pct = Theme.label(volRow, "", Theme.Fonts.Bold, 20, Theme.Colors.Snow)
	pct.AnchorPoint = Vector2.new(1, 0.5)
	pct.Position = UDim2.new(1, 0, 0.5, 0)
	pct.Size = UDim2.new(0, 60, 0, 30)
	local function setFromX(x: number)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
		rel = math.floor(rel * 20 + 0.5) / 20
		Settings.set("MusicVolume", rel)
	end
	local function refreshVol()
		local v = Settings.get("MusicVolume")
		fill.Size = UDim2.fromScale(v, 1)
		knob.Position = UDim2.new(v, 0, 0.5, 0)
		pct.Text = string.format("%d%%", math.floor(v * 100 + 0.5))
	end
	refreshVol()
	local dragging = false
	local function beginDrag(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(input.Position.X)
		end
	end
	knob.InputBegan:Connect(beginDrag)
	track.InputBegan:Connect(beginDrag)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	Settings.Changed:Connect(function(key)
		if key == "MusicVolume" then
			refreshVol()
		end
	end)

	-- Snow quality selector.
	local snowRow = row(panel, "Snowfall", 3)
	local opts = Instance.new("Frame")
	opts.BackgroundTransparency = 1
	opts.AnchorPoint = Vector2.new(1, 0.5)
	opts.Position = UDim2.new(1, 0, 0.5, 0)
	opts.Size = UDim2.new(0.6, 0, 0, 50)
	opts.Parent = snowRow
	local ol = Instance.new("UIListLayout")
	ol.FillDirection = Enum.FillDirection.Horizontal
	ol.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ol.Padding = UDim.new(0, 8)
	ol.Parent = opts
	local optionButtons: { [string]: TextButton } = {}
	local function refreshSnow()
		for level, b in optionButtons do
			local selected = Settings.get("SnowQuality") == level
			b.BackgroundColor3 = if selected then Theme.Colors.Red else Theme.Colors.PanelLight
		end
	end
	for _, level in Settings.SnowLevels do
		optionButtons[level] = Theme.button(opts, { text = level:upper(), color = Theme.Colors.PanelLight, darkColor = Theme.Colors.Night, size = UDim2.new(0, 92, 1, 0), textSize = 16 }, function()
			Settings.set("SnowQuality", level)
			refreshSnow()
		end)
	end
	refreshSnow()

	toggle(row(panel, "Animated Lights", 4), "AnimatedLights")

	local hasMusic = Music.hasTrack("Menu") or Music.hasTrack("Outside")
	local info = Theme.label(panel, if hasMusic
		then "Lower the snowfall if the game feels slow on your device."
		else "No music tracks are set up yet. Add licensed track IDs in Shared/Config/Audio.", Theme.Fonts.Body, 15, Theme.Colors.Muted)
	info.LayoutOrder = 5
	info.Size = UDim2.new(1, 0, 0, 40)
	return screen
end
