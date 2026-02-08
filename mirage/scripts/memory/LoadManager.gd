extends Node

# =================================================
# CONFIG
# =================================================
const SAVE_PATH := "user://save.json"
#const SAVE_PATH := "res://temp/save.json"

# =================================================
# STATE
# =================================================
var data: Dictionary = {}


# =================================================
# API PUBBLICA
# =================================================
func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	data = JSON.parse_string(content)

	# 1️⃣ ripopola i dati logici
	HumansManager.clear()
	if data.has("humans"):
		HumansManager.from_dict(data["humans"])

	var scene_path: String = data["scene"]

	# 2️⃣ cambia scena
	get_tree().change_scene_to_file(scene_path)

	# 3️⃣ aspetta che la scena sia pronta
	await get_tree().process_frame


func file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
