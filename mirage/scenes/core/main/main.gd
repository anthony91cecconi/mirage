extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LoadManager.pre_load_file()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/core/home/home.tscn")
