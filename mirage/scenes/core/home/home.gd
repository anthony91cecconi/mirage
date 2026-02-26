extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	D.debug_order("@")
	$Buttons/LoadGame.disabled = not LoadManager.load_file


func _on_new_game_pressed() -> void:
	D.debug_order("@")
	#get_tree().change_scene_to_file("res://scenes/core/new_player/new_player.tscn")
	SaveManager.new_game()
	RoomManager.change_room_id("Infirmary")


func _on_exit_pressed() -> void:
	D.debug_order("@")
	get_tree().quit()


func _on_load_game_pressed() -> void:
	D.debug_order("@")
	LoadManager.load_game()

func _on_test_pressed() -> void:
	D.debug_order("@")
	SaveManager.test()
	RoomManager.change_room_id("test")
