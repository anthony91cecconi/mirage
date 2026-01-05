extends Node

const SAVE_PATH := "user://finalsrecorder/saverecorder.json"

var data: Dictionary = {}


func _ready() -> void:
	D.normal("avvio SaveFinalRecorder")
	if not file_exists():
		D.warn("Save file not found. create new file.")
		save()
	else:
		D.success("Save file found. load info.")
		load_save()


func file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t")) 
		file.close()
		D.success("saved.")
	else:
		D.error("can not open file.")


func load_save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var result = JSON.parse_string(content)

		if typeof(result) == TYPE_DICTIONARY:
			data = result
		else:
			D.error("File File is invalid.")
			data = {}
			save()

		file.close()
	else:
		D.error("can not open file.")
