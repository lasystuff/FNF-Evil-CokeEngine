extends AnimatedSprite2D

@export var id:int = 0
var colors:Array = ["purple", "blue", "green", "red"]

func start():
	self.offset.y = 0
	self.visible = true
	self.stop()
	play("sustain cover pre", 0.5)

func _process(delta: float) -> void:
	if  !animation.contains("end"):
		play("sustain cover " + colors[id])

func end():
	self.stop()
	self.offset.y += 15
	play("sustain cover end " + colors[id])

func _on_animation_finished() -> void:
	if animation.contains("end"):
		self.visible = false
