extends Node
class_name RatingData

const judgements:Dictionary = {
	"epic": {"scoreMult": 1.2, "accuaracyMult": 1}, # epic has score bonus but not affect to accuracy
	"sick": {"scoreMult": 1, "accuaracyMult": 1},
	"good": {"scoreMult": 0.8, "accuaracyMult": 0.95},
	"bad": {"scoreMult": 0.5, "accuaracyMult": 0.75},
	"shit": {"scoreMult": 0.2, "accuaracyMult": 0.6}
}

static func getRatingName(diff:float):
	if diff < 15:
		return "epic"
	if diff < 40:
		return "sick"
	elif diff < 70:
		return "good"
	elif diff < 90:
		return "bad"

	return "shit"
