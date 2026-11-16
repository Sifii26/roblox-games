--!strict
-- Upgrade shop preview. Prices come from Shared/Config/Economy; buying
-- arrives with the economy phase, so cards show a locked state.
local Theme = require(script.Parent.Parent.Theme)
local Economy = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Config.Economy)

return function(ctx: any)
	local screen = Theme.screen(ctx.root, "Upgrades")
	local group = screen:FindFirstChild("Group") :: CanvasGroup
	Theme.header(group, "UPGRADES", function()
		ctx.router.show("MainMenu")
	end)

	local cash = Theme.label(group, "Your cash: $" .. tostring(Economy.StartingCash), Theme.Fonts.Heading, 24, Theme.Colors.Gold)
	cash.Position = UDim2.new(0, 0, 0, 76)
	cash.Size = UDim2.new(1, 0, 0, 30)

	local note = Theme.label(group, "Earn cash from missions to unlock upgrades. The shop opens with the first heist missions.", Theme.Fonts.Body, 16, Theme.Colors.Muted)
	note.Position = UDim2.new(0, 0, 0, 108)
	note.Size = UDim2.new(1, 0, 0, 22)

	local grid = Instance.new("Frame")
	grid.BackgroundTransparency = 1
	grid.AnchorPoint = Vector2.new(0.5, 0)
	grid.Position = UDim2.new(0.5, 0, 0, 150)
	grid.Size = UDim2.new(0, 900, 0, 480)
	grid.Parent = group
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, 430, 0, 200)
	layout.CellPadding = UDim2.new(0, 20, 0, 20)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid

	for i, up in Economy.Upgrades do
		local card = Theme.panel(grid, up.Id)
		card.LayoutOrder = i
		Theme.padding(card, 16)
		local name = Theme.label(card, up.Name, Theme.Fonts.Heading, 26, Theme.Colors.Snow)
		name.TextXAlignment = Enum.TextXAlignment.Left
		local desc = Theme.label(card, up.Description, Theme.Fonts.Body, 16, Theme.Colors.Muted)
		desc.Position = UDim2.new(0, 0, 0, 40)
		desc.Size = UDim2.new(1, 0, 0, 44)
		desc.TextXAlignment = Enum.TextXAlignment.Left
		local price = Theme.label(card, "$" .. string.format("%d", up.Cost):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""), Theme.Fonts.Heading, 28, Theme.Colors.Gold)
		price.AnchorPoint = Vector2.new(0, 1)
		price.Position = UDim2.new(0, 0, 1, -4)
		price.Size = UDim2.new(0.5, 0, 0, 36)
		price.TextXAlignment = Enum.TextXAlignment.Left
		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Position = UDim2.new(1, 0, 1, 0)
		holder.Size = UDim2.new(0, 160, 0, 52)
		holder.Parent = card
		Theme.button(holder, { text = "LOCKED", size = UDim2.fromScale(1, 1), enabled = false, textSize = 20 })
	end
	return screen
end
