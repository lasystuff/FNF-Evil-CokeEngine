extends Node

var soundPlayer
var musicPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	soundPlayer = AudioStreamPlayer.new()
	soundPlayer.finished.connect(func():
		soundPlayer.stream = null
	)
	musicPlayer = AudioStreamPlayer.new()
	musicPlayer.finished.connect(func():
		# loop
		if musicPlayer.stream != null:
			musicPlayer.play()
	)
	
	$/root.add_child.call_deferred(soundPlayer)
	$/root.add_child.call_deferred(musicPlayer)

func playSound(path):
	stopSound()
	soundPlayer.stream = load(Paths.audio(path, "sounds/"))
	soundPlayer.play()

func playMusic(path):
	stopMusic()
	musicPlayer.stream = load(Paths.audio(path, "sounds/"))
	musicPlayer.play()
	
func stopSound():
	soundPlayer.stop()

func stopMusic():
	musicPlayer.stop()
