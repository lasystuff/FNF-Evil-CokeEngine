extends FNFScene2D

var menuItems:Dictionary = {
	"storymode": func(): Main.switch_scene(load("res://scenes/PlayScene.tscn")),
	"freeplay": func(): Main.switch_scene(load("res://scenes/menu/Freeplay.tscn")),
	"credits": null,
	"options":  func(): Main.switch_scene(load("res://scenes/menu/OptionMenu.tscn"))
}

var current_item:int = 0:
	set(value):
		GlobalSound.play_sound("menu/scroll")
		current_item = wrap(value, 0, menuItems.size())
var controllable:bool = true

static var current_item_save:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# GlobalSound.play_music("freakyMenu")
	var index:int = 0
	for item in menuItems.keys():
		var sprite = AnimatedSprite2D.new()
		sprite.global_position = Vector2(0, 150*index)
		sprite.sprite_frames = load("res://assets/images/menu/mainmenu/" + item + ".xml")
		sprite.play(item + " idle")
		$items.add_child(sprite)
		index += 1
	current_item = current_item_save

	$Camera2D.limit_top = $items.get_children()[0].global_position.y - 150
	$Camera2D.limit_bottom = $items.get_children()[menuItems.size() - 1].global_position.y + 150


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_item_save = current_item
	if Input.is_action_just_pressed("ui_up") && controllable:
		current_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		current_item += 1
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		GlobalSound.music_player.volume_db = 0.0
		controllable = false
		if menuItems[menuItems.keys()[current_item]] != null:
			menuItems[menuItems.keys()[current_item]].call()
		

	$Camera2D.global_position = $items.get_children()[current_item].global_position
	
	for i in menuItems.size():
		if i == current_item:
			$items.get_children()[i].play(menuItems.keys()[i] + " selected")
		else:
			$items.get_children()[i].play(menuItems.keys()[i] + " idle")
