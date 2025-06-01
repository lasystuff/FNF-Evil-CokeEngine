class_name Paths

static func getPath(path:String):
	if ResourceLoader.exists("res://assets/_sandbox/" + path):
		return "res://assets/_sandbox/" + path
	return "res://assets/" + path

static func image(path:String):
	return getPath("images/" + path + ".png")

static func xml(path:String):
	return getPath("images/" + path + ".xml")

static func lua(path:String):
	return getPath("scripts/" + path + ".lua")
	
static func audio(path:String, folder:String = "music/"):
	return getPath(folder + "/" + path + ".ogg")

static func json(path:String):
	return getPath("data/" + path + ".json")

static func list(path:String):
	var finalArray = []
	for folder in ["res://assets/", "res://assets/_sandbox/"]:
		if !DirAccess.dir_exists_absolute(folder + path):
			continue
		var files = DirAccess.get_files_at(folder + path)
		for file in files:
			if !finalArray.has(file):
				finalArray.push_back(file)
	return finalArray
