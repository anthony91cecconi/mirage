extends Node

var player_info : HumansInfo 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_info()

func assigned_bed(bed_id : String) -> void:
	player_info.bed_id = bed_id
	save_info()

func save_info() -> void:
	SaveManager.save_player(player_info)

func load_info() -> void:
	player_info = LoadManager.get_player()
