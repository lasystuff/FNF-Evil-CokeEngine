extends Parallax2D
class_name FNFSprite2D

var _sprite:Sprite2D = Sprite2D.new()

func _init(tex:String, pos:Vector2 = Vector2(), scr:Vector2 = Vector2(1, 1)) -> void:
	self.scroll_scale = scr
	_sprite.texture = load(Paths.image(tex))
	_sprite.position = pos
	_sprite.material = CanvasItemMaterial.new()

func _ready() -> void:
	self.add_child(_sprite)

const blends = {
	"mix": 0,
	"add": 1,
	"subtract": 2,
	"multiply": 3
}
func set_blend(blend:String):
	print(blends[blend.to_lower()])
	_sprite.material.blend_mode = blends[blend.to_lower()]

func set_alpha(value:float):
	_sprite.modulate.a = value
