extends Node2D
class_name FNFStage2D

@export var zoom:float = 1
@export var camera_speed:float = 1.9
@export var hide_gf:bool = false

@export var playerCameraOffset:Vector2 = Vector2()
@export var opponentCameraOffset:Vector2 = Vector2()

func _ready() -> void:
	$djPos.visible = false
	$playerPos.visible = false
	$opponentPos.visible = false
