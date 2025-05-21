extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SceneLoader.add_child(load("res://scenes/PlayScene.tscn").instantiate())

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
