extends FNFScene2D
class_name OptionMenu

static var backToGame:bool = false
var controllable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CokeUtil.set_mouse_visibility(true)
	GlobalSound.play_music("optionMenu")
	$tab.current_tab = 0
	
	for tab in [$tab/Gameplay, $tab/Appearance, $tab/Misc]:
		for child in tab.get_children():
			match child.get_class():
				"CheckBox":
					child.button_pressed = SaveData.data[child.name]
					child.toggled.connect(func(t):
						if t:
							GlobalSound.play_sound("menu/options/enable")
						else:
							GlobalSound.play_sound("menu/options/disable")
						setValue(child.name, t)
					)
				"Label":
					var optionChild = child.get_node_or_null(child.name + "Option")
					if optionChild != null:
						match optionChild.get_class():
							"OptionButton":
								optionChild.selected = SaveData.data[child.name]
								optionChild.item_selected.connect(func(index):
									GlobalSound.play_sound("menu/options/enable")
									setValue(child.name, index)
								)
								optionChild.button_down.connect(func(): GlobalSound.play_sound("menu/options/open"))

func setValue(key:String, value):
	if SaveData.data.has(key):
		SaveData.data[key] = value

func _process(delta: float) -> void:
	$render.play("idle")
	$render.position.y = lerpf($render.position.y, 448, 0.02)

	$checker/Sprite2D.global_position.x += 0.05
	$checker/Sprite2D.global_position.y += 0.05
	if $checker/Sprite2D.global_position.x >= 3200:
		$checker/Sprite2D.global_position = Vector2(0, -1400)
		
	if Input.is_action_just_pressed("ui_exit") && controllable:
		CokeUtil.set_mouse_visibility(false)
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		GlobalSound.music_player.stop()
		if backToGame:
			backToGame = false
			Main.switch_scene(load("res://scenes/PlayScene.tscn"))
		else:
			Main.switch_scene(load("res://scenes/menu/MainMenu.tscn"))


func _on_tab_tab_changed(tab: int) -> void:
	$render.global_position.y = 460
	GlobalSound.play_sound("menu/options/open")
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	match tab:
		0:
			$render.scale = Vector2(0.9, 0.9)
			$render.offset = Vector2.ZERO
			
			$render.sprite_frames = preload("res://assets/images/menu/options/renders/bf.xml")
			tween.tween_property($bg, "modulate", Color8(92, 85, 255), 0.5)
		1:
			$render.scale = Vector2(0.75, 0.75)
			$render.offset = Vector2(50, -50)
			
			$render.sprite_frames = preload("res://assets/images/menu/options/renders/gf.xml")
			tween.tween_property($bg, "modulate", Color8(255, 85, 126), 0.5)
		2:
			$render.scale = Vector2(0.8, 0.8)
			$render.offset = Vector2.ZERO
			
			$render.sprite_frames = preload("res://assets/images/menu/options/renders/pico.xml")
			tween.tween_property($bg, "modulate", Color8(0, 182, 126), 0.5)

func _on_edit_controls_pressed() -> void:
	CokeUtil.set_mouse_visibility(false)
	Main.instance.get_node("SubSceneLoader").add_child(load("res://scenes/menu/ControlOption.tscn").instantiate())
	self.process_mode = Node.PROCESS_MODE_DISABLED
