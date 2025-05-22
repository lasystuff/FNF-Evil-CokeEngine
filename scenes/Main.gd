extends Node2D

const defaultTransIn = "gradkIn"
const defaultTransOut = "gradOut"

var nextTransIn = "quickIn"
var nextTransOut = "gradOut"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switchScene(load("res://scenes/PlayScene.tscn"))

var oldMem = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$DebugDisplay/label.text = "FPS: " + str(Engine.get_frames_per_second())
	if Engine.get_frames_per_second() < 30:
		$DebugDisplay/label.text = '[color="red"]' + $DebugDisplay/label.text + '[/color]'
	
	var memoryUsing = OS.get_static_memory_usage() / (1024 * 1024)
	if memoryUsing != oldMem:
		oldMem = memoryUsing
	var thing = "Memory: " + str(memoryUsing) +  " MB"
	if memoryUsing > 800:
		thing = '[color="red"]' + thing + '[/color]'
	$DebugDisplay/label.text += "\n" + thing + '[color="gray"] / ' + str(oldMem) + ' MB[/color]'
	$DebugDisplay/label.text += '\n[color="red"]Evil[/color] Coke Engine Indev'
	
	$DebugDisplay/labelExtra.text = "Total Object: " + str(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	$DebugDisplay/labelExtra.text += "\nTotal Draw Calls (in Frame): " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	$DebugDisplay/labelExtra.text += "\n\nAudio Output Latency: " + str(AudioServer.get_output_latency() * 1000.0)

var nextState
func switchScene(scene):
	nextState = scene.instantiate()
	$Transition/animation.play(nextTransIn)

func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == nextTransIn:
		if $SceneLoader.get_children().size() > 0:
			$SceneLoader.get_child(0).queue_free()
		$SceneLoader.add_child(nextState)
		$Transition/animation.play(nextTransOut)
		
		nextTransIn = defaultTransIn
		nextTransOut = defaultTransOut
