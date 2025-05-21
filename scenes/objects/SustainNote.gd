extends Node2D
# TODO: make this custom object

var parentNote#:Note
var length:float = 0
const sustainWidth:float = 44

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if parentNote != null:
		self.global_position = parentNote.global_position
		$sustain.scale.y = 4 + (1.5 * length)
	$tail.position.y = (sustainWidth * $sustain.scale.y) - 1.3

func updateAnim():
	match parentNote.noteData:
		0:
			$sustain.play("purple hold piece")
			$tail.play("pruple end hold") # BRO
		1:
			$sustain.play("blue hold piece")
			$tail.play("blue hold end")
		2:
			$sustain.play("green hold piece")
			$tail.play("green hold end")
		3:
			$sustain.play("red hold piece")
			$tail.play("red hold end")
