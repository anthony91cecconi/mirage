extends Node2D
class_name RoomBase

@export var room_id: String


func _ready() -> void:
	print("RoomBase READY:", room_id)
	spawn_humans()
	RoomManager.corridor_init()



func spawn_humans() -> void:
	var humans := HumansManager.get_humans_in_room(room_id)
	print("Humans in room", room_id, ":", humans.size())
	for h in humans:
		spawn_human(h)



func spawn_human(h: HumansInfo) -> void:

	var scene := load(h.scena) as PackedScene
	if scene == null:
		push_error("RoomBase: impossibile caricare scena %s" % h.scena)
		return

	var instance := scene.instantiate()
	add_child(instance)

	if instance.has_method("setup_from_info"):
		instance.setup_from_info(h)
	else:
		push_warning("RoomBase: %s non implementa setup_from_info()" % instance.name)

func snapshot_humans() -> void:
	for h in get_tree().get_nodes_in_group("humans"):
		h.sync_to_info()

func spawn_dinamic_human(id:String) -> void:
	var human : HumansInfo = HumansManager.get_human_by_id(id)
	spawn_human(human)
