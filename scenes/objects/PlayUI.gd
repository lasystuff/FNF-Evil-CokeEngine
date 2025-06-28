extends Node2D

var game

 # made these shits static cuz it looks cool on story mode hahahahaha
static var healthLerp:float = 1

static var scoreLerp:int = 1
static var missesLerp:int = 1

func initHud():
	$iconP1.load(game.player.icon)
	$iconP2.load(game.opponent.icon)
	if SaveData.data.downscroll:
		for obj in [$healthBar, $iconP1, $iconP2, $scoreText]:
			obj.position.y -= 570

func beatHit(beat:int):
	if beat % 2 == 0:
		$iconP1.bop()
		$iconP2.bop()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	healthLerp = lerpf(healthLerp, game.health, 0.01)
	$healthBar.value = healthLerp
	
	$iconP1.health = game.health
	$iconP2.health = game.health
	
	
	$iconP1.position.x = $healthBar.position.x/2 + (580 * remap($healthBar.value, 0, 2, 100, 0) * 0.01 + 220)
	$iconP2.position.x = $healthBar.position.x/2 + (580 * remap($healthBar.value, 0, 2, 100, 0) * 0.01 + 140)
	
	var lerpSize = 0.01
	scoreLerp = lerp(scoreLerp, int(game.score), lerpSize)
	missesLerp = lerp(missesLerp, int(game.misses), lerpSize)
	
	$scoreText.text = 'Score: ' + str(scoreLerp) + ' // Misses: ' + str(missesLerp) + ' // Accuracy: ' + str(int(game.accuracy)) + '%'
	if PlayScene.instance.get_node("hud/playerStrums").botplay:
		$scoreText.text += ' (Botplay)'
