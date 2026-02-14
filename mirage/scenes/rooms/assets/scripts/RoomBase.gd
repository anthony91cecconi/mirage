extends Node2D
class_name RoomBase

@onready var camera : Camera2D = $Camera2D
@export var room_id: String


func _ready() -> void:
	D.debug("RoomBase READY:"+ room_id)
	call_deferred("_spawn_after_ready")
	TouchControls.enable()

func _spawn_after_ready():
	await get_tree().process_frame
	spawn_humans()
	RoomManager.map_layer_init()


func spawn_humans() -> void:
	var humans := HumansManager.get_humans_in_room(room_id)
	D.debug("Humans in room"+ room_id+ ":"+ str(humans.size()))
	for h in humans:
		spawn_human(h)



func spawn_human(h: HumansInfo) -> void:
	var scene := load(h.scena) as PackedScene
	if scene == null:
		D.error("RoomBase: impossibile caricare scena %s" % h.scena)
		return

	var instance := scene.instantiate()
	add_child(instance)

	if instance.has_method("setup_from_info"):
		instance.setup_from_info(h)
	else:
		D.error("RoomBase: %s non implementa setup_from_info()" % instance.name)

func snapshot_humans() -> void:
	for h in get_tree().get_nodes_in_group("humans"):
		h.sync_to_info()

func spawn_dinamic_human(id:String) -> void:
	var human : HumansInfo = HumansManager.get_human_by_id(id)
	spawn_human(human)

func set_map_layer_camera() -> void:
	CameraMenager.change_camera(CameraMenager.CameraType.MAP, camera)
