extends FNFScene2D
class_name OptionMenu

static var backToGame:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$tab.current_tab = 0
	
	for tab in [$tab/Gameplay, $tab/Appearance, $tab/Controls, $tab/Misc]:
		for child in tab.get_children():
			match child.get_class():
				"CheckBox":
					child.button_pressed = SaveData.data[child.name]
					child.toggled.connect(func(t): setValue(child.name, t))
				"Label":
					var optionChild = child.get_node_or_null(child.name + "Option")
					if optionChild != null:
						match optionChild.get_class():
							"OptionButton":
								optionChild.selected = SaveData.data[child.name]
								optionChild.item_selected.connect(func(index): setValue(child.name, index))

func setValue(key:String, value):
	if SaveData.data.has(key):
		SaveData.data[key] = value
