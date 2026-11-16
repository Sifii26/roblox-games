--!strict
-- Mission definitions. Only Free Roam is playable in Phase 1.
export type Mission = {
	Id: string,
	Name: string,
	Difficulty: string,
	Reward: number?,
	Description: string,
	Playable: boolean,
	Accent: Color3,
}

local Missions: { Mission } = {
	{
		Id = "FirstHouse",
		Name = "The First House",
		Difficulty = "Easy",
		Reward = 500,
		Description = "A sleepy cottage on Holly Lane. Slip down the chimney, grab the gifts under the tree, and get out before anyone wakes up.",
		Playable = false,
		Accent = Color3.fromRGB(96, 200, 120),
	},
	{
		Id = "SilentNight",
		Name = "Silent Night",
		Difficulty = "Medium",
		Reward = 1500,
		Description = "Three houses, one night. The neighbors are light sleepers and the street is full of twinkling lights.",
		Playable = false,
		Accent = Color3.fromRGB(240, 180, 70),
	},
	{
		Id = "MansionHeist",
		Name = "The Mansion Heist",
		Difficulty = "Hard",
		Reward = 5000,
		Description = "Cameras, lasers, and a guard at the gate. The biggest pile of presents in town is waiting behind the mansion walls.",
		Playable = false,
		Accent = Color3.fromRGB(230, 80, 80),
	},
	{
		Id = "FreeRoam",
		Name = "Free Roam",
		Difficulty = "Explore",
		Reward = nil,
		Description = "Explore the town, the starter neighborhood, and your mountain hideout with no pressure.",
		Playable = true,
		Accent = Color3.fromRGB(110, 170, 255),
	},
}

return Missions
