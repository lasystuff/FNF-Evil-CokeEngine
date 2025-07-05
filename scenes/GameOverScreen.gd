extends Node2D
class_name GameOverScreen

static var character:String = "bf"

var loop_music:AudioStream = preload("res://assets/music/gameOver.ogg")
var char:FNFCharacter2D = FNFCharacter2D.new(character)
var controllable:bool = true

func _ready() -> void:
	add_child(char)
	char.flip_h = !char.flip_h
	GlobalSound.play_sound("fnf_loss_sfx")
	char.playAnim("death")
	
	# buddy....... what the fuck??????
	var charTween = get_tree().create_tween().set_parallel()
	charTween.set_trans(PlayScene.defaultCameraTrans).set_ease(PlayScene.defaultCameraEase)
	charTween.tween_property(char, "global_position", Vector2(-200, 200), 5)
	var thing = 1 + (1 - PlayScene.instance.camZoom)
	charTween.tween_property(char, "scale", Vector2(thing, thing), 5)

	$funnyTimer.start()
	
func _on_funny_timer_timeout() -> void:
	GlobalSound.play_music_raw(loop_music)
	char.playAnim("deathLoop", true)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") && controllable:
		$funnyTimer.stop()
		char.playAnim("deathConfirm", true)
		GlobalSound.play_music("gameOverEnd")
		$retryTimer.start()
		controllable = false
	if Input.is_action_just_pressed("ui_exit") && controllable:
		pass


func _on_retry_timer_timeout() -> void:
	Main.switch_scene(load("res://scenes/PlayScene.tscn"))
