@tool
extends Node2D
class_name FNFSprite2D
# FNFSprite2D is actually its Node2D not Sprite2D but it has scrollfactor and so good lol

var _parallax:Parallax2D = Parallax2D.new()
var _sprite:Sprite2D = Sprite2D.new()

@export var texture:Texture2D:
	set(value):
		texture = value
		if Engine.is_editor_hint():
			queue_redraw()
@export_custom(PROPERTY_HINT_LINK, "suffix:") var scroll_scale:Vector2 = Vector2(1, 1)

func _init(tex:String = "", pos:Vector2 = Vector2(), scr:Vector2 = Vector2(1, 1)) -> void:
	if !Engine.is_editor_hint():
		_parallax.scroll_scale = scr

		if pos != Vector2():
			self.global_position = pos

		if tex != "":
			_sprite.texture = load(Paths.image(tex))
		if pos != Vector2():
			self.global_position = pos
		_sprite.material = CanvasItemMaterial.new()

func _ready() -> void:
	if !Engine.is_editor_hint():
		add_child(_parallax)
		_parallax.add_child(_sprite)
		if self.texture != null:
			_sprite.texture = self.texture
		if _parallax.scroll_scale == Vector2(1, 1):
			_parallax.scroll_scale = self.scroll_scale
		# make accurate to editor-side idk
		

func _draw():
	if Engine.is_editor_hint():
		if self.texture != null:
			draw_texture(texture, Vector2(self.global_position.x - (texture.get_width() / 2), self.global_position.x - (texture.get_height() / 2)))

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
