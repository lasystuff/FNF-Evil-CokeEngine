extends Node2D

@export var bind_name:String = ""
@export var target_bind:String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$boundName.text = "・" + bind_name + ":"

	if SaveData.data._inputs.has(target_bind):
		$keyName.text = OS.get_keycode_string(SaveData.data._inputs[target_bind])
	else:
		var event = InputMap.action_get_events(target_bind)[0]
		print(event.keycode)
		$keyName.text = OS.get_keycode_string(event.keycode)

var waiting_for_bind:bool = false
func bind():
	$keyName.text = "WAITING FOR INPUT"
	waiting_for_bind = true
	
func _input(event: InputEvent) -> void:
	if !waiting_for_bind:
		return
	if event is InputEventKey:
		if event.is_pressed() && !event.echo:
			SaveData.set_key_bind(target_bind, event.keycode)
			waiting_for_bind = false
			SaveData.data._inputs[target_bind] = event.keycode
			$keyName.text = OS.get_keycode_string(event.key_label)
			Main.instance.get_node("SubSceneLoader").get_children()[0].controllable = true
