package;

using StringTools;

class ChartCoverterData
{
	public static inline function parseStage(stage:String)
	{
		switch(stage.toLowerCase())
		{
			case "basestage" | "stage":
				return "Stage";
			default:
				return stage;
		}
	}

	// return array of trans and ease as int
	public static inline function convertEase(haxeEase:String):Array<Int>
	{
		var transes:Array<String> = ["linear", "sine", "quint", "quart", "quad", "expo", "elastic", "cubic", "circ", "bounce", "back"];
		var result:Array<Int> = [0, 0];

		var trans = transes[0];
		if (haxeEase.endsWith("In"))
		{
			result[1] = 0;
			trans = haxeEase.split("In")[0];
		}
		else if (haxeEase.endsWith("Out"))
		{
			result[1] = 1;
			trans = haxeEase.split("Out")[0];
		}
		else if (haxeEase.endsWith("InOut"))
		{
			result[1] = 2;
			trans = haxeEase.split("InOut")[0];
		}

		result[0] = transes.indexOf(trans);

		return result;
	}
}

@:structInit class EvilChart
{
	public var bpm:Float = 100;
	public var scroll_speed:Float = 1;

	public var player:EvilCharData = {};
	public var opponent:EvilCharData = {};
	public var dj:EvilCharData = {character: "gf"};
	public var stage:String = "Stage";
}

@:structInit class EvilCharData
{
	public var character:String = "bf";
	public var notes:Array<EvilNote> = [];
}

@:structInit class EvilNote
{
	public var id:Int = 0;
	public var time:Float = 0;
	public var length:Float = 0;
	public var type:String = "";
}

@:structInit class EvilEvent
{
	public var name:String = "";
	public var data:Dynamic = {};
	public var id:Int = 0;
	public var time:Float = 0;
}