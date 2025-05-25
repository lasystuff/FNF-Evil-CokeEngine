extends Node2D
class_name Main

static var defaultTransIn = "gradIn"
static var defaultTransOut = "gradOut"

static var nextTransIn = "quickIn"
static var nextTransOut = "gradOut"

static var instance

static func switchScene(scene):
	if instance != null:
		instance._switchScene(scene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	_switchScene(load("res://scenes/PlayScene.tscn"))

var oldMem = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$overlay/debugText.text = "FPS: " + str(Engine.get_frames_per_second())
	if Engine.get_frames_per_second() < 30:
		$overlay/debugText.text = '[color="red"]' + $overlay/debugText.text + '[/color]'
	
	var memoryUsing = OS.get_static_memory_usage() / (1024 * 1024)
	if memoryUsing != oldMem:
		oldMem = memoryUsing
	var thing = "Memory: " + str(memoryUsing) +  " MB"
	if memoryUsing > 800:
		thing = '[color="red"]' + thing + '[/color]'
	$overlay/debugText.text += "\n" + thing + '[color="gray"] / ' + str(oldMem) + ' MB[/color]'
	$overlay/debugText.text += '\n[color="red"]Evil[/color] Coke Engine Indev'
	
	$overlay/debugTextExtra.text = "Total Object: " + str(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	$overlay/debugTextExtra.text += "\nTotal Draw Calls (in Frame): " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	$overlay/debugTextExtra.text += "\n\nAudio Output Latency: " + str(AudioServer.get_output_latency() * 1000.0)
	
	# RELOADING SHIT
	if Input.is_action_just_pressed("hotreload"):
		nextTransIn = "quickIn"
		_switchScene(nextState)

var nextState
func _switchScene(scene):
	if scene != nextState:
		nextState = scene
	$Transition/animation.play(nextTransIn)

func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == nextTransIn:
		if $SceneLoader.get_children().size() > 0:
			$SceneLoader.get_child(0).queue_free()
		$SceneLoader.add_child(nextState.instantiate())
		$Transition/animation.play(nextTransOut)
		
		nextTransIn = defaultTransIn
		nextTransOut = defaultTransOut
