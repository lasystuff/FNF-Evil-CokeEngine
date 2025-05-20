extends FNFScene2D
class_name PlayScene

static var playlist:Array = []
static var song:
	get():
		if playlist.size() > 0:
			return playlist[0]
		else:
			return null

var stage = null

var camFollow = Vector2(0, 0)
var camZoom:float = 0.7
var camZoomAdd:float = 0

var onCountdown:bool = false
var songStarted:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if song == null:
		playlist.push_back(SongData.getSong("2hot", "hard"))
		
	var audio = SongData.getAudio(song)
	
	$inst.stream = load(audio.instrumental)
	if audio.player != null:
		$playerVoices.stream = load(audio.player)
	if audio.opponent != null:
		$opponentVoices.stream = load(audio.opponent)
		
	Conductor.bpm = song.bpm
	Conductor.mapBPMChanges(song)

	# init stages
	var targetStage = song.stage
	if !ResourceLoader.exists("res://scenes/stages/" + targetStage + ".tscn"):
		targetStage = "Stage"

	stage = load("res://scenes/stages/" + targetStage + ".tscn").instantiate()
	add_child(stage)
	
	startCountdown()

var curCountdown:int = 0
func startCountdown():
	onCountdown = true
	Conductor.songPosition = 0
	Conductor.songPosition -= Conductor.crotchet * 5
	
	var countdownTimer = Timer.new()
	
	add_child(countdownTimer)
	countdownTimer.timeout.connect(func():
		var countSprite = Sprite2D.new()
		countSprite.position = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)
		countSprite.scale = Vector2(0.52, 0.52)
		var sprTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		sprTween.tween_property(countSprite, "modulate", Color.TRANSPARENT, Conductor.crotchet / 1000 *1.1)
		sprTween.tween_property(countSprite, "scale", Vector2(0.5, 0.5), Conductor.crotchet / 1000)
		$PlayHud/countdownSpawner.add_child(countSprite)
		
		match curCountdown:
			0:
				GlobalSound.playSound("countdown/onyourmark")
				countSprite.texture = load("res://assets/images/ui/countdown/onyourmark.png")
			1:
				GlobalSound.playSound("countdown/ready")
				countSprite.texture = load("res://assets/images/ui/countdown/ready.png")
			2:
				GlobalSound.playSound("countdown/set")
				countSprite.texture = load("res://assets/images/ui/countdown/set.png")
			3:
				GlobalSound.playSound("countdown/go")
				countSprite.texture = load("res://assets/images/ui/countdown/go.png")
			4:
				countdownTimer.stop()
				$PlayHud/countdownSpawner.queue_free()
				onCountdown = false
				startSong()

		curCountdown += 1
	)
	countdownTimer.start(Conductor.crotchet / 1000)
	
func startSong():
	songStarted = true
	$inst.play()
	$playerVoices.play()
	$opponentVoices.play()
	
	Conductor.songPosition = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if !songStarted:
		Conductor.songPosition += delta * 1000
	else:
		var instTime = $inst.get_playback_position() + AudioServer.get_time_since_last_mix()
		Conductor.songPosition = instTime * 1000

	# Peak absolutely cinema guys
	camZoomAdd = lerpf(0, camZoomAdd, exp(-delta * 6.25))
	$camera.zoom.x = camZoom + camZoomAdd
	$camera.zoom.y = $camera.zoom.x

func beatHit():
	super()
	if curBeat % 4 == 0:
		camZoomAdd = 0.02
	$PlayHud.beatHit(curBeat)
