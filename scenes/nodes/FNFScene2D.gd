extends Node2D
class_name FNFScene2D

var curSection:int = 0
var stepsToDo:int = 0

var curStep:int = 0
var curBeat:int = 0

var curDecStep:float = 0
var curDecBeat:float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var oldStep:int = curStep
	updateCurStep()
	updateBeat()
	
	if (oldStep != curStep):
		if (curStep > 0):
			stepHit()
		if (PlayScene.song != null):
			if (oldStep < curStep):
				updateSection()
			else:
				rollbackSection()

func updateSection():
	if (stepsToDo < 1):
		stepsToDo = round(getBeatsOnSection() * 4)
	while (curStep >= stepsToDo):
		curSection += 1
		var beats:float = getBeatsOnSection()
		stepsToDo += round(beats * 4)
		sectionHit()
		
func rollbackSection():
	if (curStep < 0):
		return
	var lastSection:int = curSection
	curSection = 0
	stepsToDo = 0
	for i in range(PlayScene.song.notes.size()):
		if (PlayScene.song.notes[i] != null):
			stepsToDo += round(getBeatsOnSection() * 4)
			if (stepsToDo > curStep): break

			curSection+= 1

		if (curSection > lastSection):
			sectionHit()
		
func updateCurStep():
	var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition)

	var shit = (Conductor.songPosition - lastChange.songTime) / lastChange.stepCrotchet
	curDecStep = lastChange.stepTime + shit
	curStep = lastChange.stepTime + floorf(shit)

func updateBeat():
	curBeat = floor(curStep / 4)
	curDecBeat = curDecStep / 4
	
func getBeatsOnSection():
	var val = 4
	if (PlayScene.song != null && PlayScene.song.notes[curSection] != null && PlayScene.song.notes[curSection].has("sectionBeats")):
		val = PlayScene.song.notes[curSection].sectionBeats
	return val

func stepHit():
	if (curStep % 4 == 0):
		beatHit()
		
func beatHit():
	pass

func sectionHit():
	if (PlayScene.song.notes[curSection] != null):
		if (PlayScene.song.notes[curSection].has("changeBPM") && PlayScene.song.notes[curSection].changeBPM):
			Conductor.bpm = PlayScene.song.notes[curSection].bpm
