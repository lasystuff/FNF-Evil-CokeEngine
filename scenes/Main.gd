extends Node2D
class_name Main

const initalScene = preload("res://scenes/menu/MainMenu.tscn")

static var defaultTransIn = "gradIn"
static var defaultTransOut = "gradOut"

static var nextTransIn = "quickIn"
static var nextTransOut = "gradOut"

static var scene:
	get():
		return instance.get_node("SceneLoader").get_child(0)

static var instance

static func switch_scene(scene):
	if instance != null:
		instance._switch_scene(scene)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	SaveData.load()

	$overlay/Soundtray.curVolume = SaveData.data._volume
	AudioServer.set_bus_volume_db(0, remap(SaveData.data._volume, 0, 10, -80, 0))
	match SaveData.data.vsync:
		_:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	
	_switch_scene(initalScene)
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveData.save()

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
		_switch_scene(nextState)
		
	match SaveData.data.debugCounterType:
		0:
			$overlay/debugText.visible = false
			$overlay/debugTextExtra.visible = false
		1:
			$overlay/debugText.visible = true
			$overlay/debugTextExtra.visible = true
		2:
			$overlay/debugText.visible = true
			$overlay/debugTextExtra.visible = false

var nextState
func _switch_scene(scene):
	if scene != nextState:
		nextState = scene
	$Transition/animation.play(nextTransIn)
	
func _open_subscene(scene):
	Main.instance.get_node("SubSceneLoader").add_child(load("res://scenes/PauseScreen.tscn").instantiate())
	self.process_mode = Node.PROCESS_MODE_DISABLED

func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == nextTransIn:
		if $SceneLoader.get_children().size() > 0:
			$SceneLoader.get_child(0).queue_free()
		if $SubSceneLoader.get_children().size() > 0:
			$SubSceneLoader.get_child(0).queue_free()
		$SceneLoader.add_child(nextState.instantiate())
		$Transition/animation.play(nextTransOut)
		
		nextTransIn = defaultTransIn
		nextTransOut = defaultTransOut
