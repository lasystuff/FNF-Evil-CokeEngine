extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# fix of fucking macOS DPI
	if OS.get_name() == "macOS":
		get_window().size = Vector2i(Constant.width*2, Constant.height*2)
	get_window().move_to_center()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
