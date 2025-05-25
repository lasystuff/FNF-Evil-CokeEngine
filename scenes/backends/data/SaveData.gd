class_name SaveData

const defaultData = {
	"downscroll": false,
	"middlescroll": false,
	"ghostTap": true,
	"autoPause": true,
	
	"vsync": 0, # Disabled, Enabled, Addaptive
	"flashing": true,
	"debugCounterType": 1 # Disabled, Full, Simple
}
static var data = {}

static func load():
	data = defaultData.duplicate(true)

	if FileAccess.file_exists("user://config.save"):
		var savedData = str_to_var(FileAccess.get_file_as_string("user://config.save"))
		for key in savedData.keys():
			data[key] = savedData[key]

static func save():
	var f = FileAccess.open("user://config.save", FileAccess.WRITE)
	f.store_string(var_to_str(data))
	f.close()
