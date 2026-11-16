--!strict
-- Music state machine with crossfades.
-- States: Menu, Outside, Inside, Detected, Victory (see Shared/Config/Audio).
-- Phase 1 uses Menu and Outside; Inside switches automatically when the
-- player stands in an InteriorZone. Detected/Victory are ready for later phases.
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local AudioConfig = require(Shared.Config.Audio)
local Settings = require(script.Parent.Parent.Settings)

local MusicController = {}

local group = Instance.new("SoundGroup")
group.Name = "Music"
group.Parent = SoundService

local sounds: { [string]: Sound } = {}
local current: string? = nil
local fadeInfo = TweenInfo.new(AudioConfig.CrossfadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

for state, track in AudioConfig.Tracks do
	if track.SoundId ~= "" then
		local s = Instance.new("Sound")
		s.Name = state
		s.SoundId = track.SoundId
		s.Looped = track.Looped
		s.Volume = 0
		s.SoundGroup = group
		s:SetAttribute("TargetVolume", track.Volume)
		s.Parent = group
		sounds[state] = s
	end
end

local function applyGroupVolume()
	local enabled = Settings.get("MusicEnabled")
	local vol = if enabled then Settings.get("MusicVolume") else 0
	TweenService:Create(group, TweenInfo.new(0.3), { Volume = vol }):Play()
end

-- Switch to a music state; same state is a no-op. Missing tracks fade to silence.
function MusicController.setState(state: string)
	if state == current then
		return
	end
	local old = if current then sounds[current] else nil
	current = state
	if old then
		local t = TweenService:Create(old, fadeInfo, { Volume = 0 })
		t:Play()
		t.Completed:Once(function()
			if current ~= old.Name then
				old:Stop()
			end
		end)
	end
	local new = sounds[state]
	if new then
		if not new.IsPlaying then
			new.TimePosition = 0
			new:Play()
		end
		TweenService:Create(new, fadeInfo, { Volume = new:GetAttribute("TargetVolume") :: number }):Play()
	end
end

function MusicController.getState(): string?
	return current
end

-- Plays a one-shot stinger (e.g. Victory) then returns to the previous state.
function MusicController.playStinger(state: string, returnTo: string)
	local s = sounds[state]
	if not s then
		return
	end
	MusicController.setState(state)
	s.Ended:Once(function()
		if current == state then
			MusicController.setState(returnTo)
		end
	end)
end

function MusicController.hasTrack(state: string): boolean
	return sounds[state] ~= nil
end

Settings.Changed:Connect(function(key)
	if key == "MusicEnabled" or key == "MusicVolume" then
		applyGroupVolume()
	end
end)
applyGroupVolume()

return MusicController
