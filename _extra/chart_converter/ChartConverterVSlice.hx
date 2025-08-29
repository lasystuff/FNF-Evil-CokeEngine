package;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

using StringTools;

class ChartConverterVSlice
{
	public static function main()
	{
		trace("Put chart file path!");
		var chartPath = Sys.stdin().readLine().trim();

		if (!FileSystem.exists(chartPath))
		{
			trace('No chart exists in ($chartPath) !!');
			return;
		}

		trace("Put metadata file path!");
		var metaPath = Sys.stdin().readLine().trim();

		if (!FileSystem.exists(metaPath))
		{
			trace('No metadata exists in ($metaPath) !!');
			return;
		}

		var folder = Path.directory(metaPath);
		var chart = haxe.Json.parse(File.getContent(chartPath));
		var meta = haxe.Json.parse(File.getContent(metaPath));

		trace(folder);

		var songId = chartPath.split("/")[chartPath.split("/").length - 1].split(".")[0];
		var displaySong = meta.songName;
		var difficulties:Array<String> = meta.playData.difficulties;

		FileSystem.createDirectory('$folder/converted/chart/');

		for (diff in difficulties)
		{
			var curChart = Reflect.field(chart.notes, diff);

			var newChart:ChartCoverterData.EvilChart = {
				bpm: meta.timeChanges[0].bpm,
				scroll_speed: Reflect.field(chart.scrollSpeed, diff),

				player: {character: meta.playData.characters.player},
				dj: {character: meta.playData.characters.girlfriend},
				opponent: {character: meta.playData.characters.opponent},

				stage: ChartCoverterData.parseStage(meta.playData.stage)
			}

			var curNotes:Array<VSliceNote> = curChart;
			for (note in curNotes)
			{
				var newNote:ChartCoverterData.EvilNote = {
					id: note.d % 4,
					time: note.t,
					length: note.l,
					type: note.k
				}

				if (note.d < 4)
					newChart.player.notes.push(newNote);
				else
					newChart.opponent.notes.push(newNote);
			}

			File.saveContent('$folder/converted/chart/$diff.json', haxe.Json.stringify(newChart, "\t"));
		}

		var events:Array<ChartCoverterData.EvilEvent> = [];

		var baseEvents:Array<VSliceEvent> = chart.events;
		for (event in baseEvents)
		{
			switch(event.e)
			{
				case "FocusCamera":
					var temp:ChartCoverterData.EvilEvent = {id: 0, time: event.t, name: "Move Camera"};

					var tempPos = [0, 0];
					if (event.v.x != null && event.v.x != 0)
						tempPos[0] = event.v.x;
					if (event.v.y != null && event.v.y != 0)
						tempPos[1] = event.v.x;

					if (tempPos != [0, 0])
						temp.data.position = tempPos;

					if (event.v.ease != null && event.v.ease != "CLASSIC")
					{
						if (event.v.duration != null)
							temp.data.speed = event.v.duration;

						var thing = ChartCoverterData.convertEase(event.v.ease);
						temp.data.trans = thing[0];
						temp.data.ease = thing[1];
					}

					if (event.v.char != null)
					{
						switch(event.v.char)
						{
							case 0:
								temp.data.target = "player";
							case 1:
								temp.data.target = "opponent";
							default:
						}
					}

					events.push(temp);
				case "ZoomCamera":
					var thing = ChartCoverterData.convertEase(event.v.ease);
					var trans = thing[0];
					var ease = thing[1];
					events.push({id: 0, time: event.t, name: "Zoom Camera", data: {speed: event.v.duration, value: event.v.zoom, trans: trans, ease: ease}});
				case "SetCameraBop":
					// ignore intensity cuz im lazy
					events.push({id: 0, time: event.t, name: "Set Camera Bop Rate", data: {value: event.v.rate}});
				default:
			}
		}

		File.saveContent('$folder/converted/events.json', haxe.Json.stringify({events: events}, "\t"));
	}
}

typedef VSliceNote = {
	var t:Float;
	var d:Int;
	var l:Float;
	var k:String;
}

typedef VSliceEvent = {
	var t:Float;
	var e:String;
	var v:Dynamic;
}