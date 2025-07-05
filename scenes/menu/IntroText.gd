extends FNFScene2D

# big ass hardcoded shits
const intro_texts:Array = [
["shoutouts to tom fulp", "lmao"],
["Ludum dare", "extraordinaire"],
["cyberzone", "coming soon"],
["love to thriftman", "swag"],
["ultimate rhythm gaming", "probably"],
["dope ass game", "playstation magazine"],
["in loving memory of", "henryeyes"],
["dancin", "forever"],
["funkin", "forever"],
["ritz dx", "rest in peace lol"],
["rate five", "pls no blam"],
["rhythm gaming", "ultimate"],
["game of the year", "forever"],
["you already know", "we really out here"],
["rise and grind", "love to luis"],
["like parappa", "but cooler"],
["album of the year", "chuckie finster"],
["better than geometry dash", "fight me robtop"],
["kiddbrute for president", "vote now"],
["play dead estate", "on newgrounds"],
["this is a god damn prototype", "we workin on it okay"],
["women are real", "this is official"],
["too over exposed", "newgrounds cant handle us"],
["Hatsune Miku", "biggest inspiration"],
["too many people", "my head hurts"],
["newgrounds", "forever"],
["refined taste in music", "if i say so myself"],
["his name isnt keith", "dumb eggy lol"],
["his name isnt evan", "silly tiktok"],
["stream chuckie finster", "on spotify"],
["never forget to", "pray to god"],
["dont play rust", "we only funkin"],
["good bye", "my penis"],
["dababy", "biggest inspiration"],
["fashionably late", "but here it is"],
["yooooooooooo", "yooooooooo"],
["pico funny", "pico funny"],
["updates each friday", "on time every time"],
["shoutouts to mason", "for da homies"],
["bonk", "get in the discord call"],
["carpal tunnel", "game design"],
["downscroll", "i dont know what that is"],
["warning", "choking hazard"],
["devin chat", "what an honorable man"],
["kickstarter exclusive", "intro text"],
["cussing", "we have it"],
["parental advisory", "explicit content"],
["pico says", "trans rights"],
["album of the year", "damage control"],
["proudly made", "via newgrounds pms"],
["nicotine induced", "game development"],
["free crackheads", "with love to figburn"],
["press square", "to open your popit menu"],
["jojo sez", "shoooooooom"],
["updates each pico day", "on time every time"],
["macromedia software", "legally obtained"],
["under judgement", "proud resident"],
["make tom proud", "weekly second"],
["to enable pen pressure", "disable windows ink"]
]

var current_intro:Array
var controllable:bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	current_intro = intro_texts[rng.randi_range(0, intro_texts.size() - 1)]
	if !GlobalSound.music_player.playing:
		GlobalSound.play_music("freakyMenu")
	conductor.bpm = 102


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var instTime = GlobalSound.music_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	conductor.song_position = (instTime * 1000.0)
	
	if Input.is_action_just_pressed("ui_accept") && controllable:
		go_to_title()
	
func go_to_title():
	controllable = false
	Main.nextTransIn = "quickIn"
	Main.nextTransOut = "quickOut"
	Main.switch_scene(load("res://scenes/menu/TitleScreen.tscn"))

func beat_hit(beat):
	match beat:
		1:
			add_text("The", -70)
			add_text("Funkin Crew Inc")
		3:
			add_text("Presents", 70)
		4:
			clear_text()
		5:
			add_text("In association", -140)
			add_text("With", -70)
		7:
			add_sprite(preload("res://assets/images/menu/title/newgrounds_logo.png"), 140)
		8:
			clear_text()
		9:
			add_text(current_intro[0], -70)
		11:
			add_text(current_intro[1])
		12:
			clear_text()
		13:
			add_text("Friday", -70)
		14:
			add_text("Night")
		15:
			add_text("Funkin", 70)
		16:
			go_to_title()

func add_text(text:String, y_add:float = 0):
	var lab = SparrowLabel.new()
	lab.frames = preload("res://assets/images/ui/fonts/bold.xml")
	lab.text = text.to_upper()
	$texts.add_child(lab)
	lab.position.y += y_add
	lab.position.x -= (lab.texture_width*text.length())/2
	
func add_sprite(texture:Texture2D, y_add:float = 0):
	var sprite = Sprite2D.new()
	sprite.texture = texture
	$texts.add_child(sprite)
	sprite.position.y += y_add

func clear_text():
	for l in $texts.get_children():
		l.queue_free()
