extends Node

var humans: Array[HumansInfo] = [
	HumansInfo.new(
		"test",
		"test",
		Vector2(0, 0),
		"",
		true,
		"test"
	)
]



func assign_bed(_human_id : String, _bed_id : String) -> void:
	for h in  humans:
		if h.get("human_id") == _human_id:
			SaveManager
