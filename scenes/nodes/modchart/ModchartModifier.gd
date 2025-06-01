class_name ModchartModifier

var percent:Array = [0.0, 0.0]
var submods:Dictionary = {}

func set_percent(value:float, player:int):
	if player < 0:
		percent = [value, value]
	else:
		percent[player] = value

func _process(delta:float): pass

func note_process(note:Note, player:int): pass
func strum_process(strum, strumId, player:int):pass
