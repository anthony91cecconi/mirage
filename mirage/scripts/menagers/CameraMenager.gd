extends Node

enum CameraType { PLAYER, ROOM, MAP }

var player_camera : Camera2D
var room_camera : Camera2D
var map_layer_camera : Camera2D

var map_layer := false
var room := false

func change_camera(type: CameraType, c: Camera2D) -> void:
	D.debug_order("@")
	match type:
		CameraType.PLAYER:
			player_camera = c
			player_camera.make_current()
		CameraType.ROOM:
			room_camera = c
		CameraType.MAP:
			map_layer_camera = c
	D.debug("telecamera ok")
	Orchestrator.cameraManager = true

func map_layer_swap() -> void:
	D.debug_order("@")
	if not RoomManager._map_layer_instance:
		RoomManager.map_layer_init()
	
	if not is_instance_valid(map_layer_camera):
		RoomManager._map_layer_instance.set_map_layer_camera()

	
	if map_layer and  is_instance_valid(map_layer_camera):
		map_layer_camera.make_current()
		D.debug("posizione corrido camera "+ str(map_layer_camera.global_position))
	elif player_camera:
		player_camera.make_current()

# solo debug
func room_swap() -> void:
	D.debug_order("@")
	if room and is_instance_valid(room_camera):
		room_camera.make_current()
		D.debug("posizione room camera "+ str(room_camera.global_position))
	elif player_camera:
		player_camera.make_current()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		map_layer = !map_layer
		map_layer_swap()

	if event.is_action_pressed("map_room"):
		room = !room
		room_swap()
