extends AnimatedSprite2D

func start(note:Note):
	if note.splash != "noteSplashes":
		self.sprite_frames = load("res://assets/images/ui/" + note.splash + ".png")

	var random = RandomNumberGenerator.new().randi_range(1, 2)
	match note.noteData:
		0:
			play("note impact " + str(random) + " purple")
		1:
			if random > 1:
				play("note impact " + str(random) + " blue")
			else:
				play("note impact 1  blue")
		2:
			play("note impact " + str(random) + " green")
		3:
			play("note impact " + str(random) + " red")
	var sprTween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sprTween.finished.connect(func(): self.queue_free())
	sprTween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
