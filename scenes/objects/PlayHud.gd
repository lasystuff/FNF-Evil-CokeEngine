extends CanvasLayer

var game
# Called when the node enters the scene tree for the first time.
func initHud():
	$metaText.text = "-" + PlayScene.song.song + "[" + PlayScene.song.difficulty + "] -"
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
	$healthBar.value = game.health
	
	$iconP1.health = game.health
	$iconP2.health = game.health
	
	
	$iconP1.position.x = $healthBar.position.x/2 + (580 * remap($healthBar.value, 0, 2, 100, 0) * 0.01 + 220)
	$iconP2.position.x = $healthBar.position.x/2 + (580 * remap($healthBar.value, 0, 2, 100, 0) * 0.01 + 140)
	
	$scoreText.text = 'Score: ' + str(int(game.score)) + ' // Misses: ' + str(int(game.misses)) + ' // Accuracy: ' + str(int(game.accuracy)) + '%'
