extends FNFScene2D
class_name PlayScene

enum PlayMode
{
	STORY,
	FREEPLAY,
	CHARTER
}

static var instance

static var playlist:Array = []
static var song:FNFSong:
	get():
		if playlist.size() > 0:
			return playlist[0]
		else:
			return null

static var chart:
	get():
		if song != null:
			return song.charts[difficulty]
		else:
			return null
static var events:Array = []

static var level:String = ""
static var difficulty:String = "hard"
static var play_mode:PlayMode = PlayMode.FREEPLAY

var stage = null

var dj = null
var player = null
var opponent = null
var extra_characters:Dictionary = {}

var camFollow = Node2D.new()
var camFollowExt = Node2D.new()
var camZoom:float = 0.7
var camZoomAdd:float = 0
var camZoomMult:float = 1

var camera_bop_rate:int = 4

var onCountdown:bool = false
var songStarted:bool = false

static var static_stat:Dictionary

var health:float = 1:
	set(value):
		if value > 2:
			value = 2
		health = value
		if health <= 0:
			if health < 0:
				health = 0
			death()
		return value
var misses:int = 0
var score:float = 0

var accuracy:float = 100
var everyNote:float = 0
var hitNoteDiffs:float = 0

var combo:int = -1:
	set(value):
		combo = value
		if combo > maxCombo:
			maxCombo = combo
var maxCombo:int = 0
var comboBreaks:int = 0

var scroll_speed_mult:float = 1

var modchart:ModchartManager
var modules:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	GlobalSound.stop_music()
	CokeUtil.set_mouse_visibility(false)

	if static_stat == null || static_stat == {}:
		static_stat = {"score": 0, "misses": 0, "accuracy": 0}
	events = song.events.duplicate(true)
	
	$inst.stream = song.instrumental
	$playerVoices.stream = song.player_vocals
	$opponentVoices.stream = song.opponent_vocals
		
	conductor.bpm = chart.bpm
	conductor.mapBPMChanges(song)
	
	DiscordData.set_rpc("Playing " + song.display_name + " (" + difficulty + ")")
	
	$hud/playUI.game = instance
	
	$hud/opponentStrums.botplay = true
	$hud/playerStrums.botplay = true
	$hud/playerStrums.playNoteSplash = true
	
	$hud/playerStrums.noteHit.connect(goodNoteHit)
	$hud/playerStrums.noteMiss.connect(noteMissCallback)
	if !SaveData.data.ghostTap:
		$hud/playerStrums.ghostTapped.connect(func(i): noteMiss(i, 0.02, player))
	$hud/opponentStrums.noteHit.connect(opponentNoteHit)
	
	if SaveData.data.downscroll:
		for lane in [$hud/opponentStrums, $hud/playerStrums]:
			lane.downscroll = true
			lane.position.y += 530
	
	# pushing notes
	for opponentNote in chart.opponent.notes:
		var rawData = {
			"strumTime": opponentNote.time,
			"noteData": int(opponentNote.id),
			"sustainLength": opponentNote.length
		}
		$hud/opponentStrums.addNoteData(rawData)

	for playerNote in chart.player.notes:
		var rawData = {
			"strumTime": playerNote.time,
			"noteData": int(playerNote.id),
			"sustainLength": playerNote.length
		}
		$hud/playerStrums.addNoteData(rawData)


	modchart = ModchartManager.new()
	add_child(modchart)
	$hud/playerStrums.postUpdateNote.connect(func(): updateModchart(0))
	$hud/opponentStrums.postUpdateNote.connect(func(): updateModchart(1))
	
	if SaveData.data.middlescroll:
		modchart.set_percent("opponent", 50)
		$hud/opponentStrums.visible = false

	# init stages
	var targetStage = chart.stage
	if !ResourceLoader.exists("res://scenes/stages/" + targetStage + ".tscn") && !listStageScript().has(targetStage):
			targetStage = "Stage"

	if listStageScript().has(targetStage):
		stage = preload("res://scenes/backends/helper/LuaScriptStage.tscn").instantiate()
		
		var luaScript = LuaModule.new("stages/" + targetStage)
		addLuaVariables(luaScript)
		
		luaScript.lua.globals["stage"] = stage
		luaScript.lua.globals["playerPos"] = stage.get_node("playerPos")
		luaScript.lua.globals["opponentPos"] = stage.get_node("opponentPos")
		luaScript.lua.globals["djPos"] = stage.get_node("djPos")
		
		luaScript.do()
		modules["_stage_"] = luaScript
		luaScript.callLua("build")
	else:
		stage = load("res://scenes/stages/" + targetStage + ".tscn").instantiate()
	add_child(stage)
	
	dj = FNFCharacter2D.new(chart.dj.character)
	add_child(dj)
	player = FNFCharacter2D.new(chart.player.character)
	add_child(player)
	player.flip_h = !player.flip_h
	opponent = FNFCharacter2D.new(chart.opponent.character)
	add_child(opponent)
	
	dj.idle()
	player.idle()
	opponent.idle()
	
	# stage var shit
	camZoom = stage.zoom
	
	stage.init_characters()
	
	for file in listGlobalScript():
		var luaScript = LuaModule.new("global/" + file)
		addLuaVariables(luaScript)
		luaScript.do()
		modules[file] = luaScript
		luaScript.callLua("onReady")
	
	startCountdown()

