--!strict
-- Client entry point.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Hide default Roblox UI that clutters the menu (chat stays available).
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

if not ReplicatedStorage:GetAttribute("WorldReady") then
	ReplicatedStorage:GetAttributeChangedSignal("WorldReady"):Wait()
end

require(script.Parent.Effects.Snowfall).start()
require(script.Parent.Effects.LightAnimator).start()
require(script.Parent.UI.MenuController).start()
