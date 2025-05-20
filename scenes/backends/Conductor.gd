extends Node
class_name Conductor

static var bpm:float = 0:
	set(value):
		bpm = value
		crotchet = (60 / bpm) * 1000
		stepCrotchet = crotchet / 4

static var crotchet:float
static var stepCrotchet:float

static var songPosition:float = 0
static var lastSongPos:float = 0
static var offset:float = 0

static var safeZoneOffset:float:
	get():
		return 6000; # is safeFrames in milliseconds
static var bpmChangeMap:Array = [];

static func getBPMFromSeconds(time:float):
	var lastChange = {
		"stepTime": 0,
		"songTime": 0,
		"bpm": bpm,
		"stepCrotchet": stepCrotchet
	}
	for i in range(bpmChangeMap.size() - 1):
		if time >= bpmChangeMap[i].songTime:
			lastChange = bpmChangeMap[i];
	return lastChange
	
static func mapBPMChanges(song):
	bpmChangeMap = []
	
	var curBPM:float = song.bpm
	var totalSteps:int = 0
	var totalPos:int = 0
	for i in range(song.notes.size() - 1):
		if song.notes[i].has("changeBPM") && song.notes[i].changeBPM && song.notes[i].bpm != curBPM:
			curBPM = song.notes[i].bpm
			var event= {
				"stepTime": totalSteps,
				"songTime": totalPos,
				"bpm": curBPM,
				"stepCrotchet": (60 / curBPM) * 1000
			}
			bpmChangeMap.append(event)
		
		var deltaSteps = round(getSectionBeats(song, i) * 4)
		totalSteps += deltaSteps
		totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps
		
	print("new BPM map BUDDY " + str(bpmChangeMap))

static func getSectionBeats(song, section:int):
	if (song.notes[section].has("sectionBeats")):
		return song.notes[section].sectionBeats
	return 4
