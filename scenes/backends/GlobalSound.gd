extends Node

var sound_player:AudioStreamPlayer
var music_player:AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound_player = AudioStreamPlayer.new()
	sound_player.finished.connect(func():
		sound_player.stream = null
	)
	music_player = AudioStreamPlayer.new()
	music_player.finished.connect(func():
		# loop
		if music_player.stream != null:
			music_player.play()
	)
	
	$/root.add_child.call_deferred(sound_player)
	$/root.add_child.call_deferred(music_player)

func play_sound(path):
	stop_sound()
	sound_player.stream = load(Paths.audio(path, "sounds/"))
	sound_player.play()

func play_sound_raw(data):
	stop_sound()
	sound_player.stream = data
	sound_player.play()

func play_music(path):
	stop_music()
	music_player.stream = load(Paths.audio(path, "music/"))
	music_player.play()
	
func play_music_raw(data):
	stop_music()
	music_player.stream = data
	music_player.play()
	
func stop_sound():
	sound_player.stop()

func stop_music():
	music_player.stop()
