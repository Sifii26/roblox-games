--!strict
-- Party menu foundation. Everything that works today works for real
-- (navigation, friend invite prompt). Party creation, ready sync and privacy
-- are local previews only until the multiplayer phase, and say so on screen.
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local Theme = require(script.Parent.Parent.Theme)

local MAX_SLOTS = 4

return function(ctx: any)
	local screen = Theme.screen(ctx.root, "Party")
	local group = screen:FindFirstChild("Group") :: CanvasGroup
	local player = Players.LocalPlayer

	Theme.header(group, "PARTY", function()
		ctx.router.show("MainMenu")
	end)

	local notice = Theme.label(group, "Preview: parties and matchmaking arrive in the multiplayer update. Invites already work, and Free Roam is shared with everyone on this server.", Theme.Fonts.Body, 16, Theme.Colors.Muted)
	notice.Position = UDim2.new(0, 100, 0, 74)
	notice.Size = UDim2.new(1, -200, 0, 40)

	-- Player slots.
	local slots = Instance.new("Frame")
	slots.Name = "Slots"
	slots.BackgroundTransparency = 1
	slots.AnchorPoint = Vector2.new(0.5, 0)
	slots.Position = UDim2.new(0.5, 0, 0, 130)
	slots.Size = UDim2.new(0, 1000, 0, 280)
	slots.Parent = group
	local sl = Instance.new("UIListLayout")
	sl.FillDirection = Enum.FillDirection.Horizontal
	sl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sl.Padding = UDim.new(0, 20)
	sl.Parent = slots

	local readyLabel: TextLabel? = nil
	for i = 1, MAX_SLOTS do
		local slot = Theme.panel(slots, "Slot" .. i)
		slot.Size = UDim2.new(0, 230, 1, 0)
		slot.LayoutOrder = i
		if i == 1 then
			local avatar = Instance.new("ImageLabel")
			avatar.BackgroundColor3 = Theme.Colors.PanelLight
			avatar.AnchorPoint = Vector2.new(0.5, 0)
			avatar.Position = UDim2.new(0.5, 0, 0, 30)
			avatar.Size = UDim2.new(0, 130, 0, 130)
			Theme.corner(avatar, 65)
			avatar.Parent = slot
			task.spawn(function()
				local ok, img = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
				end)
				if ok then
					avatar.Image = img
				end
			end)
			local crown = Theme.label(slot, "👑 LEADER", Theme.Fonts.Bold, 16, Theme.Colors.Gold)
			crown.Position = UDim2.new(0, 0, 0, 4)
			crown.Size = UDim2.new(1, 0, 0, 24)
			local name = Theme.label(slot, player.DisplayName, Theme.Fonts.Heading, 24, Theme.Colors.Snow)
			name.Position = UDim2.new(0, 10, 0, 170)
			name.Size = UDim2.new(1, -20, 0, 30)
			name.TextScaled = true
			readyLabel = Theme.label(slot, "NOT READY", Theme.Fonts.Bold, 18, Color3.fromRGB(240, 120, 120))
			;(readyLabel :: TextLabel).Position = UDim2.new(0, 0, 0, 215)
		else
			local empty = Theme.label(slot, "+", Theme.Fonts.Title, 80, Theme.Colors.Muted)
			empty.Position = UDim2.new(0, 0, 0, 60)
			empty.Size = UDim2.new(1, 0, 0, 90)
			empty.TextTransparency = 0.4
			local t = Theme.label(slot, "Empty slot", Theme.Fonts.Body, 18, Theme.Colors.Muted)
			t.Position = UDim2.new(0, 0, 0, 170)
		end
	end

	-- Controls row.
	local controls = Instance.new("Frame")
	controls.BackgroundTransparency = 1
	controls.AnchorPoint = Vector2.new(0.5, 0)
	controls.Position = UDim2.new(0.5, 0, 0, 430)
	controls.Size = UDim2.new(0, 1000, 0, 64)
	controls.Parent = group
	local cl = Instance.new("UIListLayout")
	cl.FillDirection = Enum.FillDirection.Horizontal
	cl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cl.Padding = UDim.new(0, 16)
	cl.Parent = controls

	Theme.button(controls, { text = "INVITE FRIENDS", color = Color3.fromRGB(70, 120, 220), darkColor = Color3.fromRGB(40, 70, 150), size = UDim2.new(0, 240, 1, 0), textSize = 22 }, function()
		local ok, canInvite = pcall(function()
			return SocialService:CanSendGameInviteAsync(player)
		end)
		if ok and canInvite then
			pcall(function()
				SocialService:PromptGameInvite(player)
			end)
		else
			ctx.toast("Invites aren't available right now (they don't work in Studio test mode).")
		end
	end)

	local ready = false
	local readyBtn: TextButton
	readyBtn = Theme.button(controls, { text = "READY", color = Theme.Colors.Green, darkColor = Theme.Colors.GreenDark, size = UDim2.new(0, 180, 1, 0), textSize = 22 }, function()
		ready = not ready
		readyBtn.Text = if ready then "UNREADY" else "READY"
		if readyLabel then
			readyLabel.Text = if ready then "READY" else "NOT READY"
			readyLabel.TextColor3 = if ready then Color3.fromRGB(120, 230, 140) else Color3.fromRGB(240, 120, 120)
		end
	end)

	local privacyOptions = { "PUBLIC", "FRIENDS", "PRIVATE" }
	local privacyIndex = 2
	local privacyBtn: TextButton
	privacyBtn = Theme.button(controls, { text = "PRIVACY: FRIENDS", color = Theme.Colors.PanelLight, darkColor = Theme.Colors.Night, size = UDim2.new(0, 260, 1, 0), textSize = 20 }, function()
		privacyIndex = privacyIndex % #privacyOptions + 1
		privacyBtn.Text = "PRIVACY: " .. privacyOptions[privacyIndex]
	end)

	local continueHolder = Instance.new("Frame")
	continueHolder.BackgroundTransparency = 1
	continueHolder.AnchorPoint = Vector2.new(0.5, 0)
	continueHolder.Position = UDim2.new(0.5, 0, 0, 520)
	continueHolder.Size = UDim2.new(0, 420, 0, 72)
	continueHolder.Parent = group
	Theme.button(continueHolder, { text = "CONTINUE TO MISSIONS", color = Theme.Colors.Red, darkColor = Theme.Colors.RedDark, size = UDim2.fromScale(1, 1), textSize = 26 }, function()
		ctx.router.show("MissionSelect", { mode = "Party" })
	end)

	return screen
end
