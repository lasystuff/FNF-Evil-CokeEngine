class_name SongData

static func getSong(song:String, difficulty:String = "normal", variation:String = ""):
	difficulty = normalizeDiff(difficulty)
	if variation == "default":
		variation = ""

	var songPath = "res://assets/data/songs/" + song
	var chartPath = songPath + "/" + song + difficulty + ".json"
	if FileAccess.file_exists(chartPath):
		var json = JSON.parse_string(FileAccess.get_file_as_string(chartPath))
		addExData(json.song, difficulty, variation)
		return json.song
	else:
		print("FUCK GUH UHHH NO CHART FUCKING FOUND!!!!!!! (" + chartPath + ") returning Test song instead! sorry bro")
		return getSong("test", "hard")

# add shitty stuffs to json
static func addExData(data, difficulty, variation):
	if !data.has("difficulty"):
		data.difficulty = difficulty
	if !data.has("variation"):
		data.variation = variation
	if !data.has("stage"):
		data.stage = "Stage"

static func normalizeDiff(diff:String):
	if diff == "normal" || diff == "erect":
		return ""
	else: return "-" + diff
		
static func getAudio(songData):
	var songPath = "res://assets/songs/" + songData.song + "/"
	
	var list = {
		"instrumental": songPath + "Inst.ogg", # Instrumental is required anyway
		"player": null,
		"opponent": null
	}
	
	if ResourceLoader.exists(songPath + "Inst-" + songData.variation + ".ogg"):
		list["instrumental"] = songPath + "Inst-" + songData.variation + ".ogg"

	if ResourceLoader.exists(songPath + "Voices-" + songData.player1 + ".ogg"):
		list["player"] = songPath + "Voices-" + songData.player1 + ".ogg"
	elif ResourceLoader.exists(songPath + "Voices.ogg"): # Classic Vocals
		list["player"] = songPath + "Voices.ogg"

	if ResourceLoader.exists(songPath + "Voices-" + songData.player2 + ".ogg"):
		list["opponent"] = songPath + "Voices-" + songData.player2 + ".ogg"
	
	return list
