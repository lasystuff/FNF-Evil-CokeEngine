extends ModchartModifier
class_name DrunkModifier

func _init() -> void:
	self.submods = {
		"tipsy": ModchartSubModifier.new(),
		"drunkSpeed": ModchartSubModifier.new(),
		"tipsySpeed": ModchartSubModifier.new()
	}
	
func strum_process(strumline, strumId:float, player:int):
	var drunkPerc = percent[player]
	var tipsyPerc = submods["tipsy"].percent[player]
	var tipsySpeed = ModchartManager.scale(submods["tipsySpeed"].percent[player], 0,1,1,2)
	var drunkSpeed = ModchartManager.scale(submods["drunkSpeed"].percent[player], 0,1,1,2)

	var time = Conductor.songPosition/1000
	if(drunkPerc != 0):
		strumline.strums[strumId].position.x += drunkPerc * (cos((time + strumId*0.2)*drunkSpeed) * 112*0.5)


func note_process(note:Note, player:int):
	if !note.autoFollow:
		return
	var drunkPerc = percent[player]
	var tipsyPerc = submods["tipsy"].percent[player]
	var drunkSpeed = ModchartManager.scale(submods["drunkSpeed"].percent[player], 0,1,1,2)
	
	var time = Conductor.songPosition/1000
	
	note.position.x = note.position.x + (drunkPerc*(cos((time + note.noteData*.2 + note.position.y*10/Constant.height)*drunkSpeed) * 112*0.5))
