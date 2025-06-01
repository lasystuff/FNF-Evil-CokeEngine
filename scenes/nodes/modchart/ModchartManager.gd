extends Node
class_name ModchartManager

var modifiers:Dictionary = {
	"drunk": DrunkModifier.new(),
	"boost": AccelModifier.new()
}

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	for mod in modifiers.values():
		mod._process(delta)

func set_percent(mod:String, value:float, player:int = -1):
	if modifiers.has(mod):
		modifiers[mod].set_percent(value/100, player)
		
func set_submod_percent(mod:String, submod:String, value:float, player:int):
	if modifiers.has(mod):
		if modifiers[mod].submods.has(submod):
			modifiers[mod].submods[submod].set_percent(value/100, player)

func updateNote(note:Note, player:int = 0):
	for mod in modifiers.values():
		mod.note_process(note, player)

func updateStrum(strumline, strumId, player:int = 0):
	for mod in modifiers.values():
		mod.strum_process(strumline, strumId, player)

# Utils (from Andromeda Engine)
static func scale(x:float,l1:float,h1:float,l2:float,h2:float):
	return ((x - l1) * (h2 - l2) / (h1 - l1) + l2)
