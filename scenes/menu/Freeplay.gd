extends FNFScene2D

@export var song_list:Array[String] = []

@onready var itemsY = $items.global_position.y

var targetScore:int = 0
var scoreLerp:int = 0

var targetAccuracy:float = 0
var accuracyLerp:float = 0

var current_item:int = 0:
	set(value):
		
		GlobalSound.play_sound("menu/scroll")
		current_item = wrap(value, 0, song_list_final.size())
		GlobalSound.play_music_raw(preview_musics[current_item])

		var data = load(Paths.getPath("songs/" + song_list_final[current_item] + "/data.tres"))
		var beforeDifficulties = difficulties
		difficulties = data.difficulties
		if difficulties.has(beforeDifficulties[current_difficulty]):
			current_difficulty = difficulties.find(beforeDifficulties[current_difficulty])
		else:
			current_difficulty = 1 # normal
var song_list_final:Array = []
var controllable:bool = true

var difficulties:Array = []
var current_difficulty:int = 0:
	set(value):
		GlobalSound.play_sound("menu/scroll")
		current_difficulty = value
		current_difficulty = wrap(current_difficulty, 0, difficulties.size())

var preview_musics:Array = []

static var current_item_save:int = 0

func _ready() -> void:
	DiscordData.set_rpc("In Freeplay Menu")

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

	difficulties = load(Paths.getPath("songs/" + song_list_final[0] + "/data.tres")).difficulties
	current_item = current_item_save
			
func _process(delta: float) -> void:
	current_item_save = current_item
	if Input.is_action_just_pressed("ui_up") && controllable:
		current_item -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		current_item += 1
		
	if Input.is_action_just_pressed("ui_left") && controllable:
		current_difficulty -= 1
	elif Input.is_action_just_pressed("ui_right") && controllable:
		current_difficulty += 1
	
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		GlobalSound.stop_music()
		controllable = false
		
		# ok starting song lol
		PlayScene.playlist = [load(Paths.getPath("songs/" + song_list_final[current_item] + "/data.tres"))]
		PlayScene.difficulty = difficulties[current_difficulty]
		PlayScene.play_mode = PlayScene.PlayMode.FREEPLAY
		Main.switch_scene(load("res://scenes/PlayScene.tscn"))
	if Input.is_action_just_pressed("ui_exit") && controllable:
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		Main.switch_scene(load("res://scenes/menu/MainMenu.tscn"))
		
	$items.global_position.y = lerpf($items.global_position.y, itemsY - $items.get_children()[current_item].position.y, 0.02)
	
	for i in song_list_final.size():
		if i == current_item:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5

	if SaveData.data["_score"].has(song_list_final[current_item] + "-" + difficulties[current_difficulty]):
		var savedScore = SaveData.data._score[song_list_final[current_item] + "-" + difficulties[current_difficulty]]
		targetScore = savedScore.score
		targetAccuracy = savedScore.accuracy
	else:
		targetScore = 0
		targetAccuracy = 0
		
	var lerpSize = 0.01
	scoreLerp = lerp(scoreLerp, targetScore, lerpSize)
	accuracyLerp = lerp(accuracyLerp, targetAccuracy, lerpSize)
	
	$scoreLabel.text = "PERSONAL BEST: " + str(scoreLerp) + " (" + str(snapped(accuracyLerp, 0.01)) + "%)"
	var leftArrow = "< "
	var rightArrow = " >"
	if difficulties.size() < 2:
		leftArrow = "[color=GRAY]< [/color]"
		rightArrow = "[color=GRAY] >[/color]"
	$diffLabel.text = leftArrow + difficulties[current_difficulty].to_upper() + rightArrow
