extends Node

enum CameraType { PLAYER, ROOM, CORRIDOR }

var player_camera : Camera2D
var room_camera : Camera2D
var corridor_camera : Camera2D

var corridor := false
var room := false

func change_camera(type: CameraType, c: Camera2D) -> void:
	match type:
		CameraType.PLAYER:
			player_camera = c
			player_camera.make_current()
		CameraType.ROOM:
			room_camera = c
		CameraType.CORRIDOR:
			corridor_camera = c

func corridor_swap() -> void:
	if not RoomManager._corridor_instance:
		RoomManager.corridor_init()
	
	if not is_instance_valid(corridor_camera):
		RoomManager._corridor_instance.set_corridor_camera()

	
	if corridor and  is_instance_valid(corridor_camera):
		corridor_camera.make_current()
		D.debug("posizione corrido camera "+ str(corridor_camera.global_position))
	elif player_camera:
		player_camera.make_current()

# solo debug
func room_swap() -> void:
	if room and is_instance_valid(room_camera):
		room_camera.make_current()
		D.debug("posizione room camera "+ str(room_camera.global_position))
	elif player_camera:
		player_camera.make_current()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		corridor = !corridor
		corridor_swap()

	if event.is_action_pressed("map_room"):
		room = !room
		room_swap()
