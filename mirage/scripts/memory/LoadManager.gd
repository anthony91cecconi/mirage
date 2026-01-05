extends Node

const SAVE_PATH := "user://save.json"

var data: Dictionary = {}   # Loaded data


func _ready() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		D.warn("Save file not found. Nothing to load.")
		return
	
	load_data()


func load_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if not file:
		D.error("Unable to open file for reading.")
		return

	var content := file.get_as_text()
	var result :Dictionary= JSON.parse_string(content)

	if typeof(result) == TYPE_DICTIONARY:
		data = result
		D.debug("Save file loaded successfully.")
	else:
		D.error("Invalid or corrupted file.")
		data = {}  # Reset to default

	file.close()


func get_value(key: String, default_value = null):
	if data.has(key):
		return data[key]
	return default_value
