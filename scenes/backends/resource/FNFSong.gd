extends Resource
class_name FNFSong

const default_chart:Dictionary = {
	"bpm": 100,
	"scroll_speed": 1.0,

	"player": {"character": "bf", "notes":[]},
	"opponent": {"character": "dad", "notes":[]},
	"dj": {"character": "gf", "notes":[]},

	"stage": "Stage"
}

@export var name:String

@export_category("Metadata")
@export var display_name:String:
	get():
		if display_name == null:
			return self.name
		return display_name

@export var artist:String = ""
@export var charter:String = ""

@export var difficulties:Array[String] = []

@export_category("Audio")
@export var instrumental:AudioStream
@export var player_vocals:AudioStream
@export var opponent_vocals:AudioStream
@export_category("Extra")
@export_multiline var extra_description:String = ""

var charts:Dictionary:
	get():
		if charts.size() <= 0:
			for diff in difficulties:
				var d:Dictionary = default_chart
				var chartPath = Paths.getPath("songs/" + self.name + "/chart/" + diff + ".json")
				if FileAccess.file_exists(chartPath):
					d = JSON.parse_string(FileAccess.get_file_as_string(chartPath))
				charts[diff] = d
		
		return charts
		
var events:Array:
	get():
		var eventPath = Paths.getPath("songs/" + self.name + "/events.json")
		if FileAccess.file_exists(eventPath):
			var d = JSON.parse_string(FileAccess.get_file_as_string(eventPath))
			return d.events
		return []
