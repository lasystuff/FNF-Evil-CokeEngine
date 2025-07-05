extends FNFScene2D

var controllable:bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !GlobalSound.music_player.playing:
		GlobalSound.play_music("freakyMenu")
	conductor.bpm = 102
	$flash.modulate.a = 1
	conductor.song_position = 0
	beat_hit(0) # fucking animation shit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	conductor.song_position += (delta * 1000.0)

	if controllable:
		$titleenter.play("Press Enter to Begin")
	$flash.modulate.a = lerpf($flash.modulate.a, 0, 0.005)
	
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		controllable = false
		$titleenter.stop()
		$titleenter.play("ENTER PRESSED")
		$transTimer.start()

func beat_hit(beat):
	$logo.stop()
	$logo.play("logo bumpin")
	
	if beat % 2 == 0:
		$gfdance.stop()
		$gfdance.play("gfDance")

func _on_trans_timer_timeout() -> void:
	Main.switch_scene(load("res://scenes/menu/MainMenu.tscn"))
