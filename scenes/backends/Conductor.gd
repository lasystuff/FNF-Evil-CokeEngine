extends Node
class_name Conductor

var bpm:float = 0:
	set(value):
		bpm = value
		crotchet = (60 / bpm) * 1000
		step_crotchet = crotchet / 4

var crotchet:float:
	get():
		return (60 / bpm) * 1000
var step_crotchet:float:
	get():
		return crotchet/4

var song_position:float = 0
var lastSongPos:float = 0
var offset:float = 0

var current_step:int = 0
var current_beat:int = 0

signal step_hit(s:int)
signal beat_hit(b:int)

var bpmChanges:Array = []
	
func mapBPMChanges(song):
	bpmChanges = []
	var current_bpm:float = song.charts[song.difficulties[0]].bpm
	var current_step:int = 0
	for event in song.events:
		if event.name == "Change BPM" && event.data.bpm != current_bpm:
			var steps:float = (event.time - event.time) / ((60 / current_bpm) * 1000 / 4)
			current_step += steps
			bpmChanges.push_back({"step": current_step, "time": event.time, "bpm": current_bpm})

func _process(delta: float) -> void:
	var bpmChange = {"step": 0, "time": 0, "bpm": self.bpm}
	
	for event in bpmChanges:
		if  song_position >= event.time:
			bpmChange = event
			break
	if (bpm != bpmChange.bpm):
		bpm = bpmChange.bpm
		
	var oldStep:int = current_step
	var oldBeat:int = current_beat
	current_step = floor((bpmChange.step + (song_position - bpmChange.time) / step_crotchet))
	current_beat = floor(current_step / 4)

	if(oldStep != current_step):
		step_hit.emit(current_step)
		if (current_step % 4 == 0 && current_beat != oldBeat):
			beat_hit.emit(current_beat)
