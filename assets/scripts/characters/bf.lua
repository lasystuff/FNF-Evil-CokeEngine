texture = "characters/BOYFRIEND"
position = Vector2(0, 0)
cameraPosition = Vector2(0, 0)

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
		offset = Vector2(-12, 6),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singDOWN",
		prefix = "BF NOTE DOWN",
		offset = Vector2(10, 30),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singUP",
		prefix = "BF NOTE UP",
		offset = Vector2(29, -27),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singRIGHT",
		prefix = "BF NOTE RIGHT",
		offset = Vector2(38, 7),
		indices = {},
		loop = false,
		fps = 24
	},

	{
		name = "singLEFTmiss",
		prefix = "BF NOTE LEFT MISS",
		offset = Vector2(-12, -24),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singDOWNmiss",
		prefix = "BF NOTE DOWN MISS",
		offset = Vector2(11, 19),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singUPmiss",
		prefix = "BF NOTE UP MISS",
		offset = Vector2(29, -27),
		indices = {},
		loop = false,
		fps = 24
	},
	{
		name = "singRIGHTmiss",
		prefix = "BF NOTE RIGHT MISS",
		offset = Vector2(30, -21),
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
