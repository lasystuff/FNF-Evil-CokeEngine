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
	"singDuration": 4
}

static func getCharacter(char:String):
	var data = defaultData.duplicate(true)
	var characterPath = Paths.lua("characters/" + char)
	if !ResourceLoader.exists(characterPath):
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
			for entry in luaScript.lua.globals["animations"].to_array():
				var thing = entry.to_dictionary()
				thing.indices = thing.indices.to_array()
				data["animations"].push_back(thing)
		elif key == "idleAnimations":
			if typeof(luaScript.lua.globals["idleAnimations"]) != TYPE_ARRAY:
				data["idleAnimations"] = luaScript.lua.globals["idleAnimations"].to_array()
		elif key != "id":
			data[key] = luaScript.lua.globals[key]
	
	return data

static func listCharacter() -> Array:
	var finalArray = []
	var files = Paths.list("scripts/characters/")
	for file in files:
		if file.ends_with(".lua"):
			finalArray.push_back(file.split(".lua")[0])
	return finalArray
