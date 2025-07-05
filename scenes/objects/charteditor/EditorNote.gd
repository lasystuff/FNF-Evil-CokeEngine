extends AnimatedSprite2D

func set_data(data:Dictionary):
	match data.noteData:
		0:
			$sustainRect.color = Color8(321, 61, 76)
			play("purple")
		1:
			$sustainRect.color = Color8(180, 99, 100)
			play("blue")
		2:
			$sustainRect.color = Color8(116, 98, 98)
			play("green")
		3:
			$sustainRect.color = Color8(358, 77, 98)
			play("red")
	if data.sustainLength >= 0:
		$sustainRect.visible = true
		$sustainRect.size.y = 80 + (160 * data.sustainLength)
	else:
		$sustainRect.visible = false
