extends Node

#const SAVE_PATH := "user://save.json"
const SAVE_PATH := "res://temp/save.json"
var data: Dictionary = {}   # Loaded data



func _ready() -> void:
	#load_data()
	pass

func file_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## PRE REFACTORING
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
	return get_human("player")


#-------------------------------------------------------
#------------------gestione CRUD npc -----------------
#-------------------------------------------------------
func get_human(human_id) -> HumansInfo:
	load_data()
	if not data.has("humans"):
		return null
	
	for human in data["humans"]:
		if human.get("human_id") == human_id:
			return HumansInfo.from_dict(human)
	return null


func get_all_humans() -> Array[HumansInfo]:
	return  data["humans"]

func get_all_humans_in_room(room:String) -> Array[HumansInfo]:
	load_data()
	var a : Array[HumansInfo] = []
	for human_dict in data["humans"]:
		if human_dict.get("room") == room:

			var human_info := HumansInfo.from_dict(human_dict)
			a.append(human_info)
	return a
	
	
	
#-------------------------------------------------------
#------------------gestione CRUD tempo -----------------
#-------------------------------------------------------

func load_time_second() -> float:
	if not data.has("stats"):
		data["stats"] = {}	
		SaveManager.save_time_second(90.0 * 60.0 * 60.0)
		load_data()
	return data["stats"]["time"]
