extends FNFScene2D

var menuItems:Dictionary = {
	"storymode": load("res://scenes/PlayScene.tscn"),
	"freeplay": null,
	"credits": null,
	"options": preload("res://scenes/menu/OptionMenu.tscn")
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# GlobalSound.playMusic("freakyMenu")
	var index:int = 0
	for item in menuItems.keys():
		var sprite = AnimatedSprite2D.new()
		sprite.global_position = Vector2(0, 150*index)
		sprite.sprite_frames = load("res://assets/images/menu/mainmenu/" + item + ".xml")
		sprite.play(item + " idle")
		$items.add_child(sprite)
		index += 1

	$Camera2D.global_position = $items.get_children()[0].global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
