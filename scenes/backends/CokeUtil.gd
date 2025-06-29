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
