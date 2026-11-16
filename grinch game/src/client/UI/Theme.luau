--!strict
-- Visual theme and small UI building helpers (buttons, panels, labels).
local TweenService = game:GetService("TweenService")

local Theme = {}

Theme.Colors = {
	Night = Color3.fromRGB(14, 22, 48),
	Panel = Color3.fromRGB(22, 34, 70),
	PanelLight = Color3.fromRGB(34, 50, 98),
	Red = Color3.fromRGB(200, 45, 55),
	RedDark = Color3.fromRGB(140, 25, 35),
	Green = Color3.fromRGB(46, 150, 86),
	GreenDark = Color3.fromRGB(28, 100, 58),
	Gold = Color3.fromRGB(246, 200, 90),
	Snow = Color3.fromRGB(245, 249, 255),
	Muted = Color3.fromRGB(170, 185, 220),
	Disabled = Color3.fromRGB(90, 98, 120),
}

Theme.Fonts = {
	Title = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular),
	Heading = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular),
	Body = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
	Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
}

local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local BOUNCE = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function Theme.tween(inst: Instance, info: TweenInfo, goal: { [string]: any }): Tween
	local t = TweenService:Create(inst, info, goal)
	t:Play()
	return t
end

function Theme.corner(parent: Instance, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 14)
	c.Parent = parent
	return c
end

function Theme.stroke(parent: Instance, color: Color3?, thickness: number?, transparency: number?)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Colors.Gold
	s.Thickness = thickness or 2
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

function Theme.gradient(parent: Instance, top: Color3, bottom: Color3)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(top, bottom)
	g.Rotation = 90
	g.Parent = parent
	return g
end

function Theme.padding(parent: Instance, px: number)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, px)
	p.PaddingBottom = UDim.new(0, px)
	p.PaddingLeft = UDim.new(0, px)
	p.PaddingRight = UDim.new(0, px)
	p.Parent = parent
	return p
end

