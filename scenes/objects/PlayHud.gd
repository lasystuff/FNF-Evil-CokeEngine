extends CanvasLayer

var game
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

var iconBopScale = 1.2
func beatHit(beat:int):
	if beat % 2 == 0:
		$iconP1.scale = Vector2(iconBopScale, iconBopScale)
		$iconP2.scale = Vector2(iconBopScale, iconBopScale)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$healthBar.value = game.health
	$iconP1.position.x = $healthBar.position.x/2 + (580 * remap($healthBar.value, 0, 2, 100, 0) * 0.01 + 220)
	$iconP2.position.x = $healthBar.position.x/2 + (580 * remap($healthBar.value, 0, 2, 100, 0) * 0.01 + 140)
	
	$iconP1.scale.x = lerpf($iconP1.scale.x, 1, 0.1)
	$iconP1.scale.y = $iconP1.scale.x
	$iconP2.scale.x = lerpf($iconP2.scale.x, 1, 0.1)
	$iconP2.scale.y = $iconP2.scale.x
