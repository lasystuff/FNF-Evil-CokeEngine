class_name SongData

static func getSong(song:String, difficulty:String = "normal", variation:String = ""):
	difficulty = normalizeDiff(difficulty)
	if variation == "default":
		variation = ""

	var chartPath = Paths.json("songs/" + song + "/" + song + difficulty)
	if ResourceLoader.exists(chartPath):
		var json = JSON.parse_string(FileAccess.get_file_as_string(chartPath))
		addExData(json.song, variation)
		return json.song
	else:
		print("FUCK GUH UHHH NO CHART FUCKING FOUND!!!!!!! (" + chartPath + ") returning Test song instead! sorry bro")
		return getSong("test", "hard")

# add shitty stuffs to json
static func addExData(data, variation):
	if !data.has("variation"):
		data.variation = variation
	if !data.has("stage"):
		data.stage = "Stage"

static func normalizeDiff(diff:String):
	if diff == "normal" || diff == "erect":
		return ""
	else: return "-" + diff
		
static func getAudio(songData):
	var list = {
		"instrumental": Paths.audio(songData.song + "/Inst", "songs/"), # Instrumental is required anyway
		"player": null,
		"opponent": null
	}
	
	var inst = Paths.audio(songData.song + "/Inst-" + songData.variation, "songs/")
	if ResourceLoader.exists(inst):
		list["instrumental"] = inst

	var plrVox = Paths.audio(songData.song + "/Voices-" + songData.player1, "songs/")
	if ResourceLoader.exists(plrVox):
		list["player"] = plrVox
	elif ResourceLoader.exists(Paths.audio(songData.song + "/Voices", "songs/")): # Classic Vocals
		list["player"] = Paths.audio(songData.song + "/Voices", "song/s")

	var oppVox = Paths.audio(songData.song + "/Voices-" + songData.player2, "songs/")
	if ResourceLoader.exists(oppVox):
		list["opponent"] = oppVox
	
	return list
