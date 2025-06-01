extends Node2D
# TODO: make this custom object

var parentNote#:Note
var length:float = 0
const sustainHeight:float = 87

var lastLengthOld = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if parentNote != null:
		var speedAdjust = (parentNote.strumline.scrollSpeed*0.45) # Scroll Speed shit...
		# destroying sustain lol shitty implement
		if !parentNote.autoFollow:
			speedAdjust = 1
			var lastLength = ((parentNote.strumTime + parentNote.sustainLength) - Conductor.songPosition) * (parentNote.strumline.scrollSpeed*0.45)
			var susLengthAdjust = (lastLength / Conductor.stepCrotchet)
			self.length = susLengthAdjust
			if lastLengthOld != susLengthAdjust:
				lastLengthOld = susLengthAdjust
				parentNote.strumline.noteHit.emit(parentNote, true)
			# destroying shit
			if susLengthAdjust <= 0:
				self.queue_free()

		self.global_position = parentNote.global_position
		$sustain.scale.y = length * speedAdjust
	$tail.position.y = sustainHeight * $sustain.scale.y
	
	if parentNote.scale.y < 0:
		$sustain.flip_h = true
		$tail.flip_h = true
		scale.y = -1
	else:
		$sustain.flip_h = false
		$tail.flip_h = false
		scale.y = 1

func updateAnim():
	match parentNote.noteData:
		0:
			$sustain.frame = 0
			$tail.frame = 1
		1:
			$sustain.frame = 2
			$tail.frame = 3
		2:
			$sustain.frame = 4
			$tail.frame = 5
		3:
			$sustain.frame = 6
			$tail.frame = 7
