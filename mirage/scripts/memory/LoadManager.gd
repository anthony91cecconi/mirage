extends Node

# =================================================
# CONFIG
# =================================================
#const SAVE_PATH := "user://save.json"
const SAVE_PATH := "res://temp/save.json"

# =================================================
# STATE
# =================================================
var data: Dictionary = {}

var load_file : bool
# =================================================
# API PUBBLICA
# =================================================
func load_game() -> void:
	D.debug_order("@")
	HumansManager.clear()
	if data.has("humans"):
		HumansManager.from_dict(data["humans"])
	var scene_path: String = data["scene"]
	get_tree().change_scene_to_file(scene_path)

	# 3️⃣ aspetta che la scena sia pronta
	await get_tree().process_frame


func pre_load_file() -> void:
	file_exists()
	D.debug_order("@")
	
	if not load_file:
		return
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		load_file = false
		return
	
	var content := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		delete_save()
		load_file = false
		return
	
	data = parsed

	# Controllo versione
	if not data.has("version") or data["version"] != SaveManager.version:
		D.error("Save non compatibile, lo elimino")
		delete_save()
		data = {}


func file_exists() -> void:
	D.debug_order("@")
	load_file = FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	D.debug_order("@")
	if FileAccess.file_exists(SAVE_PATH):
		var err = DirAccess.remove_absolute(SAVE_PATH)
		if err != OK:
			push_error("Impossibile eliminare il save: " + str(err))