var curCountdown:int = 0
func startCountdown():
	$hud/playUI.initHud()
	onCountdown = true
	conductor.song_position = 0
	conductor.song_position -= conductor.crotchet * 5
	
	var countdownTimer = Timer.new()
	
	add_child(countdownTimer)
	countdownTimer.timeout.connect(func():
		var countSprite = Sprite2D.new()
		countSprite.scale = Vector2(0.52, 0.52)
		var sprTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		sprTween.tween_property(countSprite, "modulate", Color.TRANSPARENT, conductor.crotchet / 1000 *1.1)
		sprTween.tween_property(countSprite, "scale", Vector2(0.5, 0.5), conductor.crotchet / 1000)
		$hud/countdownSpawner.add_child(countSprite)
		
		match curCountdown:
			0:
				GlobalSound.play_sound("countdown/onyourmark")
				countSprite.texture = load(Paths.image("ui/countdown/onyourmark"))
				
				player.idle()
				opponent.idle()
			1:
				GlobalSound.play_sound("countdown/ready")
				countSprite.texture = load(Paths.image("ui/countdown/ready"))
			2:
				GlobalSound.play_sound("countdown/set")
				countSprite.texture = load(Paths.image("ui/countdown/set"))
				
				player.idle()
				opponent.idle()
			3:
				GlobalSound.play_sound("countdown/go")
				countSprite.texture = load(Paths.image("ui/countdown/go"))
			4:
				countdownTimer.stop()
				$hud/countdownSpawner.queue_free()
				onCountdown = false
				startSong()
				
		dj.idle()

		curCountdown += 1
	)
	countdownTimer.start(conductor.crotchet / 1000)
	for lua in modules.values(): lua.callLua("onStartCountdown")
	for event in events:
		if event.time == 0 && event.name == "Move Camera":
			call_event(event.name, event.data)
			events.erase(event)
	
func startSong():
	songStarted = true
	$inst.play()
	$playerVoices.play()
	$opponentVoices.play()
	
	conductor.song_position = 0
	for lua in modules.values(): lua.callLua("onSongStart")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !songStarted:
		conductor.song_position += delta * 1000
	else:
		var instTime = $inst.get_playback_position() + AudioServer.get_time_since_last_mix()
		conductor.song_position = instTime * 1000
		for event in events:
			if  conductor.song_position >= event.time:
				call_event(event.name, event.data)
				events.erase(event)

	# Peak absolutely cinema guys
	$camera.global_position = camFollow.global_position + camFollowExt.global_position
	camZoomAdd = lerpf(0, camZoomAdd, exp(-delta * 6.25))
	$camera.zoom.x = (camZoom * camZoomMult) + camZoomAdd
	$camera.zoom.y = $camera.zoom.x
	$hud.scale.x = 1 + camZoomAdd
	$hud.scale.y = $hud.scale.x
	# terrible fix of canvaslayer offsetting
	$hud.offset.x = (-Constant.width/2)*($hud.scale.x-1)
	$hud.offset.y = (-Constant.height/2)*($hud.scale.y-1)
	
	if everyNote < 1:
		accuracy = 0
	else:
		accuracy = (hitNoteDiffs / everyNote)*100
	
	if Input.is_action_just_pressed("ui_accept"):
		Main.instance.get_node("SubSceneLoader").add_child(load("res://scenes/PauseScreen.tscn").instantiate())
		self.process_mode = Node.PROCESS_MODE_DISABLED

	if Input.is_action_just_pressed("ui_debug2"):
		Main.nextTransIn = "quickIn"
		if Input.is_key_pressed(KEY_SHIFT):
			CharacterDebug.characterName = player.characterName
			CharacterDebug.player = true
		else:
			CharacterDebug.characterName = opponent.characterName
			CharacterDebug.player = false
		Main.switch_scene(preload("res://scenes/menu/debug/CharacterDebug.tscn"))
	if Input.is_action_just_pressed("kill"):
		self.health = 0
		
	$hud/opponentStrums.scrollSpeed = chart.scroll_speed * scroll_speed_mult
	$hud/playerStrums.scrollSpeed = chart.scroll_speed * scroll_speed_mult
		
	for lua in modules.values(): lua.callLua("onProcess", [delta])

