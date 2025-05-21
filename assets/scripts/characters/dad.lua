texture = "characters/daddyDearest"
position = Vector2(0, 0)
cameraPosition = Vector2(0, 0)

animations = {
    {
        name = "idle",
        prefix = "idle",
        offset = Vector2(0, 0),
        indices = {},
        loop = false,
        fps = 24
    },
    {
        name = "singLEFT",
        prefix = "singLEFT",
        offset = Vector2(10, -10),
        indices = {},
        loop = false,
        fps = 24
    },
    {
        name = "singDOWN",
        prefix = "singDOWN",
        offset = Vector2(0, 30),
        indices = {},
        loop = false,
        fps = 24
    },
    {
        name = "singUP",
        prefix = "singUP",
        offset = Vector2(6, -50),
        indices = {},
        loop = false,
        fps = 24
    },
    {
        name = "singRIGHT",
        prefix = "singRIGHT",
        offset = Vector2(0, -27),
        indices = {},
        loop = false,
        fps = 24
    }
}

scale = 1
antialiasing = true
flipHorizon = false

icon = "dad"
healthColor = Color(49, 176, 209)

vocalPrefix = "bf"