texture = "characters/GF_assets"
position = Vector2(0, 0)
cameraPosition = Vector2(100, -100)

animations = {
    {
        name = "danceLeft",
        prefix = "GF Dancing Beat",
        offset = Vector2(0, 0),
        indices = {30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
        loop = false,
        fps = 24
    },
    {
        name = "danceRight",
        prefix = "GF Dancing Beat",
        offset = Vector2(0, 0),
        indices = {15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29},
        loop = false,
        fps = 24
    }
}
idleAnimations = {"danceLeft", "danceRight"}

scale = 1
antialiasing = true
flipHorizon = false

icon = "gf"
healthColor = Color(49, 176, 209)

vocalPrefix = "gf"