func beat_hit(beat):
	dj.idle()
	if beat % 2 == 0:
		player.idle()
		opponent.idle()
	if beat % camera_bop_rate == 0:
		camZoomAdd = 0.025
	$hud/playUI.beatHit(beat)
	for lua in modules.values(): lua.callLua("onBeatHit", [beat])

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
	GlobalSound.play_sound("missnote" + str(rng.randi_range(1, 3)))
	if character != null:
		doSingAnimation(character, id, "miss")

func opponentNoteHit(note, isSustain):
	for lua in modules.values(): lua.callLua("onOpponentNoteHit", [note, isSustain])
	doSingAnimation(opponent, note.noteData)

var animArray = ["singLEFT", "singDOWN", "singUP", "singRIGHT"]
func doSingAnimation(char:FNFCharacter2D, data:int, postfix:String = ""):
	if char.interruptible:
		char.playAnim(animArray[data] + postfix, true)

var camera_target:String = "player"
const defaultCameraTrans = Tween.TRANS_EXPO
const defaultCameraEase = Tween.EASE_OUT

func moveCamera(position:Vector2, speed:float = 1.9, trans:Tween.TransitionType = defaultCameraTrans, ease:Tween.EaseType = defaultCameraEase):
	var camFollowTween = get_tree().create_tween()
	camFollowTween.set_trans(trans).set_ease(ease)
	camFollowTween.tween_property(camFollow, "position", position, speed)

func moveCameraExtend(position:Vector2, speed:float = 1.4, trans:Tween.TransitionType = defaultCameraTrans, ease:Tween.EaseType = defaultCameraEase):
	var camFollowExtTween = get_tree().create_tween()
	camFollowExtTween.set_trans(trans).set_ease(ease)
	camFollowExtTween.tween_property(camFollowExt, "position", position, speed)


func spawnJudgementSprite(judge:String):
	var judgeSpawner = $hud/judgeSpawner
	var judgeWorld = stage.judgeSpawner
	if (judgeWorld != null): #&& worldJudgeDisplay
		judgeSpawner = judgeWorld

	var judgeSprite = Sprite2D.new()
	judgeSprite.scale = Vector2(1.15, 1.15)
	judgeSprite.texture = load(Paths.image("ui/judgements/" + judge))
	judgeSpawner.add_child(judgeSprite)

	var sprTween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	sprTween.finished.connect(func(): judgeSprite.queue_free())
	sprTween.tween_property(judgeSprite, "scale", Vector2(1, 1), (conductor.crotchet / 1000))
	sprTween.tween_property(judgeSprite, "modulate", Color.TRANSPARENT, (conductor.crotchet / 1000)*2)
	sprTween.tween_property(judgeSprite, "position:y", judgeSprite.position.y + 140, (conductor.crotchet / 1000)*2.3)

	if combo > 0:
		var comboDisplay = preload("res://scenes/objects/ComboDisplay.tscn").instantiate()
		comboDisplay.scale = Vector2(0.8, 0.8)
		comboDisplay.number = self.combo
		comboDisplay.global_position = Vector2(judgeSprite.global_position.x, judgeSprite.global_position.y + 200)
		judgeSpawner.add_child(comboDisplay)
		
		sprTween.finished.connect(func(): comboDisplay.queue_free())
		sprTween.tween_property(comboDisplay, "scale", Vector2(0.75, 0.75), (conductor.crotchet / 1000))
		sprTween.tween_property(comboDisplay, "modulate", Color.TRANSPARENT, (conductor.crotchet / 1000)*3)
		sprTween.tween_property(comboDisplay, "position:y", comboDisplay.position.y + 50, (conductor.crotchet / 1000)*3)

func listGlobalScript() -> Array:
	var finalArray = []
	var files = Paths.list("scripts/global/")
	for file in files:
		if file.ends_with(".lua"):
			finalArray.push_back(file.split(".lua")[0])
	return finalArray
	
func listStageScript() -> Array:
	var finalArray = []
	var files = Paths.list("scripts/stages/")
	for file in files:
		if file.ends_with(".lua"):
			finalArray.push_back(file.split(".lua")[0])
	return finalArray

static func addLuaVariables(module:LuaModule):
	module.lua.globals["game"] = PlayScene.instance
	module.lua.globals["modchart"] = PlayScene.instance.modchart
	
	module.lua.globals["add_stage_sprite"] = func(obj): PlayScene.instance.stage.add_child(obj)
	module.lua.globals["add_hud_sprite"] = func(obj): PlayScene.instance.get_node("hud").add_child(obj)
	
	# h,s,v,b
	module.lua.globals["set_hsv_adjust"] = func(obj, h:float = 0, s:float = 1, v:float = 1, b:float = 0):
		obj.material = ShaderMaterial.new()
		obj.material.shader = preload("res://assets/shaders/hsv_adjust.gdshader")
		
		obj.material.set_shader_parameter("hue_shift", h)
		obj.material.set_shader_parameter("saturation_mult", s)
		obj.material.set_shader_parameter("value_mult", v)
		obj.material.set_shader_parameter("brightness_add", b)

