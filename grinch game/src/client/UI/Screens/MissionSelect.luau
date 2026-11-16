--!strict
-- Mission cards. Only Free Roam is playable in Phase 1; the rest are shown
-- with a clear "Coming soon" state instead of pretending to work.
local Theme = require(script.Parent.Parent.Theme)
local Missions = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config.Missions)

local function formatCash(n: number): string
	local s = tostring(n)
	local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return "$" .. formatted
end

return function(ctx: any)
	local screen = Theme.screen(ctx.root, "MissionSelect")
	local group = screen:FindFirstChild("Group") :: CanvasGroup
	local mode = "Solo"

	Theme.header(group, "SELECT A MISSION", function()
		ctx.router.show(if mode == "Party" then "Party" else "MainMenu")
	end)

	local modeLabel = Theme.label(group, "", Theme.Fonts.Body, 18, Theme.Colors.Muted)
	modeLabel.Position = UDim2.new(0, 0, 0, 74)
	modeLabel.Size = UDim2.new(1, 0, 0, 24)

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Cards"
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.Position = UDim2.new(0, 0, 0, 110)
	scroller.Size = UDim2.new(1, 0, 1, -120)
	scroller.CanvasSize = UDim2.new()
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.X
	scroller.ScrollingDirection = Enum.ScrollingDirection.X
	scroller.ScrollBarThickness = 6
	scroller.ScrollBarImageColor3 = Theme.Colors.Gold
	scroller.Parent = group
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.Padding = UDim.new(0, 20)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = scroller
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = scroller

	for i, mission in Missions do
		local card = Theme.panel(scroller, mission.Id)
		card.LayoutOrder = i
		card.Size = UDim2.new(0, 270, 0, 470)
		card.ClipsDescendants = true

		local stripe = Instance.new("Frame")
		stripe.Name = "Accent"
		stripe.BackgroundColor3 = mission.Accent
		stripe.BorderSizePixel = 0
		stripe.Size = UDim2.new(1, 0, 0, 120)
		stripe.Parent = card
		Theme.gradient(stripe, Color3.new(1, 1, 1), Color3.fromRGB(150, 150, 170))
		local icon = Theme.label(stripe, if mission.Playable then "❄" else "🎁", Theme.Fonts.Title, 64, Theme.Colors.Snow)
		icon.Size = UDim2.fromScale(1, 1)

		local body = Instance.new("Frame")
		body.BackgroundTransparency = 1
		body.Position = UDim2.new(0, 16, 0, 132)
		body.Size = UDim2.new(1, -32, 1, -148)
		body.Parent = card
		local bl = Instance.new("UIListLayout")
		bl.Padding = UDim.new(0, 8)
		bl.SortOrder = Enum.SortOrder.LayoutOrder
		bl.Parent = body

		local name = Theme.label(body, mission.Name, Theme.Fonts.Heading, 26, Theme.Colors.Snow)
		name.LayoutOrder = 1
		name.TextXAlignment = Enum.TextXAlignment.Left

		local pills = Instance.new("Frame")
		pills.BackgroundTransparency = 1
		pills.Size = UDim2.new(1, 0, 0, 28)
		pills.LayoutOrder = 2
		pills.Parent = body
		local pl = Instance.new("UIListLayout")
		pl.FillDirection = Enum.FillDirection.Horizontal
		pl.Padding = UDim.new(0, 8)
		pl.Parent = pills
		local function pill(text: string, color: Color3)
			local p = Instance.new("TextLabel")
			p.AutomaticSize = Enum.AutomaticSize.X
			p.Size = UDim2.new(0, 0, 1, 0)
			p.BackgroundColor3 = color
			p.Text = text
			p.FontFace = Theme.Fonts.Bold
			p.TextSize = 15
			p.TextColor3 = Theme.Colors.Snow
			Theme.corner(p, 14)
			local pp = Instance.new("UIPadding")
			pp.PaddingLeft = UDim.new(0, 12)
			pp.PaddingRight = UDim.new(0, 12)
			pp.Parent = p
			p.Parent = pills
		end
		pill(mission.Difficulty:upper(), mission.Accent:Lerp(Color3.new(0, 0, 0), 0.25))
		if mission.Reward then
			pill(formatCash(mission.Reward), Color3.fromRGB(60, 120, 70))
		end

		local desc = Theme.label(body, mission.Description, Theme.Fonts.Body, 16, Theme.Colors.Muted)
		desc.LayoutOrder = 3
		desc.Size = UDim2.new(1, 0, 0, 150)
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextYAlignment = Enum.TextYAlignment.Top

		local btnHolder = Instance.new("Frame")
		btnHolder.BackgroundTransparency = 1
		btnHolder.AnchorPoint = Vector2.new(0.5, 1)
		btnHolder.Position = UDim2.new(0.5, 0, 1, -16)
		btnHolder.Size = UDim2.new(1, -32, 0, 58)
		btnHolder.Parent = card
		if mission.Playable then
			Theme.button(btnHolder, { text = "PLAY", color = Theme.Colors.Green, darkColor = Theme.Colors.GreenDark, size = UDim2.fromScale(1, 1) }, function()
				ctx.startFreeRoam(mission.Id)
			end)
		else
			Theme.button(btnHolder, { text = "LOCKED", size = UDim2.fromScale(1, 1), enabled = false, badge = "SOON" })
		end
	end

	return screen, function(params: any?)
		mode = if params and params.mode then params.mode else mode
		modeLabel.Text = if mode == "Party"
			then "Party mode: missions launch for your party in a later update. Free Roam works now."
			else "Solo"
	end
end
