extends AnimatedSprite2D
class_name FNFCharacter2D

var data = CharacterData.defaultData
var characterName:String = ""

var cameraPosition = Vector2()
var icon = "bf"

var singDuration:float = 4

var curAnim:String = ""
var holdTimer:float = 0
var singing:bool = false
var interruptible:bool = true

var is_animate:bool = false
var animate_anim_data:Dictionary
var animate_sprite:AnimateSymbol

func _init(character:String):
	data = CharacterData.getCharacter(character)
	characterName = data.id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animate_path = Paths.getPath("images/" + data.texture + "/Animation.json")
	if (ResourceLoader.exists(animate_path)):
		var folder = Paths.getPath("images/" + data.texture)
		if animate_path.contains("_sandbox"): # ugly ass patch
			folder = "assets/_sandbox/images/" + data.texture
			
		animate_sprite = AnimateSymbol.new()
		animate_sprite.atlas = folder
		add_child(animate_sprite)
	
		var tex = FileAccess.get_file_as_string(animate_path)
		var json = JSON.parse_string(tex)
		animate_anim_data = CokeUtil.parse_animate_timeline(json)
		is_animate = true
	else:
		sprite_frames = load(Paths.xml(data.texture))

	position = data.position
	cameraPosition = data.cameraPosition
	scale = Vector2(data.scale, data.scale)
	icon = data.icon
	if !data.antialiasing:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	flip_h = data.flipHorizon
	singDuration = data.singDuration
	
	self.frame_changed.connect(onFrameChange)
	self.animation_finished.connect(onAnimationFinish)
	
	if is_animate:
		animate_sprite.frame_changed.connect(onFrameChange)

func playAnim(name:String, force:bool = false):
	var anim = getAnimData(name)
	if anim == null:
		print("Animation not Found: " + name)
		return
		
	if force:
		stop()

	curAnim = name
	curFrameIndex = 0
	var thing = float(anim.fps) / 24
	if is_animate:
		animate_sprite.playing = true
		animate_sprite.frame = animate_anim_data.get(anim.prefix)[0]
	else:
		play(anim.prefix, thing)
	self.offset = Vector2(anim.offset.x, anim.offset.y)

	if (anim.name.begins_with("sing") && interruptible):
		holdTimer = 0
		singing = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (singing):
		holdTimer += delta

		var singTimeSec:float = (Main.scene.conductor.step_crotchet*0.0011) * singDuration
		if (holdTimer > singTimeSec):
			singing = false
			holdTimer = 0

func getAnimData(name:String):
	for entry in data.animations:
		if entry.name == name:
			return entry
	return null

var curIdle:int = 0
func idle():
	if !singing:
		if curIdle > data.idleAnimations.size() - 1:
			curIdle = 0
		playAnim(data.idleAnimations[curIdle])
		curIdle += 1


var curFrameIndex = 0
var autoChanged:bool = false
func onFrameChange():
	if autoChanged:
		return
	var data = getAnimData(curAnim)
	
	if is_animate:
		if animate_sprite.frame > animate_anim_data.get(data.prefix)[1]:
			animate_sprite.frame = animate_anim_data.get(data.prefix)[1]
			onAnimationFinish()
	else:
		if data.indices.size() > 0:
			curFrameIndex += 1
			if curFrameIndex >= data.indices.size() - 1:
				curFrameIndex = data.indices.size() - 1

			autoChanged = true
			frame = data.indices[curFrameIndex]
			autoChanged = false

func onAnimationFinish():
	var data = getAnimData(curAnim)
	if data.loop:
		playAnim(curAnim)
	elif is_animate:
		animate_sprite.playing = false
