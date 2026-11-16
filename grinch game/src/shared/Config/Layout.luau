--!strict
-- World layout constants shared by the world builder and future systems
-- (sleigh, NPCs, missions). All units are studs.
return {
	RoadWidth = 30, -- wide enough for a dog-pulled sleigh to turn
	SidewalkWidth = 8,
	GroundY = 0,

	TownCenter = Vector3.new(0, 0, 0),
	PlazaHalf = 70, -- plaza is 140x140, ring road around it
	RingRoad = 95, -- ring road centerline offset from plaza center

	Neighborhood = { StartX = -110, EndX = -520, Z = 0, CulDeSacRadius = 46 },
	GatedEntranceX = 330, -- gate along the east road
	MansionGateZ = -360, -- gate along the north road
	Hideout = Vector3.new(0, 130, 700),
	MenuCamera = {
		Position = Vector3.new(-160, 120, 260),
		LookAt = Vector3.new(-120, 15, -20),
	},
	FreeRoamSpawn = Vector3.new(0, 4, 72),
}
