extends Node

func format_money(Amount:float, EnglishStyle:bool = true):
		var isNegative = Amount < 0;
		Amount = abs(Amount);

		var string:String = "";
		var comma:String = "";
		var amount:float = floor(Amount);
		while (amount > 0):
			if (string.length() > 0 && comma.length() <= 0):
				if EnglishStyle:
					comma = ","
				else:
					comma = "."

			var zeroes = "";
			var helper = amount - floor(amount / 1000) * 1000;
			amount = floor(amount / 1000);
			if (amount > 0):
				if (helper < 100):
					zeroes += "0";
				if (helper < 10):
					zeroes += "0";
			string = zeroes + str(int(helper)) + comma + string;

		if (string == ""):
			string = "0"

		if (isNegative):
			string = "-" + string;
		return string;

# recreation of FlxFlicker
func flicker(object:Node2D, duration = 1, interval = 0.04, endVisibility:bool = true, forceRestart:bool = true, callback:Callable = func(): pass):
	if endVisibility:
		for i in (duration/interval):
			object.visible = false
			await get_tree().create_timer(interval/2).timeout
			object.visible = true
			await get_tree().create_timer(interval/2).timeout
	else:
		for i in (duration/interval):
			object.visible = true
			await get_tree().create_timer(interval/2).timeout
			object.visible = false
			await get_tree().create_timer(interval/2).timeout
			
	callback.call()

var mouse_mode = Input.MOUSE_MODE_VISIBLE
func set_mouse_visibility(b:bool):
	if b:
		mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	Input.set_mouse_mode(mouse_mode)
