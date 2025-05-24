extends Node2D

@onready var strums = [$left, $down, $up, $right]
var spawnDistance:float = 3000
var queuedNotes:Array = []

var scrollSpeed:float = 1
# very funny implemetion but works so good im genious
var downscroll:bool = false:
	set(value):
		downscroll = value
		var thing = 1
		if downscroll:
			thing = -1
		self.scale.y = thing
		for strum in strums:
			strum.scale.y *= thing
	
var botplay:bool = false
var playNoteSplash:bool = false

var notePressTimer = [0, 0, 0, 0]
var controlArray = ["ui_left", "ui_down", "ui_up", "ui_right"]

var defaultAnims = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"]
var pressAnims = ["left press", "down press", "up press", "right press"]
var confirmAnims = ["left confirm", "down confirm", "up confirm", "right confirm"]

signal noteHit(note:Note, sustain:bool)
signal noteMiss(note:Note, sustain:bool)

func addNoteData(raw:Dictionary) -> void:
	queuedNotes.push_back(raw)
	queuedNotes.sort_custom(func(a, b): return a.strumTime < b.strumTime)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noteHit.connect(_noteHit)
	noteMiss.connect(_noteMiss)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if queuedNotes.size() > 0:
		var raw = queuedNotes[0]
		# spawn note if in the spawn distance
		if raw.strumTime - Conductor.songPosition < spawnDistance:
			var note = Note.new(raw.strumTime, raw.noteData, raw.sustainLength)
			$noteSpawner.add_child(note)
			note.strumline = self
			queuedNotes.erase(raw)
			
	# updating note pos & hit if this strumline on botplay
	for note in $noteSpawner.get_children():
		if !note.autoFollow:
			continue
		var targetX = strums[note.noteData].global_position.x
		var targetY = strums[note.noteData].global_position.y
		note.global_position.x = targetX
		#strum rotation do cool stuffs so i dont need to edit sustain shit yay!!
		if downscroll:
			note.global_position.y = targetY + (Conductor.songPosition - note.strumTime) * (0.45 * scrollSpeed)
		else:
			note.global_position.y = targetY - (Conductor.songPosition - note.strumTime) * (0.45 * scrollSpeed)
		updateNoteStatus(note)
		
		if botplay && Conductor.songPosition >= note.strumTime && note.status == Note.HITTABLE:
			note.hitDiff = 0 # relly awrsome
			noteHit.emit(note, false)
			
	if !botplay:
		inputProcess(delta)
	for strum in strums.size():
		strumPlay(strum, "default")

# yoo guys guyz
func updateNoteStatus(note:Note):
	if note.status == Note.HIT || note.status == Note.MISSED:
		return

	if note.strumTime > Conductor.songPosition - Constant.noteSafeZone && note.strumTime < Conductor.songPosition + Constant.noteSafeZone:
		note.status = Note.HITTABLE
	elif (note.strumTime < Conductor.songPosition - Constant.noteSafeZone):
		noteMiss.emit(note, false)
	else:
		note.status = Note.NEUTRAL

func _noteHit(note, isSustain):
	note.status = Note.HIT

	if (!isSustain):
		if playNoteSplash:
			var splash = preload("res://scenes/objects/NoteSplash.tscn").instantiate()
			strums[note.noteData].add_child(splash)
			splash.start(note)
		if note.sustainLength >= 0:
			note.autoFollow = false
			note.global_position.y = strums[note.noteData].global_position.y
			# oh! worst take for sustain note! nice!
			note.self_modulate = Color.TRANSPARENT
		else:
			note.queue_free()
	else:
		if note.sustain.length <= 0:
			note.queue_free()
			return
		if !botplay && !Input.is_action_pressed(controlArray[note.noteData]):
			noteMiss.emit(note, true)

	strumPlay(note.noteData, "confirm")

func _noteMiss(note, isSustain):
	note.status = Note.MISSED
	note.queue_free()

func inputProcess(delta:float):
	for i in controlArray.size():
		if Input.is_action_just_pressed(controlArray[i]):
			strumPlay(i, "press")
			notePressTimer[i] = 1
	
	for i in notePressTimer.size():
		notePressTimer[i] -= delta*10
		if notePressTimer[i] < 0:
			notePressTimer[i] = 0
			
	for note in $noteSpawner.get_children():
		if note.status == Note.HITTABLE && notePressTimer[note.noteData] > 0:
			note.hitDiff = Conductor.songPosition - note.strumTime
			noteHit.emit(note, false)


func strumPlay(id:int, animType:String = "default"):
	var targetStrum = strums[id]
	match animType:
		"default":
			if (botplay && !targetStrum.is_playing()) || (!botplay && !Input.is_action_pressed(controlArray[id])):
				strums[id].play(defaultAnims[id])
		"press":
			if targetStrum.animation == defaultAnims[id]:
				strums[id].play(pressAnims[id])
		"confirm":
			strums[id].stop()
			strums[id].play(confirmAnims[id])
