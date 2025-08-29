extends ModchartModifier
class_name OpponentModifier

func strum_process(strumline, strumId:float, player:int):
	if (percent[player] == 0):
		return

	var distX = Constant.width / 2
	strumline.strums[strumId].position.x += distX * sign((player + 1) * 2 - 3) * percent[player]
	
func note_process(note:Note, player:int):
	if (percent[player] == 0):
		return

	var distX = Constant.width / 2
	note.position.x += distX * sign((player + 1) * 2 - 3) * percent[player]
