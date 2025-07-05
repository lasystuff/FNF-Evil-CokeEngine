extends Node2D
class_name FNFScene2D

var conductor:Conductor

func _init() -> void:
	conductor = Conductor.new()
	add_child(conductor)
	
	conductor.step_hit.connect(step_hit)
	conductor.beat_hit.connect(beat_hit)

func step_hit(step:int):
	pass
		
func beat_hit(beat:int):
	pass
