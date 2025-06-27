extends FNFScene2D

@export var song_list:Array = []

@onready var itemsY = $items.global_position.y

var current_item:int = 0:
	set(value):
		GlobalSound.play_sound("menu/scroll")
		current_item = wrap(value, 0, song_list_final.size())
		GlobalSound.play_music_raw(preview_musics[current_item])
var song_list_final:Array = []
var controllable:bool = true

var difficulties:Array = ["hard"]
var current_difficulty:int = 0

var preview_musics:Array = []

static var current_item_save:int = 0

func _ready() -> void:
	for i in song_list.size():
		if Paths.exists("songs/" + song_list[i] + "/data.tres"):
			var lab = SparrowLabel.new()
			lab.font_size = 1.08
			lab.frames = preload("res://assets/images/ui/fonts/bold.xml")
			lab.text = song_list[i].to_upper()
			$items.add_child(lab)
			lab.position.y = 130*i
			
			song_list_final.push_back(song_list[i])
			var data = load(Paths.getPath("songs/" + song_list[i] + "/data.tres"))
			preview_musics.push_back(data.instrumental)

	current_item = current_item_save
			
func _process(delta: float) -> void:
	super(delta)
	
	current_item_save = current_item
	if Input.is_action_just_pressed("ui_up") && controllable:
		current_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		current_item += 1
	
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		GlobalSound.stop_music()
		controllable = false
		
		# ok starting song lol
		PlayScene.playlist = [load(Paths.getPath("songs/" + song_list_final[current_item] + "/data.tres"))]
		PlayScene.difficulty = difficulties[current_difficulty]
		Main.switch_scene(load("res://scenes/PlayScene.tscn"))
	if Input.is_action_just_pressed("ui_text_clear_carets_and_selection") && controllable:
		GlobalSound.play_sound("menu/cancel")
		Main.switch_scene(preload("res://scenes/menu/MainMenu.tscn"))
		
	$items.global_position.y = lerpf($items.global_position.y, itemsY - $items.get_children()[current_item].position.y, 0.02)
	
	for i in song_list_final.size():
		if i == current_item:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5
