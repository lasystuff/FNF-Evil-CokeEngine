extends FNFScene2D

var menuItems:Dictionary = {
	"storymode": func(): Main.switch_scene(load("res://scenes/menu/StoryMode.tscn")),
	"freeplay": func(): Main.switch_scene(load("res://scenes/menu/Freeplay.tscn")),
	#"credits": null,
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
	DiscordData.set_rpc("In Main Menu")
	if !GlobalSound.music_player.playing:
		GlobalSound.play_music("freakyMenu")
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
	if menuItems.size() > 3:
		$Camera2D.limit_bottom = $items.get_children()[menuItems.size() - 1].global_position.y + 150
	else:
		$Camera2D.limit_bottom = $items.get_children()[menuItems.size() - 1].global_position.y + 300
	
	var versionPostfix = "v" + ProjectSettings.get_setting("application/config/version")
	if versionPostfix == "v": # prerelease
		versionPostfix = ""
	$overlay/RichTextLabel.text = '[color="red"]EVIL[/color] Coke Engine Indev ' + versionPostfix
	$overlay/RichTextLabel.text += "\nFriday Night Funkin' Rewritten"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_item_save = current_item
	if Input.is_action_just_pressed("ui_up") && controllable:
		current_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		current_item += 1
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		controllable = false
		if menuItems[menuItems.keys()[current_item]] != null:
			CokeUtil.flicker($items.get_child(current_item), 1, 0.1, false, false, menuItems[menuItems.keys()[current_item]])
			
			var charTween = get_tree().create_tween().set_parallel()
			charTween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			for i in menuItems.size():
				if i != current_item:
					charTween.tween_property($items.get_child(i), "self_modulate", Color.TRANSPARENT, 0.5)
	if Input.is_action_just_pressed("ui_exit") && controllable:
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		Main.nextTransOut = "quickOut"
		Main.switch_scene(load("res://scenes/menu/TitleScreen.tscn"))
		
	$Camera2D.global_position = $items.get_children()[current_item].global_position
	
	for i in menuItems.size():
		if i == current_item:
			$items.get_child(i).play(menuItems.keys()[i] + " selected")
		else:
			$items.get_child(i).play(menuItems.keys()[i] + " idle")
