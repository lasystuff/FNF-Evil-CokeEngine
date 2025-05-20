extends FNFScene2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Conductor.bpm = 102


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	var instTime = $music.get_playback_position() + AudioServer.get_time_since_last_mix()
	Conductor.songPosition = (instTime * 1000.0)

func beatHit():
	super()
	$AnimationPlayer.play("bop")
	$logo.stop()
	$logo.play("logo bumpin")
	
	if curBeat % 2 == 0:
		$gfdance.stop()
		$gfdance.play("gfDance")
