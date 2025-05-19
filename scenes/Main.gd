extends Node2D

@onready var stageScript = LuaModule.new("stage")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# fix of fucking macOS DPI
	if OS.get_name() == "macOS":
		get_window().size = Vector2i(1280*2, 720*2)
	get_window().move_to_center()
	
	stageScript.callLua("onCreate")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	stageScript.callLua("onUpdate", [delta])
