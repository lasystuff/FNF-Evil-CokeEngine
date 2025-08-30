extends Node2D
class_name FNFStage2D

@export var zoom:float = 1
@export var camera_speed:float = 1.9
@export var hide_gf:bool = false

@export var playerCameraOffset:Vector2 = Vector2()
@export var opponentCameraOffset:Vector2 = Vector2()

var judgeSpawner:Node2D

func _init() -> void:
	PlayScene.instance.conductor.step_hit.connect(step_hit)
	PlayScene.instance.conductor.beat_hit.connect(beat_hit)

func init_characters():
	$djPos.visible = false
	$playerPos.visible = false
	$opponentPos.visible = false
	
	PlayScene.instance.dj.position += $djPos.global_position
	PlayScene.instance.player.position += $playerPos.global_position
	PlayScene.instance.opponent.position += $opponentPos.global_position

# some callbacks
func step_hit(beat):pass
func beat_hit(beat):pass
func event_called(event, data):pass
