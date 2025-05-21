extends Node
class_name LuaModule

var lua:LuaState = null
var scriptPath = ""

func _init(path:String) -> void:
	scriptPath = "res://assets/scripts/" + path + ".lua"
	if FileAccess.file_exists(scriptPath):
		_initLua()
	else:
		print("Failed to Load Script File from: " + scriptPath)

# Initalize LuaState and adding Variables and uhh idk!
func _initLua():
	lua = LuaState.new()
	lua.open_libraries()

	lua.globals["print"] = func(t): print(t)
	lua.globals["makeCallable"] = func(f):
		if (lua.globals.to_dictionary().has(f)):
			return lua.globals[f].to_callable()

func do():
	var result = lua.do_file(scriptPath)
	if result is LuaError:
		printerr("Error in Lua code: ", result)

func callLua(function:String, args:Array = []):
	if (lua != null && lua.globals.to_dictionary().has(function)):
		lua.globals[function].to_callable().callv(args)