function Theme.label(parent: Instance, text: string, font: Font, size: number, color: Color3?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.FontFace = font
	l.TextSize = size
	l.TextColor3 = color or Theme.Colors.Snow
	l.TextWrapped = true
	l.Size = UDim2.new(1, 0, 0, size + 8)
	l.Parent = parent
	return l
end

function Theme.panel(parent: Instance, name: string): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = Theme.Colors.Panel
	f.BackgroundTransparency = 0.08
	f.BorderSizePixel = 0
	Theme.corner(f, 20)
	Theme.stroke(f, Theme.Colors.Gold, 2, 0.35)
	Theme.gradient(f, Color3.new(1, 1, 1), Color3.fromRGB(190, 200, 230))
	f.Parent = parent
	return f
end

export type ButtonOpts = {
	text: string,
	color: Color3?,
	darkColor: Color3?,
	size: UDim2?,
	textSize: number?,
	enabled: boolean?,
	badge: string?, -- small tag such as "SOON"
}

-- Candy-style button with hover lift, press squash and click callback.
function Theme.button(parent: Instance, opts: ButtonOpts, onClick: (() -> ())?): TextButton
	local enabled = opts.enabled ~= false
	local color = if enabled then (opts.color or Theme.Colors.Red) else Theme.Colors.Disabled
	local dark = if enabled then (opts.darkColor or Theme.Colors.RedDark) else Color3.fromRGB(60, 66, 84)

	local holder = Instance.new("Frame")
	holder.Name = opts.text .. "Holder"
	holder.BackgroundTransparency = 1
	holder.Size = opts.size or UDim2.new(1, 0, 0, 64)
	holder.Parent = parent

	-- Darker "base" under the face gives a chunky 3D look.
	local base = Instance.new("Frame")
	base.Name = "Base"
	base.BackgroundColor3 = dark
	base.BorderSizePixel = 0
	base.Size = UDim2.new(1, 0, 1, 0)
	base.Position = UDim2.new(0, 0, 0, 0)
	Theme.corner(base, 16)
	base.Parent = holder

	local button = Instance.new("TextButton")
	button.Name = opts.text
	button.AutoButtonColor = false
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 1, -6)
	button.Position = UDim2.new(0, 0, 0, 0)
	button.Text = opts.text
	button.FontFace = Theme.Fonts.Heading
	button.TextSize = opts.textSize or 26
	button.TextColor3 = Theme.Colors.Snow
	button.Active = enabled
	Theme.corner(button, 16)
	Theme.gradient(button, Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 215))
	local stroke = Theme.stroke(button, Color3.new(1, 1, 1), 2, 0.6)
	local textStroke = Instance.new("UIStroke")
	textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	textStroke.Color = dark
	textStroke.Thickness = 2
	textStroke.Parent = button
	button.Parent = holder

	if opts.badge then
		local badge = Instance.new("TextLabel")
		badge.Name = "Badge"
		badge.AnchorPoint = Vector2.new(1, 0)
		badge.Position = UDim2.new(1, 6, 0, -8)
		badge.Size = UDim2.new(0, 64, 0, 22)
		badge.BackgroundColor3 = Theme.Colors.Gold
		badge.Text = opts.badge
		badge.FontFace = Theme.Fonts.Bold
		badge.TextSize = 13
		badge.TextColor3 = Theme.Colors.Night
		badge.ZIndex = 3
		Theme.corner(badge, 11)
		badge.Parent = holder
	end

	if not enabled then
		button.TextTransparency = 0.35
		return button
	end

	local up = UDim2.new(0, 0, 0, -3)
	local rest = UDim2.new(0, 0, 0, 0)
	local down = UDim2.new(0, 0, 0, 4)
	button.MouseEnter:Connect(function()
		Theme.tween(button, FAST, { Position = up })
		Theme.tween(stroke, FAST, { Transparency = 0.1 })
	end)
	button.MouseLeave:Connect(function()
		Theme.tween(button, FAST, { Position = rest })
		Theme.tween(stroke, FAST, { Transparency = 0.6 })
	end)
	button.MouseButton1Down:Connect(function()
		Theme.tween(button, FAST, { Position = down })
	end)
	button.MouseButton1Up:Connect(function()
		Theme.tween(button, BOUNCE, { Position = rest })
	end)
	button.Activated:Connect(function()
		Theme.tween(button, BOUNCE, { Position = rest })
		if onClick then
			onClick()
		end
	end)
	return button
end

-- Screen-sized container that the router fades and slides in/out.
function Theme.screen(parent: Instance, name: string): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundTransparency = 1
	f.Size = UDim2.fromScale(1, 1)
	f.Visible = false
	f.Parent = parent
	local group = Instance.new("CanvasGroup")
	group.Name = "Group"
	group.BackgroundTransparency = 1
	group.Size = UDim2.fromScale(1, 1)
	group.Parent = f
	return f
end

-- Header used by sub-screens: back button on the left, title centered.
function Theme.header(parent: Instance, title: string, onBack: () -> ()): Frame
	local bar = Instance.new("Frame")
	bar.Name = "Header"
	bar.BackgroundTransparency = 1
	bar.Size = UDim2.new(1, 0, 0, 70)
	bar.Parent = parent
	local back = Theme.button(bar, { text = "< BACK", color = Theme.Colors.PanelLight, darkColor = Theme.Colors.Night, size = UDim2.new(0, 130, 0, 52), textSize = 22 }, onBack)
	local holder = back.Parent :: Frame
	holder.Position = UDim2.new(0, 0, 0.5, -26)
	local t = Theme.label(bar, title, Theme.Fonts.Title, 40, Theme.Colors.Gold)
	t.Size = UDim2.new(1, -300, 1, 0)
	t.Position = UDim2.new(0, 150, 0, 0)
	t.TextScaled = true
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MaxTextSize = 44
	constraint.Parent = t
	local s = Instance.new("UIStroke")
	s.Color = Theme.Colors.RedDark
	s.Thickness = 3
	s.Parent = t
	return bar
end

return Theme
