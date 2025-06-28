extends Resource
class_name FNFSong

const default_chart:Dictionary = {
	"song": "",
	"bpm": 100,
	"notes": [],
	"stage": "Stage",
	"player1": "bf",
	"player2": "bf",
	"gf": "gf"
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

@export var difficulties:Array = []

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
				var d:Dictionary = {"song": default_chart}
				var chartPath = Paths.getPath("songs/" + self.name + "/chart/" + diff + ".json")
				if FileAccess.file_exists(chartPath):
					d = JSON.parse_string(FileAccess.get_file_as_string(Paths.getPath("songs/" + self.name + "/chart/" + diff + ".json")))
				charts[diff] = d.song
		
		return charts
