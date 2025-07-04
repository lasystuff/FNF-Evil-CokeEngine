extends FNFScene2D

var current_item:int:
	set(value):
		GlobalSound.play_sound("menu/scroll")
		current_item = wrap(value, 0, $items.get_children().size())
		
@onready var itemsY = $items.global_position.y
var controllable = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && controllable:
		current_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		current_item += 1
		
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		$items.get_children()[current_item].bind()

	if Input.is_action_just_pressed("ui_exit") && controllable:
		CokeUtil.set_mouse_visibility(true)
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		self.queue_free()
		Main.scene.process_mode = Node.PROCESS_MODE_INHERIT

	for i in $items.get_children().size():
		if i == current_item:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5
