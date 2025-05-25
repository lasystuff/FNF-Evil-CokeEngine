extends Node
class_name CharacterData
# Called when the node enters the scene tree for the first time.

const defaultData = {
	"id": "bf",
	"texture": "characters/BOYFRIEND",
	"position": Vector2(),
	"cameraPosition": Vector2(),
	"animations": [],
	"idleAnimations": ["idle"],
	"scale": 1,
	"antialiasing": true,
	"flipHorizon": true,
	
	"icon": "bf",
	"healthColor": Color(0, 255, 0),
	
	"singDuration": 4
}

static func getCharacter(char:String):
	var data = defaultData.duplicate(true)
	var characterPath = "res://assets/scripts/characters/" + char + ".lua"
	if !FileAccess.file_exists(characterPath):
		char = "bf"
	
	data.id = char
	var luaScript = LuaModule.new("characters/" + char)
	for key in data.keys():
		if key != "id":
			luaScript.lua.globals[key] = data[key]
	luaScript.do()
	# store data
	for key in data.keys():
		# okay... who made playtime cry...?????
		if key == "animations":
			data["animations"] = []
			for entry in luaScript.lua.globals["animations"].to_array():
				var thing = entry.to_dictionary()
				thing.indices = thing.indices.to_array()
				data["animations"].push_back(thing)
		elif key != "id":
			data[key] = luaScript.lua.globals[key]
	
	return data


static func listCharacter() -> Array:
	var finalArray = []
	var files = DirAccess.get_files_at("res://assets/scripts/characters/")
	for file in files:
		if file.ends_with(".lua"):
			finalArray.push_back(file.split(".lua")[0])
	return finalArray
