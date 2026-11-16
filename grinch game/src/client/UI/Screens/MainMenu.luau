--!strict
-- Title screen with the four main buttons.
local Theme = require(script.Parent.Parent.Theme)
local GameInfo = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config.GameInfo)

return function(ctx: any)
	local screen = Theme.screen(ctx.root, "MainMenu")
	local group = screen:FindFirstChild("Group") :: CanvasGroup

	-- Title block.
	local titleHolder = Instance.new("Frame")
	titleHolder.Name = "Title"
	titleHolder.BackgroundTransparency = 1
	titleHolder.AnchorPoint = Vector2.new(0.5, 0)
	titleHolder.Position = UDim2.new(0.5, 0, 0, 30)
	titleHolder.Size = UDim2.new(0, 900, 0, 190)
	titleHolder.Parent = group

	local title = Theme.label(titleHolder, GameInfo.Title, Theme.Fonts.Title, 96, Theme.Colors.Snow)
	title.Size = UDim2.new(1, 0, 0, 120)
	title.TextScaled = true
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 236, 170)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(246, 190, 80)),
	})
	grad.Rotation = 90
	grad.Parent = title
	local outline = Instance.new("UIStroke")
	outline.Color = Theme.Colors.RedDark
	outline.Thickness = 5
	outline.Parent = title

	local sub = Theme.label(titleHolder, GameInfo.Subtitle:upper(), Theme.Fonts.Heading, 28, Theme.Colors.Gold)
	sub.Position = UDim2.new(0, 0, 0, 122)
	sub.Size = UDim2.new(1, 0, 0, 34)
	local subStroke = Instance.new("UIStroke")
	subStroke.Color = Theme.Colors.Night
	subStroke.Thickness = 2
	subStroke.Parent = sub

	-- Gentle bob on the title.
	task.spawn(function()
		local up = true
		while title.Parent do
			Theme.tween(title, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(0, 0, 0, if up then -6 else 4) })
			up = not up
			task.wait(2.4)
		end
	end)

	-- Buttons.
	local column = Instance.new("Frame")
	column.Name = "Buttons"
	column.BackgroundTransparency = 1
	column.AnchorPoint = Vector2.new(0.5, 0)
	column.Position = UDim2.new(0.5, 0, 0, 250)
	column.Size = UDim2.new(0, 400, 0, 360)
	column.Parent = group
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 16)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = column

	local buttons = {
		{ "SINGLE PLAYER", Theme.Colors.Red, Theme.Colors.RedDark, function()
			ctx.router.show("MissionSelect", { mode = "Solo" })
		end },
		{ "MULTIPLAYER", Theme.Colors.Green, Theme.Colors.GreenDark, function()
			ctx.router.show("Party")
		end },
		{ "UPGRADES", Color3.fromRGB(220, 150, 40), Color3.fromRGB(150, 95, 20), function()
			ctx.router.show("Upgrades")
		end },
		{ "SETTINGS", Theme.Colors.PanelLight, Theme.Colors.Night, function()
			ctx.router.show("Settings")
		end },
	}
	for i, b in buttons do
		local btn = Theme.button(column, { text = b[1], color = b[2], darkColor = b[3], size = UDim2.new(1, 0, 0, 70), textSize = 30 }, b[4])
		;(btn.Parent :: Frame).LayoutOrder = i
	end

	local footer = Theme.label(group, GameInfo.Version, Theme.Fonts.Body, 14, Theme.Colors.Muted)
	footer.AnchorPoint = Vector2.new(1, 1)
	footer.Position = UDim2.new(1, -10, 1, -6)
	footer.Size = UDim2.new(0, 200, 0, 20)
	footer.TextXAlignment = Enum.TextXAlignment.Right

	return screen
end
