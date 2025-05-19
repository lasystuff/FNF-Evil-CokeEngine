extends Node
class_name LuaModule

var lua:LuaState = null

func _init(path:String) -> void:
	var loadPath = "res://assets/scripts/" + path + ".lua"
	if FileAccess.file_exists(loadPath):
		_initLua()
		lua.do_file(loadPath)
	else:
		print("Failed to Load Script File from: " + loadPath)

# Initalize LuaState and adding Variables and uhh idk!
func _initLua():
	lua = LuaState.new()
	lua.open_libraries()

	lua.globals["makeCallable"] = func(f):
		if (lua.globals.to_dictionary().has(f)):
			return lua.globals[f].to_callable()

func callLua(function:String, args:Array = []):
	if (lua != null && lua.globals.to_dictionary().has(function)):
		lua.globals[function].to_callable().callv(args)
