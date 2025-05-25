extends Node2D

var curVolume:int = 10

@onready var basePos = Vector2(position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var remappedVolume = int(remap(AudioServer.get_bus_volume_db(0), -80, 0, 0, 10))
	if Input.is_action_just_pressed("volume_up"):
		remappedVolume += 1
	elif Input.is_action_just_pressed("volume_down"):
		remappedVolume -= 1
	if remappedVolume > 10:
		remappedVolume = 10
	elif remappedVolume < 0:
		remappedVolume = 0
	if curVolume != remappedVolume:
		displayTray()
		if remappedVolume == 10:
			GlobalSound.playSound("soundtray/volMax")
		elif curVolume > remappedVolume:
			GlobalSound.playSound("soundtray/volUp")
		elif curVolume < remappedVolume:
			GlobalSound.playSound("soundtray/volUp")
		curVolume = remappedVolume
		if curVolume != 0:
			$bars.visible = true
			$bars.texture = load("res://assets/images/ui/soundtray/bars_" + str(curVolume) + ".png")
		else:
			$bars.visible = false
		AudioServer.set_bus_volume_db(0, remap(curVolume, 0, 10, -80, 0))
		SaveData.data._volume = curVolume


func displayTray():
	$hideTimer.stop()
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(basePos.x, basePos.y + 110), 1)
	$hideTimer.start()

func _on_hide_timer_timeout() -> void:
	var tweenEnd = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tweenEnd.tween_property(self, "position", basePos, 0.5)
