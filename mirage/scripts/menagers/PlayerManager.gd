extends Node

var player_info : HumansInfo 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func assigned_bed(bed_id : String) -> void:
	player_info.bed_id_assigned = bed_id

func save_info() -> void:
	pass

func load_info() -> void:
	pass
