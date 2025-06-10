extends Node2D

var itemList = [
	"Resume",
	"Restart Song",
	"Options",
	"Exit Song"
]

const itemListDebug = [
	"Resume",
	"Restart Song",
	"Options",
	"Toggle Botplay",
	"Back Charter"
]

var debug:bool = true
var curItem:int = 0
var itemsY = 0
var controllable:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if debug:
		itemList = itemListDebug
	GlobalSound.playMusic("breakfast")
	GlobalSound.musicPlayer.volume_db = -80
	
	GlobalSound.playSound("menu/scroll")
	for i in itemList.size():
		var lab = SparrowLabel.new()
		lab.font_size = 1.08
		lab.frames = preload("res://assets/images/ui/fonts/bold.xml")
		lab.text = itemList[i].to_upper()
		$items.add_child(lab)
		lab.position.y = 130*i
	itemsY = $items.global_position.y
	
	$song.text = PlayScene.song.display_name
	$meta.text = "Composed by: " + PlayScene.song.artist + "\nCharted by: " + PlayScene.song.charter
	$extra.text = "\n"+PlayScene.song.extra_description

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") && controllable:
		GlobalSound.playSound("menu/scroll")
		curItem -= 1
	elif Input.is_action_just_pressed("ui_down") && controllable:
		GlobalSound.playSound("menu/scroll")
		curItem += 1
	elif Input.is_action_just_pressed("ui_accept"):
		GlobalSound.stopMusic()
		GlobalSound.musicPlayer.volume_db = 0.0
		controllable = false
		selectItem(itemList[curItem])
	if Input.is_action_just_pressed("ui_text_clear_carets_and_selection"):
		resume()
		
	curItem = wrap(curItem, 0, itemList.size())

	for i in itemList.size():
		if i == curItem:
			$items.get_children()[i].modulate.a = 1
		else:
			$items.get_children()[i].modulate.a = 0.5
	$items.global_position.y = lerpf($items.global_position.y, itemsY - $items.get_children()[curItem].position.y, 0.02)
	# im too lazy to doing shits sorry
	GlobalSound.musicPlayer.volume_db = lerpf(GlobalSound.musicPlayer.volume_db, 0.0, 0.004)

func selectItem(item):
	match item:
		"Resume":
			resume()
		"Restart Song":
			Main.switchScene(load("res://scenes/PlayScene.tscn"))
		"Options":
			OptionMenu.backToGame = true
			Main.switchScene(load("res://scenes/menu/OptionMenu.tscn"))
		"Exit Song":
			Main.switchScene(load("res://scenes/menu/OptionMenu.tscn"))

		"Toggle Botplay":
			PlayScene.instance.get_node("playHud/playerStrums").botplay = !PlayScene.instance.get_node("playHud/playerStrums").botplay
			resume()
		"Back Charter":
			Main.switchScene(load("res://scenes/menu/debug/ChartEditor.tscn"))

func resume():
	PlayScene.instance.process_mode = Node.PROCESS_MODE_INHERIT
	self.queue_free()
