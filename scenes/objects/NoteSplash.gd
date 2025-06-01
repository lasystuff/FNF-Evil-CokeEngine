extends AnimatedSprite2D

func start(note:Note):
	self.sprite_frames = load(Paths.xml("ui/" + note.splash))
	offset = Vector2(-38, -47)

	var random = RandomNumberGenerator.new().randi_range(1, 2)
	match note.noteData:
		0:
			play("note splash purple " + str(random))
		1:
			play("note splash blue " + str(random))
		2:
			play("note splash green " + str(random))
		3:
			play("note splash red " + str(random))
	var sprTween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	sprTween.finished.connect(func(): self.queue_free())
	sprTween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
