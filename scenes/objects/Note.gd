extends AnimatedSprite2D
class_name Note

enum
{
	NEUTRAL,
	HITTABLE,
	HIT,
	MISSED
}

var strumTime:float = 0
var noteData:int = 0
var sustainLength:int = 0

var strumline;
var sustain;

var status = NEUTRAL
var autoFollow:bool = true # for sustain notes

func _init(time:float, id:int, susLength:float) -> void:
	self.strumTime = time
	self.noteData = id
	self.sustainLength = susLength

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_frames = preload("res://assets/images/ui/NOTE_assets.xml")
	scale = Vector2(0.7, 0.7)
	
	match noteData:
		0:
			play("purple")
		1:
			play("blue")
		2:
			play("green")
		3:
			play("red")
	self.position.y += 3000
	
	var susLengthAdjust = sustainLength / Conductor.stepCrotchet
	if(roundf(susLengthAdjust) > 0):
		var sustainNote = preload("res://scenes/objects/SustainNote.tscn").instantiate()
		sustainNote.parentNote = self
		sustainNote.length = susLengthAdjust
		self.add_child(sustainNote)
		sustainNote.updateAnim()
		self.sustain = sustainNote
	else:
		sustainLength = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
