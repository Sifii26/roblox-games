--!strict
-- Player settings for this session, with a change signal.
-- (Saving settings between sessions needs a DataStore; planned with the
-- economy/progression phase.)
local Settings = {}

export type Values = {
	MusicEnabled: boolean,
	MusicVolume: number, -- 0..1
	SnowQuality: string, -- "Off" | "Low" | "Medium" | "High"
	AnimatedLights: boolean,
}

local values: Values = {
	MusicEnabled = true,
	MusicVolume = 0.7,
	SnowQuality = "Medium",
	AnimatedLights = true,
}

local changed = Instance.new("BindableEvent")
Settings.Changed = changed.Event -- (key: string, value: any)

Settings.SnowLevels = { "Off", "Low", "Medium", "High" }

function Settings.get(key: string): any
	return (values :: any)[key]
end

function Settings.set(key: string, value: any)
	if (values :: any)[key] == value then
		return
	end
	(values :: any)[key] = value
	changed:Fire(key, value)
end

return Settings
