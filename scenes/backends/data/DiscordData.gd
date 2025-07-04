extends Node
class_name DiscordData

# Called when the node enters the scene tree for the first time.
static func init():
	DiscordRPC.app_id = 1390813721634406533 # Application ID
	DiscordRPC.details = "Most Evil FNF Engine"
	DiscordRPC.state = "In the Menus"
	
	DiscordRPC.refresh()

static func set_rpc(state:String):
	DiscordRPC.state = state
	DiscordRPC.refresh()
