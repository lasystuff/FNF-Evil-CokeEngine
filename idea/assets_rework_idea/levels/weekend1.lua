display_name = "Weekend 1"
title = "Due Debits"

-- Insert Blazin to songs if you finished blazin
songs = ["darnell", "lit-up", "2hot"]
if not SaveData.data._score:get("story_week1") == nil then
	songs:insert("blazin")
end