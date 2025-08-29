package;

import sys.FileSystem;
import sys.io.File;

import ChartCoverterData.*;

using StringTools;

class ChartConverterLegacy
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

		var chart = haxe.Json.parse(File.getContent(chartPath)).song;

		var newChart:EvilChart = {
			bpm: chart.bpm,
			scroll_speed: chart.speed,
			player: {character: chart.player1},
			opponent: {character: chart.player2}
		}

		if (chart.gfVersion != null)
			newChart.dj.character = chart.gfVersion;
		else if (chart.gf != null)
			newChart.dj.character = chart.gf;
		if (chart.stage != null)
			newChart.stage = ChartCoverterData.getStage(chart.stage);

		for (i in 0...chart.notes.length)
		{
			var section = chart.notes[i];
			for (i in 0...section.sectionNotes.length)
			{
				var note = section.sectionNotes[i];

				var isPlayer:Bool = section.mustHitSection;
				if (note[1] > 3)
					isPlayer = !isPlayer;

				var newNote:EvilNote = {
					id: note[1] % 4,
					time: note[0],
					length: note[2]
				}

				if (isPlayer)
					newChart.player.notes.push(newNote);
				else
					newChart.opponent.notes.push(newNote);
			}
		}

		File.saveContent(chartPath.replace(".json", "-converted.json"), haxe.Json.stringify(newChart, "\t"));

		var events:Array<EvilEvent> = [];

		// then do camera events stuff
		var sectionStart:Float = 0;
		var lastMustHit:Bool = !chart.notes[0].mustHitSection;
		for (i in 0...chart.notes.length)
		{
			var section = chart.notes[i];
			if (section.mustHitSection != lastMustHit)
			{
				lastMustHit = section.mustHitSection;
				if (section.sectionNotes.length > 0){
					var e:EvilEvent = {
						name: "Move Camera",
						id: 0,
						time: sectionStart,
						data: {target: "player"}
					};

					if (!section.mustHitSection)
						e.data.target = "opponent";

					events.push(e);
				}
			}

			var crochet = ((60 / chart.bpm) * 1000);
			var stepCrochet = crochet / 4;
			sectionStart += section.lengthInSteps * stepCrochet;
		}

		File.saveContent(chartPath.replace(".json", "-converted-events.json"), haxe.Json.stringify({events: events}, "\t"));
	}
}