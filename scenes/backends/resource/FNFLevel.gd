extends Resource
class_name FNFLevel

@export_category("Display")
@export var title:String = "Your own week"
@export var texture:Texture2D
@export var opponent_prop:SpriteFrames = preload("res://assets/images/menu/storymode/props/dad.xml")
@export var player_prop:SpriteFrames = preload("res://assets/images/menu/storymode/props/bf.xml")
@export var dj_prop:SpriteFrames = preload("res://assets/images/menu/storymode/props/gf.xml")

@export_category("Data")
@export var songs:Array[FNFSong] = []
@export var difficulties:Array[String] = ["easy", "normal", "hard"]

# internal
var lua_script:LuaModule
var display_songs:Array[String] = []
var level_name:String = ""

func setup(name:String) -> void:
	level_name = name
	for d in songs:
		display_songs.push_back(d.id)

	if Paths.exists("scripts/levels/" + name + ".lua"):
		lua_script = LuaModule.new("levels/" + name)
		lua_script.lua.globals["level"] = self
		lua_script.do()
