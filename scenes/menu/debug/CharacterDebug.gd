extends FNFScene2D
class_name CharacterDebug

static var characterName = "dad"
static var player = false

var zoomLerp = 1

var curAnimIndex:int = 0:
	set(value):
		curAnimIndex = value
		if curAnimIndex < 0:
			curAnimIndex = character.data.animations.size() - 1
		elif curAnimIndex > character.data.animations.size() - 1:
			curAnimIndex = 0
var ghost;
var character;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ghost = FNFCharacter2D.new(characterName)
	add_child(ghost)
	ghost.self_modulate = Color(0, 0, 0, 0.5)
	
	character = FNFCharacter2D.new(characterName)
	add_child(character)
	
	ghost.playAnim("idle")
	character.playAnim(character.data.animations[0].name)
	
	if player:
		ghost.flip_h = !ghost.flip_h
		character.flip_h = !character.flip_h
	
func _process(delta: float) -> void:
	$Camera2D.zoom.x = lerpf($Camera2D.zoom.x, zoomLerp, 0.02)
	$Camera2D.zoom.y = $Camera2D.zoom.x
	
	$Camera2D.global_position = character.global_position
	var value = 1
	if Input.is_key_pressed(KEY_SHIFT):
		value = 10
	if Input.is_action_just_pressed("ui_left"):
		addAnimOffset(Vector2(-value, 0))
	if Input.is_action_just_pressed("ui_down"):
		addAnimOffset(Vector2(0, value))
	if Input.is_action_just_pressed("ui_up"):
		addAnimOffset(Vector2(0, -value))
	if Input.is_action_just_pressed("ui_right"):
		addAnimOffset(Vector2(value, 0))
		
	if Input.is_action_just_pressed("ui_accept"):
		character.playAnim(character.data.animations[curAnimIndex].name, true)
	if Input.is_action_just_pressed("ui_text_clear_carets_and_selection"):
		Main.nextTransIn = "quickIn"
		Main.switch_scene(load("res://scenes/PlayScene.tscn"))

	$overlay/debugText.text = ""
	for anim in character.data.animations:
		if character.curAnim == anim.name:
			$overlay/debugText.text += ">"
		$overlay/debugText.text += anim.name + "  offsets: " + "[" + str(anim.offset.x) + "," +  str(anim.offset.y) + "]\n"

func addAnimOffset(offset:Vector2):
	character.getAnimData(character.curAnim).offset += offset
	ghost.getAnimData(character.curAnim).offset += offset
	
	character.offset = character.getAnimData(character.curAnim).offset
	ghost.offset = ghost.getAnimData(ghost.curAnim).offset

# budddd
func _input(event):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_W) and just_pressed:
		curAnimIndex -= 1
		character.playAnim(character.data.animations[curAnimIndex].name)
	if Input.is_key_pressed(KEY_S) and just_pressed:
		curAnimIndex += 1
		character.playAnim(character.data.animations[curAnimIndex].name)
	
	if Input.is_key_pressed(KEY_E) and just_pressed:
		zoomLerp += 0.1
	if Input.is_key_pressed(KEY_Q) and just_pressed:
		zoomLerp -= 0.1
