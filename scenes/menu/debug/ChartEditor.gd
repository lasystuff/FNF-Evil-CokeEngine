extends FNFScene2D

var song:FNFSong
var difficulty:String = "nightmare"

var chart:
	get():
		return song.charts[difficulty]

var grid_size:int = 40
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CokeUtil.set_mouse_visibility(true)
	
	song = preload("res://assets/songs/bopeebo-erect/data.tres")
	for playerNote in chart.player.notes:
		var raw = {
			"strumTime": playerNote.time,
			"noteData": int(playerNote.id),
			"sustainLength": playerNote.length
		}
		
		var note = preload("res://scenes/objects/charteditor/EditorNote.tscn").instantiate()
		note.set_data(raw)
		$notes.add_child(note)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
