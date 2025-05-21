extends Node2D

@onready var strums = [$left, $down, $up, $right]
var spawnDistance:float = 3000
var queuedNotes:Array = []

var scrollSpeed:float = 2.3
var botplay:bool = true

signal noteHit(note:Note)
signal noteMiss(note:Note)

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
			queuedNotes.erase(raw)
			
	# updating note pos & hit if this strumline on botplay
	for note in $noteSpawner.get_children():
		var targetX = strums[note.noteData].global_position.x
		var targetY = strums[note.noteData].global_position.y
		note.global_position.x = targetX
		note.global_position.y = (targetY - (Conductor.songPosition - note.strumTime) * (0.45 * scrollSpeed))
		updateNoteStatus(note)
		
		if botplay && Conductor.songPosition >= note.strumTime && note.status == Note.HITTABLE:
			noteHit.emit(note)

	var animArray = ["arrowLEFT", "arrowDOWN", "arrowUP", "arrowRIGHT"]
	for strum in strums:
		if !strum.is_playing():
			strum.play(animArray[strums.find(strum)])

# yoo guys guyz
func updateNoteStatus(note:Note):
	if note.status == Note.HIT || note.status == Note.MISSED:
		return

	if note.strumTime > Conductor.songPosition - Constant.noteSafeZone && note.strumTime < Conductor.songPosition + Constant.noteSafeZone:
		note.status = Note.HITTABLE
	elif (note.strumTime < Conductor.songPosition - Constant.noteSafeZone):
		_noteMiss(note)
	else:
		note.status = Note.NEUTRAL

func _noteHit(note):
	note.status = Note.HIT

	if note.sustainLength >= 0:
		# oh! worst take for sustain note! nice!
		note.self_modulate = Color.TRANSPARENT
	else:
		note.queue_free()
	
	var anims = ["left confirm", "down confirm", "up confirm", "right confirm"]
	strums[note.noteData].play(anims[note.noteData])

func _noteMiss(note):
	note.status = Note.MISSED