func updateModchart(player:int):
	var target = $hud/opponentStrums
	if player == 0:
		target = $hud/playerStrums

	for i in target.strums.size():
		modchart.updateStrum(target, i, player)
	for note in target.get_node("noteSpawner").get_children():
		modchart.updateNote(note, player)

# ending song stuff
func _on_inst_finished() -> void:
	# continue to next song
	static_stat["score"] += self.score
	static_stat["misses"] += self.misses
	static_stat["accuracy"] += self.accuracy
	if static_stat["accuracy"] > 100:
		static_stat["accuracy"] = 100
		
	if playlist.size() > 1:
		playlist.pop_front()
		Main.nextTransIn = "quickIn"
		Main.nextTransOut = "quickOut"
		Main.switch_scene(preload("res://scenes/PlayScene.tscn"))
	else:
		match play_mode:
			PlayMode.FREEPLAY:
				var replace:bool = true
				if SaveData.data._score.has(song.id + "-" + difficulty):
					var ogData = SaveData.data._score[song.id + "-" + difficulty]
					if ogData.score < static_stat.score:
						replace = false
				if replace:
					SaveData.data._score[song.id + "-" + difficulty] = static_stat
				Main.switch_scene(load("res://scenes/menu/Freeplay.tscn"))
			PlayMode.STORY:
				SaveData.data._score["story_" + level] = static_stat
				Main.switch_scene("MainMenuState")
			PlayMode.CHARTER:
				Main.switch_scene("MainMenuState")
		static_stat = {}

var died:bool = false
# haha funny thing lmfao
func death():
	if died:
		return
	died = true

	$hud.visible = false #grrr kys kys kys
	var thing = load("res://scenes/GameOverScreen.tscn").instantiate()
	thing.global_position = self.player.global_position
	add_child(thing)
	self.process_mode = Node.PROCESS_MODE_DISABLED

	DiscordData.set_rpc("Game Over - " + song.display_name + " (" + difficulty + ")")

func call_event(name:String, data:Dictionary):
	for lua in modules.values(): lua.callLua("onCallEvent", [name, data])
	
	match name:
		"Move Camera":
			var target_pos = Vector2.ZERO
			if data.has("position"):
				target_pos = Vector2(data.position[0], data.position[1])
			
			if data.has("target"):
				camera_target = data.target
				if data.target == "player":
					target_pos += player.position + player.cameraPosition + stage.playerCameraOffset
				else:
					target_pos += opponent.position + opponent.cameraPosition + stage.opponentCameraOffset

			var trans = defaultCameraTrans
			if data.has("trans"):
				trans = data.trans
			var ease = defaultCameraEase
			if data.has("ease"):
				ease = data.ease
			var speed = 1.9
			if data.has("speed"):
				speed = conductor.step_crotchet * data.speed / 1000
			moveCamera(target_pos, speed, trans, ease)
		"Zoom Camera":
			var targetZoom = 1;
			if data.has("value"):
				targetZoom = data.value

			if data.has("speed"):
				var trans = defaultCameraTrans
				if data.has("trans"):
					trans = data.trans
				var ease = defaultCameraEase
				if data.has("ease"):
					ease = data.ease

				var zoomMultTween = get_tree().create_tween()
				zoomMultTween.set_trans(trans).set_ease(ease)
				zoomMultTween.tween_property(self, "camZoomMult", targetZoom, conductor.step_crotchet * data.speed / 1000)
			else:
				camZoomMult = targetZoom
		"Set Camera Bop Rate":
			camera_bop_rate = int(data.value)
		"Change Scroll Speed":
			if data.has("speed"):
				var scrollTween = get_tree().create_tween()
				
				if data.has("trans"):
					scrollTween.set_trans(data.trans)
				if data.has("ease"):
					scrollTween.set_ease(data.ease)

				scrollTween.tween_property(self, "scroll_speed_mult", data.value, conductor.step_crotchet * data.speed / 1000)
			else:
				scroll_speed_mult = data.value
		"Play Animation":
			var target
			match(data.target.to_lower()):
				"player":
					target = player
				"opponent":
					target = opponent
				"dj":
					target = dj
				_:
					target = extra_characters.get(data.target, opponent)
			
			target.playAnim(data.animation, data.has("force") && data.force)
