class_name ModchartSubModifier

var percent:Array = [0.0, 0.0]
func set_percent(value:float, player:int):
	if player < 0:
		percent = [value, value]
	else:
		percent[player] = value