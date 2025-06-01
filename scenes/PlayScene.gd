extends FNFScene2D
class_name PlayScene

static var instance

static var playlist:Array = []
static var song:
	get():
		if playlist.size() > 0:
			return playlist[0]
		else:
			return null

var stage = null

var dj = null
var player = null
var opponent = null

var camFollow = Node2D.new()
var camFollowExt = Node2D.new()
var camZoom:float = 0.7
var camZoomAdd:float = 0

var onCountdown:bool = false
var songStarted:bool = false

var health:float = 1:
	set(value):
		if value > 2:
			value = 2
		health = value
		return value
var misses:int = 0
var score:float = 0

var accuracy:float = 1
var everyNote:float = 0
var hitNoteDiffs:float = 0

var combo:int = -1:
	set(value):
		combo = value
		if combo > maxCombo:
			maxCombo = combo
var maxCombo:int = 0
var comboBreaks:int = 0

var modchart:ModchartManager;
var modules:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	if song == null:
		playlist.push_back(SongData.getSong("bopeebo-erect", "hard"))

	var audio = SongData.getAudio(song)
	
	$inst.stream = load(audio.instrumental)
	if audio.player != null:
		$playerVoices.stream = load(audio.player)
	if audio.opponent != null:
		$opponentVoices.stream = load(audio.opponent)
		
	Conductor.bpm = song.bpm
	Conductor.mapBPMChanges(song)
	
	$playHud.game = instance
	$playHud/opponentStrums.scrollSpeed = song.speed
	$playHud/playerStrums.scrollSpeed = song.speed
	
	$playHud/opponentStrums.botplay = true
	$playHud/playerStrums.botplay = true
	$playHud/playerStrums.playNoteSplash = true
	
	$playHud/playerStrums.noteHit.connect(goodNoteHit)
	$playHud/playerStrums.noteMiss.connect(noteMissCallback)
	$playHud/opponentStrums.noteHit.connect(opponentNoteHit)
	
	if SaveData.data.downscroll:
		for lane in [$playHud/opponentStrums, $playHud/playerStrums]:
			lane.downscroll = true
			lane.position.y += 530
	if SaveData.data.middlescroll:
		$playHud/opponentStrums.visible = false
		$playHud/playerStrums.position.x = Constant.width/2
	
	# pushing notes
	for section in song.notes:
		for note in section.sectionNotes:
			var mustHit:bool = section.mustHitSection;
			if (note[1] > 3):
				mustHit = !section.mustHitSection
			
			var rawData = {
				"strumTime": note[0],
				"noteData": int(note[1]) % 4,
				"sustainLength": note[2]
			}
			if mustHit:
				$playHud/playerStrums.addNoteData(rawData)
			else:
				$playHud/opponentStrums.addNoteData(rawData)


	modchart = ModchartManager.new()
	add_child(modchart)
	$playHud/playerStrums.postUpdateNote.connect(func(): updateModchart(0))
	$playHud/opponentStrums.postUpdateNote.connect(func(): updateModchart(1))

	# init stages
	var targetStage = song.stage
	if !ResourceLoader.exists("res://scenes/stages/" + targetStage + ".tscn"):
		targetStage = "Stage"

	stage = load("res://scenes/stages/" + targetStage + ".tscn").instantiate()
	add_child(stage)
	
	dj = FNFCharacter2D.new("gf")
	add_child(dj)
	player = FNFCharacter2D.new("bf")
	add_child(player)
	player.flip_h = !player.flip_h
	opponent = FNFCharacter2D.new("dad")
	add_child(opponent)
	
	dj.idle()
	player.idle()
	opponent.idle()
	
	# stage var shit
	camZoom = stage.zoom
	
	dj.position += stage.get_node("djPos").global_position
	player.position += stage.get_node("playerPos").global_position
	opponent.position += stage.get_node("opponentPos").global_position
	
	for file in listExternalScript():
		var luaScript = LuaModule.new("external/" + file)
		addLuaVariables(luaScript)
		luaScript.do()
		modules[file] = luaScript
	for lua in modules.values(): lua.callLua("onReady")
	
	startCountdown()

