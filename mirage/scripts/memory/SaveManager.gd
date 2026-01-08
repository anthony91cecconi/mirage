extends Node

#const SAVE_PATH := "user://save.json"
const SAVE_PATH := "res://temp/save.json"


var data: Dictionary = {}


func _ready() -> void:
	D.normal("avvio Savemanager")
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


#-------------------------------------------------------
#------------------gestione CRUD letti -----------------
#-------------------------------------------------------

func save_bed(bed_data: BedInfo) -> void:
	if not bed_data.has_id():
		D.error("Bed has no id.")
		return
		
	if not data.has("entities"):
		data["entities"] = {}
		
	if not data["entities"].has("beds"):
		data["entities"]["beds"] = []
		
	var beds: Array = data["entities"]["beds"]

	for i in range(beds.size()):
		if beds[i].get("bed_id") == bed_data["bed_id"]:
			beds[i] = BedInfo.to_dict(bed_data)
			data["entities"]["beds"] = beds
			save()
			return

	beds.append(BedInfo.to_dict(bed_data))
	data["entities"]["beds"] = beds
	save()
	load_save()
	
func bed_remuve_old_human(human : HumansInfo) -> void:
	print("------------",human.bed_id,human.bed_id.is_empty())
	if human.bed_id.is_empty():
		return
	var bed: BedInfo = LoadManager.get_bed(human.bed_id).bed
	bed.NPC_ID = ""
	save_bed(bed)

func delete_bed(bed_id) -> void:
	if not data.has("entities"):
		return

	if not data["entities"].has("beds"):
		return

	var beds: Array = data["entities"]["beds"]

	for i in range(beds.size()):
		if beds[i].get("bed_id") == bed_id:
			beds.remove_at(i)
			data["entities"]["beds"] = beds
			save()
			return

func save_all_beds_in_scene() -> void:
	if not data.has("entities"):
		data["entities"] = {}

	if not data["entities"].has("beds"):
		data["entities"]["beds"] = []

	var beds_by_id := {}

	for bed in data["entities"]["beds"]:
		if bed.has("bed_id"):
			beds_by_id[bed["bed_id"]] = bed

	for node in get_tree().get_nodes_in_group("beds"):
		if node.has_method("to_dict"):
			var bd: Dictionary = node.to_dict()
			if bd.has("bed_id"):
				beds_by_id[bd["bed_id"]] = bd

	data["entities"]["beds"] = beds_by_id.values()
	save()


#-------------------------------------------------------
#------------------gestione CRUD player -----------------
#-------------------------------------------------------

func save_player(player: HumansInfo) -> void:
	if not data.has("player"):
		data["player"] = {}	
	data["player"] = HumansInfo.to_dict(player) 
	save()

func generate_defoult_player() -> void:
	save_player(HumansInfo.new("player di prova","",Vector2(0,0),"",true,"player"))


#-------------------------------------------------------
#------------------gestione CRUD NPC -----------------
#-------------------------------------------------------

func save_human(human_data: HumansInfo) -> void:
	if not human_data.has("human_id"):
		D.error("human has no id.")
		return
		
	if not data.has("humans"):
		data["humans"] = {}
		
	var humans: Array = data["humans"]

	for i in range(humans.size()):
		if humans[i].get("humans_id") == human_data["humans_id"]:
			humans[i] = HumansInfo.to_dict(human_data)
			data["humans"] = humans
			save()
			return

	humans.append(HumansInfo.to_dict(human_data))
	data["humans"] = humans
	save()


#-------------------------------------------------------
#------------------gestione CRUD tempo -----------------
#-------------------------------------------------------
func save_time_second(time: float) -> void:
	if not data.has("stats"):
		data["stats"] = {}	
	data["stats"]["time"] = time
	save()

func load_time_second() -> float:
	if not data.has("stats") or not data["stats"].has("time"):
		save_time_second(TimeManager.TOTAL_GAME_HOURS)
		return TimeManager.TOTAL_GAME_HOURS

	return data["stats"]["time"]
