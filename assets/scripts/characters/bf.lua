texture = "characters/BOYFRIEND"
position = Vector2(0, 0)
cameraPosition = Vector2(0, -50)

animations = {
	{
		name = "idle",
		prefix = "BF idle dance",
		offset = Vector2(0, -5),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singLEFT",
		prefix = "BF NOTE LEFT",
		offset = Vector2(-20, -2),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singDOWN",
		prefix = "BF NOTE DOWN",
		offset = Vector2(0, 20),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singUP",
		prefix = "BF NOTE UP",
		offset = Vector2(25, -20),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singRIGHT",
		prefix = "BF NOTE RIGHT",
		offset = Vector2(45, 0),
		indices = {},
		loop = false,
		fps = 24
	},

	{
		name = "singLEFTmiss",
		prefix = "BF NOTE LEFT MISS",
		offset = Vector2(-20, -15),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singDOWNmiss",
		prefix = "BF NOTE DOWN MISS",
		offset = Vector2(0, 1),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singUPmiss",
		prefix = "BF NOTE UP MISS",
		offset = Vector2(20, -15),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singRIGHTmiss",
		prefix = "BF NOTE RIGHT MISS",
		offset = Vector2(40, -10),
		indices = {},
		loop = false,
		fps = 24
	},

	{
		name = "death",
		prefix = "BF dies",
		offset = Vector2(-12, 7),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "deathLoop",
		prefix = "BF Dead Loop",
		offset = Vector2(-12, 8),
		indices = {},
		loop = true,
		fps = 24
	},
	{
		name = "deathConfirm",
		prefix = "BF Dead confirm",
		offset = Vector2(-12, -24),
		indices = {},
		loop = false,
		fps = 24
	}
}

scale = 1
antialiasing = true
flipHorizon = true

icon = "bf"
healthColor = Color(49, 176, 209)

vocalPrefix = "bf"
