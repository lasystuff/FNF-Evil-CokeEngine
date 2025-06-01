extends ModchartModifier
class_name AccelModifier

func _init() -> void:
	self.submods = {
		"brake": ModchartSubModifier.new(),
		"wave": ModchartSubModifier.new()
	}

func note_process(note:Note, player:int):
	if !note.autoFollow:
		return
		
	var noteDiff = Conductor.songPosition - note.strumTime

	var boost = percent[player]
	var brake = submods["brake"].percent[player]
	var wave = submods["wave"].percent[player]
	
	var effectHeight = 500
	var yAdjust:float = 0
		
	if(brake != 0):
		var scale = ModchartManager.scale(noteDiff, 0, effectHeight, 0, 1)
		var off = noteDiff * scale
		yAdjust += clampf(brake * (off - noteDiff),-400,400)

	if(boost!=0):
		var off = noteDiff * 1.5 / ((noteDiff + effectHeight/1.2)/effectHeight)
		yAdjust += clampf(boost * (off - noteDiff),-400,400)

	yAdjust += wave * 20 * sin(noteDiff/38)
	note.position.y += yAdjust