var curCountdown:int = 0
func startCountdown():
	moveCamBySection()
	$playHud.initHud()
	onCountdown = true
	Conductor.songPosition = 0
	Conductor.songPosition -= Conductor.crotchet * 5
	
	var countdownTimer = Timer.new()
	
	add_child(countdownTimer)
	countdownTimer.timeout.connect(func():
		var countSprite = Sprite2D.new()
		countSprite.scale = Vector2(0.52, 0.52)
		var sprTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		sprTween.tween_property(countSprite, "modulate", Color.TRANSPARENT, Conductor.crotchet / 1000 *1.1)
		sprTween.tween_property(countSprite, "scale", Vector2(0.5, 0.5), Conductor.crotchet / 1000)
		$playHud/countdownSpawner.add_child(countSprite)
		
		match curCountdown:
			0:
				GlobalSound.playSound("countdown/onyourmark")
				countSprite.texture = load("res://assets/images/ui/countdown/onyourmark.png")
				
				player.idle()
				opponent.idle()
			1:
				GlobalSound.playSound("countdown/ready")
				countSprite.texture = load("res://assets/images/ui/countdown/ready.png")
			2:
				GlobalSound.playSound("countdown/set")
				countSprite.texture = load("res://assets/images/ui/countdown/set.png")
				
				player.idle()
				opponent.idle()
			3:
				GlobalSound.playSound("countdown/go")
				countSprite.texture = load("res://assets/images/ui/countdown/go.png")
			4:
				countdownTimer.stop()
				$playHud/countdownSpawner.queue_free()
				onCountdown = false
				startSong()
				
		dj.idle()

		curCountdown += 1
	)
	countdownTimer.start(Conductor.crotchet / 1000)
	for lua in modules.values(): lua.callLua("onStartCountdown")
	
func startSong():
	songStarted = true
	$inst.play()
	$playerVoices.play()
	$opponentVoices.play()
	
	Conductor.songPosition = 0
	for lua in modules.values(): lua.callLua("onSongStart")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if !songStarted:
		Conductor.songPosition += delta * 1000
	else:
		var instTime = $inst.get_playback_position() + AudioServer.get_time_since_last_mix()
		Conductor.songPosition = instTime * 1000

	# Peak absolutely cinema guys
	$camera.global_position = camFollow.global_position + camFollowExt.global_position
	camZoomAdd = lerpf(0, camZoomAdd, exp(-delta * 6.25))
	$camera.zoom.x = camZoom + camZoomAdd
	$camera.zoom.y = $camera.zoom.x
	$playHud.scale.x = 1 + camZoomAdd
	$playHud.scale.y = $playHud.scale.x
	# terrible fix of canvaslayer offsetting
	$playHud.offset.x = (-Constant.width/2)*($playHud.scale.x-1)
	$playHud.offset.y = (-Constant.height/2)*($playHud.scale.y-1)
	
	accuracy = (hitNoteDiffs / everyNote)*100
	
	if Input.is_action_just_pressed("ui_debug2"):
		Main.nextTransIn = "quickIn"
		if Input.is_key_pressed(KEY_SHIFT):
			CharacterDebug.characterName = player.characterName
			CharacterDebug.player = true
		else:
			CharacterDebug.characterName = opponent.characterName
			CharacterDebug.player = false
		Main.switchScene(preload("res://scenes/menu/debug/CharacterDebug.tscn"))
		
	for lua in modules.values(): lua.callLua("onProcess", [delta])

func beatHit():
	super()
	dj.idle()
	if curBeat % 2 == 0:
		player.idle()
		opponent.idle()
	if curBeat % 4 == 0:
		camZoomAdd = 0.02
	$playHud.beatHit(curBeat)
	for lua in modules.values(): lua.callLua("onBeatHit", [curBeat])

func goodNoteHit(note, isSustain):
	for lua in modules.values(): lua.callLua("onGoodNoteHit", [note, isSustain])
	
	$playerVoices.volume_db = 0
	doSingAnimation(player, note.noteData)
	
	if !isSustain:
		everyNote += 1
		var data = RatingData.judgements[RatingData.getRatingName(note.hitDiff)]

		score += 350*data.scoreMult
		health += 0.03
		hitNoteDiffs += data.accuaracyMult
		combo += 1
		
		spawnJudgementSprite(RatingData.getRatingName(note.hitDiff))
	else:
		score += 0.1

func noteMissCallback(note, isSustain):
	$playerVoices.volume_db = -80
	if isSustain:
		noteMiss(note.noteData, 0.04, player)
	else:
		everyNote += 1
		noteMiss(note.noteData, 0.08, player)

func noteMiss(id:int = 0, healthLoss:float = 1, character = null):
	misses += 1
	health -= healthLoss

	if combo > -1:
		combo = -1
		comboBreaks += 1
	
	var rng = RandomNumberGenerator.new()
	GlobalSound.playSound("missnote" + str(rng.randi_range(1, 3)))
	if character != null:
		doSingAnimation(character, id, "miss")

