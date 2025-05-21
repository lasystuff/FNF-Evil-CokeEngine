--This is idea of character script. based off FPS Plus's approach! i'll not use tres cuz godot's resource manager sucks (in my opinion) also using Lua instead of GDScript cuz i dont know so much at Godot Class System

texture = "characters/BOYFRIEND"
position = Vector2(0, 0)
cameraPosition = Vector2(0, 0)

animations = {
    {
        name: "idle"
        prefix: "BF idle dance",
        offset: Vector2(0, -5),
        indices: [],
        loop: false,
        fps: 24
    }
}

scale = 1
antialiasing = true
flipX = true

icon = "bf"
healthColor = Color(49, 176, 209)

vocalPrefix = "bf"