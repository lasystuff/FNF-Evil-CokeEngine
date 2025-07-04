extends FNFScene2D

var controllable:bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !GlobalSound.music_player.playing:
		GlobalSound.play_music("freakyMenu")
	Conductor.bpm = 102
	$flash.modulate.a = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	var instTime = GlobalSound.music_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	Conductor.songPosition = (instTime * 1000.0)
	
	if controllable:
		$titleenter.play("Press Enter to Begin")
	$flash.modulate.a = lerpf($flash.modulate.a, 0, 0.005)
	
	if Input.is_action_just_pressed("ui_accept") && controllable:
		GlobalSound.play_sound("menu/confirm")
		controllable = false
		$titleenter.stop()
		$titleenter.play("ENTER PRESSED")
		$transTimer.start()

func beatHit():
	super()
	$logo.stop()
	$logo.play("logo bumpin")
	
	if curBeat % 2 == 0:
		$gfdance.stop()
		$gfdance.play("gfDance")

func _on_trans_timer_timeout() -> void:
	Main.switch_scene(load("res://scenes/menu/MainMenu.tscn"))
