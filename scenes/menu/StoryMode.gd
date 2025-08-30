extends FNFScene2D

var level_list:Array = []

static var save_current_level:int = 0
static var save_current_difficulty:int = 1

var current_level:int = 0:
	set(value):
		current_level = wrap(value, 0, level_list.size())
		
		if $props/opponent.sprite_frames != level_list[current_level].opponent_prop:
			$props/opponent.sprite_frames = level_list[current_level].opponent_prop
		if $props/player.sprite_frames != level_list[current_level].player_prop:
			$props/player.sprite_frames = level_list[current_level].player_prop
		if $props/dj.sprite_frames != level_list[current_level].dj_prop:
			$props/dj.sprite_frames = level_list[current_level].dj_prop

		var prevDifficulties = difficulties
		if prevDifficulties == difficulties:
			return
		difficulties = level_list[current_level].difficulties
		if difficulties.has(prevDifficulties[current_difficulty]):
			current_difficulty = difficulties.find(prevDifficulties[current_difficulty])
		else:
			current_difficulty = 1 # normal

var difficulties:Array = ["easy", "normal", "hard"]
var current_difficulty:int = 0:
	set(value):
		current_difficulty = wrap(value, 0, difficulties.size())
		$difficultySprite.global_position.y = og_difficultyY + 10
		$difficultySprite.texture = load("res://assets/images/menu/storymode/difficulties/" + level_list[current_level].difficulties[current_difficulty] + ".png")

var controllable:bool = true

@onready var og_itemY:float = $items.global_position.y
@onready var og_difficultyY:float = $difficultySprite.global_position.y
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DiscordData.set_rpc("In Story Mode Menu")
	if !GlobalSound.music_player.playing:
		GlobalSound.play_music("freakyMenu")
	# this literally fucking sucks what?????
	if Paths.exists("levels/_list.txt"):
		var rawlist = FileAccess.get_file_as_string(Paths.getPath("levels/_list.txt"))
		for level in rawlist.split("\n", false):
			if level.begins_with("#"):
				continue
			if Paths.exists("levels/" + level + ".tres"):
				var data = load(Paths.getPath("levels/" + level + ".tres"))
				if data.songs.size() > 0:
					data.setup(level)
					level_list.push_back(data)

	for file in Paths.list("levels"):
		var level = file.split(".tres")[0]
		if file.begins_with("_") || level_list.has(level):
			continue
		var data = load(Paths.getPath("levels/" + file))
		if data.songs.size() > 0:
			data.setup(level)
			level_list.push_back(data)

	for i in level_list.size():
		var spr = Sprite2D.new()
		spr.position.y = (level_list[i].texture.get_height()*0.8)*i
		spr.texture = level_list[i].texture
		$items.add_child(spr)
	
	current_level = save_current_level
	current_difficulty = save_current_difficulty

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	save_current_level = current_level
	save_current_difficulty = current_difficulty

	if Input.is_action_just_pressed("ui_up") && controllable:
		GlobalSound.play_sound("menu/scroll")
		current_level -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		GlobalSound.play_sound("menu/scroll")
		current_level += 1
		
	if Input.is_action_just_pressed("ui_left") && controllable:
		GlobalSound.play_sound("menu/scroll")
		current_difficulty -= 1
		$leftArrow.stop()
		$leftArrow.play("leftConfirm")
	elif Input.is_action_just_pressed("ui_right") && controllable:
		GlobalSound.play_sound("menu/scroll")
		current_difficulty += 1
		$rightArrow.stop()
		$rightArrow.play("rightConfirm")
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		controllable = false
		
		for prop in $props.get_children():
			if !prop.sprite_frames.has_animation("confirm"):
				continue
			prop.stop()
			prop.play("confirm")

		CokeUtil.flicker($items.get_child(current_level), 1, 0.1, false, false, func():
				PlayScene.playlist = level_list[current_level].songs.duplicate(true)
				PlayScene.difficulty = difficulties[current_difficulty]
				PlayScene.play_mode = PlayScene.PlayMode.STORY
				PlayScene.level = level_list[current_level].level_name

				Main.switch_scene(load("res://scenes/PlayScene.tscn")))

	if Input.is_action_just_pressed("ui_exit") && controllable:
		GlobalSound.play_sound("menu/cancel")
		controllable = false
		Main.switch_scene(preload("res://scenes/menu/MainMenu.tscn"))

	$difficultySprite.global_position.y = lerpf($difficultySprite.global_position.y, og_difficultyY, 0.05)
		
	$items.global_position.y = lerpf($items.global_position.y, og_itemY - $items.get_children()[current_level].position.y, 0.02)
	for i in level_list.size():
		if i == current_level:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5
	
	$titleLabel.text = level_list[current_level].title.to_upper()
	if SaveData.data._score.has("story_" + level_list[current_level].level_name):
		$scoreLabel.text = "LEVEL SCORE:" + SaveData.data._score["story_" + level_list[current_level].level_name]
	else:
		$scoreLabel.text = "LEVEL SCORE: 0"
		
	$songsLabel.text = "TRACKS\n\n"
	for song in level_list[current_level].display_songs:
		$songsLabel.text += song
	
	if !$leftArrow.is_playing():
		$leftArrow.play("leftIdle")
	if !$rightArrow.is_playing():
		$rightArrow.play("rightIdle")
		
	for prop in $props.get_children():
		if !prop.is_playing() && controllable:
			prop.play("idle")
