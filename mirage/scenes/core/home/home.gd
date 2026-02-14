extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not LoadManager.file_exists():
		$Buttons/LoadGame.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/core/new_player/new_player.tscn")
	SaveManager.new_game()
	RoomManager.change_room_id("Infirmary")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_load_game_pressed() -> void:
	LoadManager.load_game()
