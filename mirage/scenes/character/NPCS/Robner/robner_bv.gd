extends NpcOffscreenBehaviour

func simulate(info: HumansInfo, delta: float) -> void:
	var chance := 10
	
	if randi() % 100 < chance:
		var rooms := RoomManager.rooms.keys()
		if rooms.is_empty():
			return
		
		var new_room := rooms.pick_random()
		HumansManager.update_room(info.human_id, new_room)
