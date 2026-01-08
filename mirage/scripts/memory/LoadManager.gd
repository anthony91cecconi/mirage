extends Node

#const SAVE_PATH := "user://save.json"
const SAVE_PATH := "res://temp/save.json"
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


#-------------------------------------------------------
#------------------gestione CRUD letti -----------------
#-------------------------------------------------------
func get_bed(bed_id) -> Dictionary:
	if not data.has("entities"):
		return {"succes" : false}

	if not data["entities"].has("beds"):
		return {"succes" : false}

	for bed in data["entities"]["beds"]:
		if bed.get("bed_id") == bed_id:
			
			return {"succes" : true,"bed":BedInfo.from_dict(bed)}
	return {"succes" : false}

#-------------------------------------------------------
#------------------gestione CRUD player -----------------
#-------------------------------------------------------
func get_player() -> HumansInfo:
	if not data.has("player"):
		SaveManager.generate_defoult_player()
	return HumansInfo.from_dict(data["player"])


#-------------------------------------------------------
#------------------gestione CRUD npc -----------------
#-------------------------------------------------------
func get_human(human_id) -> Dictionary:
	if not data.has("humans"):
		return {"succes" : false}

	for human in data["humans"]:
		if human.get("human_id") == human_id:
			return {"succes" : true,"human":human}

	return {"succes" : false}

func get_all_humans() -> Array[HumansInfo]:
	return data["humans"]


#-------------------------------------------------------
#------------------gestione CRUD tempo -----------------
#-------------------------------------------------------

func load_time_second() -> float:
	if not data.has("stats"):
		data["stats"] = {}	
		SaveManager.save_time_second(90.0 * 60.0 * 60.0)
		load_data()
	return data["stats"]["time"]
