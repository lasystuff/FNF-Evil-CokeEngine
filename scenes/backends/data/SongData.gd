class_name SongData

static func getSong(song:String, difficulty:String = "normal", variation:String = ""):
	difficulty = normalizeDiff(difficulty)
	if variation == "default":
		variation = ""

	var songPath = "res://assets/data/songs/" + song
	var chartPath = songPath + "/" + song + difficulty + ".json"
	if FileAccess.file_exists(chartPath):
		var json = JSON.parse_string(FileAccess.get_file_as_string("res://assets/songs/" + "/metadata.json"))
		return json.song
	else:
		print("FUCK GUH UHHH NO CHART FUCKING FOUND!!!!!!! (" + chartPath + ") returning Test song instead! sorry bro")
		return getSong("test", "hard")
	
static func normalizeDiff(diff:String):
	if diff == "normal" || diff == "erect":
		diff = ""
	return "-" + diff
		
static func getAudio(song:String, variation:String):
	var list = {
		"instrumental": "Inst",
		"player": "Voices",
		"opponent": ""
	}
	
	var songPath = "res://assets/data/songs/" + song
	var songData = getSong(song, "", variation)
	
	if FileAccess.file_exists(songPath + "/Inst-" + variation + ".ogg"):
		list["instrumental"] = "Inst-" + variation

	if FileAccess.file_exists(songPath + "/Voices-" + songData.player1 + ".ogg"):
		list["player"] = "Voices-" + songData.player1
	if FileAccess.file_exists(songPath + "/Voices-" + songData.player2 + ".ogg"):
		list["opponent"] = "Voices-" + songData.player2