func opponentNoteHit(note, isSustain):
	for lua in modules.values(): lua.callLua("onOpponentNoteHit", [note, isSustain])
	doSingAnimation(opponent, note.noteData)

var animArray = ["singLEFT", "singDOWN", "singUP", "singRIGHT"]
func doSingAnimation(char:FNFCharacter2D, data:int, postfix:String = ""):
	if char.interruptible:
		char.playAnim(animArray[data] + postfix, true)

func sectionHit():
	super()
	moveCamBySection()
	for lua in modules.values(): lua.callLua("onSectionHit", [curSection])

func moveCamBySection():
	if song.notes[curSection].mustHitSection:
		moveCamera(player.position + player.cameraPosition + stage.playerCameraOffset)
	else:
		moveCamera(opponent.position + opponent.cameraPosition + stage.opponentCameraOffset)

var defaultCameraTrans = Tween.TRANS_EXPO
var defaultCameraEase = Tween.EASE_OUT

func moveCamera(position:Vector2, speed:float = 1.9, trans:Tween.TransitionType = defaultCameraTrans, ease:Tween.EaseType = defaultCameraEase):
	var camFollowTween = get_tree().create_tween()
	camFollowTween.set_trans(trans).set_ease(ease)
	camFollowTween.tween_property(camFollow, "position", position, speed)

func moveCameraExtend(position:Vector2, speed:float = 1.4, trans:Tween.TransitionType = defaultCameraTrans, ease:Tween.EaseType = defaultCameraEase):
	var camFollowExtTween = get_tree().create_tween()
	camFollowExtTween.set_trans(trans).set_ease(ease)
	camFollowExtTween.tween_property(camFollowExt, "position", position, speed)


func spawnJudgementSprite(judge:String):
	var judgeSpawner = $playHud/judgeSpawner
	var judgeWorld = stage.get_node_or_null("judgeSpawner")
	if (judgeWorld != null): #&& worldJudgeDisplay
		judgeSpawner = judgeWorld

	var judgeSprite = Sprite2D.new()
	judgeSprite.scale = Vector2(1.15, 1.15)
	judgeSprite.texture = load("res://assets/images/ui/judgements/" + judge + ".png")
	judgeSpawner.add_child(judgeSprite)

	var sprTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	sprTween.finished.connect(func(): judgeSprite.queue_free())
	sprTween.tween_property(judgeSprite, "scale", Vector2(1, 1), (Conductor.crotchet / 1000))
	sprTween.tween_property(judgeSprite, "modulate", Color.TRANSPARENT, (Conductor.crotchet / 1000)*2)
	sprTween.tween_property(judgeSprite, "position:y", judgeSprite.position.y + 140, (Conductor.crotchet / 1000)*2.3)

	if combo > 0:
		var comboDisplay = preload("res://scenes/objects/ComboDisplay.tscn").instantiate()
		comboDisplay.scale = Vector2(0.8, 0.8)
		comboDisplay.number = self.combo
		comboDisplay.global_position = Vector2(judgeSprite.global_position.x, judgeSprite.global_position.y + 200)
		judgeSpawner.add_child(comboDisplay)
		
		sprTween.finished.connect(func(): comboDisplay.queue_free())
		sprTween.tween_property(comboDisplay, "scale", Vector2(0.75, 0.75), (Conductor.crotchet / 1000))
		sprTween.tween_property(comboDisplay, "modulate", Color.TRANSPARENT, (Conductor.crotchet / 1000)*3)
		sprTween.tween_property(comboDisplay, "position:y", comboDisplay.position.y + 50, (Conductor.crotchet / 1000)*3)

func listExternalScript() -> Array:
	var finalArray = []
	var files = DirAccess.get_files_at("res://assets/scripts/external/")
	for file in files:
		if file.ends_with(".lua"):
			finalArray.push_back(file.split(".lua")[0])
	return finalArray

func addLuaVariables(module:LuaModule):
	module.lua.globals["game"] = PlayScene.instance
	module.lua.globals["modchart"] = PlayScene.instance.modchart

func updateModchart(player:int):
	var target = $playHud/opponentStrums
	if player == 0:
		target = $playHud/playerStrums
		
	for i in target.strums.size():
		modchart.updateStrum(target, i, player)
	for note in target.get_node("noteSpawner").get_children():
		modchart.updateNote(note, player)
