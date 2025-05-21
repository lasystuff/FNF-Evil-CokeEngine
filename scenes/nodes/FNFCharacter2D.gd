extends AnimatedSprite2D
class_name FNFCharacter2D

var data = CharacterData.defaultData
var characterName:String = ""

var cameraPosition = Vector2()
var icon = "bf"
var healthColor = Color(255, 0, 0)

var singDuration:float = 4

var holdTimer:float = 0
var singing:bool = false
var interruptible:bool = true

func _init(character:String):
	data = CharacterData.getCharacter(character)
	characterName = data.id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_frames = load("res://assets/images/" + data.texture + ".xml")
	position = data.position
	cameraPosition = data.cameraPosition
	scale = Vector2(data.scale, data.scale)
	icon = data.icon
	if !data.antialiasing:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flip_h = data.flipHorizon
	singDuration = data.singDuration

func playAnim(name:String, force:bool = false):
	var anim = getAnimData(name)
	if anim == null:
		print("Animation not Found: " + name)
		return
		
	if force:
		stop()

	play(anim.prefix, anim.fps/24)
	self.offset = Vector2(anim.offset.x, anim.offset.y)

	if (anim.name.begins_with("sing") && interruptible):
		holdTimer = 0
		singing = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (singing):
		holdTimer += delta

		var singTimeSec:float = (Conductor.stepCrotchet*0.0011) * singDuration
		if (holdTimer > singTimeSec):
			singing = false
			holdTimer = 0

func getAnimData(name:String):
	for entry in data.animations:
		if entry.name == name:
			return entry
	return null
