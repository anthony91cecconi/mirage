extends Node

# =================================================
# CONFIG
# =================================================
const SAVE_PATH := "user://save.json"
#const SAVE_PATH := "res://temp/save.json"
const AUTOSAVE_INTERVAL := 20.0

# =================================================
# STATE
# =================================================
var _autosave_timer: Timer


# =================================================
# LIFECYCLE
# =================================================
func _ready() -> void:
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = AUTOSAVE_INTERVAL
	_autosave_timer.one_shot = false
	_autosave_timer.autostart = true
	_autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(_autosave_timer)


# =================================================
# AUTOSAVE
# =================================================
func _on_autosave_timeout() -> void:
	D.debug("autosalvataggio scattato")
	autosave()


func request_save() -> void:
	save_game()


# =================================================
# SAVE
# =================================================
func save_game() -> void:
	var data: Dictionary = {}
	data["scene"] = get_tree().current_scene.scene_file_path
	
	data["humans"] = HumansManager.use_for_save()
	D.debug(str(data))
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: impossibile aprire file")
		return
	var json := JSON.stringify(data, "\t") # oppure "  " (2 spazi)
	file.store_string(json)
	file.close()
	
		

func new_game() -> void:
	# reset stato globale
	HumansManager.clear()

	# ===============================
	# PLAYER
	# ===============================
	var player_info := HumansInfo.new(
		"namePlayer",
		"Room47Infirmary",
		"res://scenes/character/player/player.tscn",
		Vector2(-296.12, 1597.60),
		"player",
		true
	)

	HumansManager.add_human(player_info)

	# ===============================
	# NPCs
	# ===============================
	randomize()

	# rettangolo debug tracciato dal player
	var min_x := 378.45
	var max_x := 1002.73
	var min_y := -105.64
	var max_y := 434.46

	for i in range(1, 1):
		var npc_id := "npc-%03d" % i

		var npc_pos := Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)

		var npc_info := HumansInfo.new(
			npc_id, # nome (provvisorio)
			"Room47Infirmary",
			"res://scenes/character/NPCS/base/npc_base.tscn",
			npc_pos,
			npc_id,
			true
		)

		HumansManager.add_human(npc_info)


	HumansManager.add_human(player_info)

	# costruiamo il save iniziale
	var data: Dictionary = {}
	data["scene"] = "res://scenes/levels/level_01.tscn"
	data["humans"] = HumansManager.to_dict()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: impossibile creare nuovo save")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func autosave() -> void:
	save_game()
