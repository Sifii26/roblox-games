--!strict
-- Music tracks per game state.
-- Put the asset id of a track you are allowed to use (for example a Roblox-licensed
-- track from the Creator Store "Audio" tab) in each SoundId. Leave it as "" to keep
-- that state silent. The music system skips empty ids instead of erroring.
export type Track = { SoundId: string, Volume: number, Looped: boolean }

local Tracks: { [string]: Track } = {
	Menu = { SoundId = "", Volume = 0.6, Looped = true }, -- cheerful instrumental
	Outside = { SoundId = "", Volume = 0.5, Looped = true }, -- cheerful instrumental
	Inside = { SoundId = "", Volume = 0.5, Looped = true }, -- sneaky / suspense (future)
	Detected = { SoundId = "", Volume = 0.7, Looped = true }, -- chase (future)
	Victory = { SoundId = "", Volume = 0.7, Looped = false }, -- short stinger (future)
}

return {
	Tracks = Tracks,
	CrossfadeTime = 1.5,
}
