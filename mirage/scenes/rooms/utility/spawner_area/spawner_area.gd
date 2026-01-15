extends Area2D
class_name AreaSpawner

@onready var collision: CollisionShape2D = $CollisionShape2D




# ----------------------------------------------------
# ---------------- PRECISION SPAWN -------------------
# ----------------------------------------------------

func _spawn_precision(human_id : String) -> void:
	if human_id == "":
		push_warning("AreaSpawner: human_id non impostato per spawn di precisione")
		return

	var human_info : HumansInfo = LoadManager.get_human(human_id)
	
	_spawn_human(human_info)

# ----------------------------------------------------
# ---------------- HUMAN SPAWN CORE ------------------
# ----------------------------------------------------

func _spawn_human(human_info: HumansInfo) -> void:
	print(human_info)

	# ---------------- PLAYER ----------------
	if human_info.human_id == "player":
		var player_scene := preload("res://scenes/characters/player/topdown/player_top_down.tscn")
		var player := player_scene.instantiate()

		get_tree().current_scene.add_child(player)

		# POSIZIONE DELLO SPAWNER
		human_info.position = global_position
		player.global_position = global_position

		player.call_deferred("setup_from_info", human_info)
		return

	# ---------------- NPC (MOCK VISIVO) ----------------
	var npc_mock := Button.new()
	npc_mock.text = human_info.human_name
	get_tree().current_scene.add_child(npc_mock)
	npc_mock.global_position = global_position
