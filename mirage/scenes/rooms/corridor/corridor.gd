extends RoomBase


func _ready() -> void:
	D.debug_order("@")
	super._ready()
	start_room_counters()
	HumansManager.npc_moved_simulation.connect(_on_npc_moved_simulation)

	D.debug("corridor _ready()")


# =================================================
# SIGNAL HANDLER
# =================================================
func _on_npc_moved(id:String, old_room:String, new_room:String) -> void:
	D.debug_order("@")
	
	# aggiorniamo i contatori come prima
	_update_room_counters(old_room, new_room)
	
	# 🔥 se entra nel corridor lo spawnamo
	if new_room == "corridor":
		spawn_dinamic_human(id)

func _on_npc_moved_simulation(id:String, old_room:String, new_room:String) -> void:
	D.debug_order("@")
	_update_room_counters(old_room, new_room)

	if new_room == "corridor":
		spawn_dinamic_human(id)


# =================================================
# ROOM COUNTERS
# =================================================
func _update_room_counters(room1:String, room2:String) -> void:
	D.debug_order("@")
	for child in get_children():
		
		if not child is Node2D:
			continue
			
		if child.name != room1 and child.name != room2:
			continue

		if RoomManager.has_room(child.name):
			var count := HumansManager.get_humans_in_room_only_number(child.name)
			
			var label := child.get_node_or_null("Label")
			if label:
				label.text = str(count)


func start_room_counters() -> void:
	D.debug_order("@")
	for child in get_children():
		if not child is Node2D:
			continue
			
		var room_id := child.name
		
		if RoomManager.has_room(room_id):
			var count := HumansManager.get_humans_in_room_only_number(room_id)
			
			var label := child.get_node_or_null("Label")
			if label:
				label.text = str(count)

func spawn_human(h: HumansInfo) -> void:
	D.debug_order("@")

	var scene := load("res://scenes/character/NPCS/base/corridor_body/corridor_body.tscn")
	if h.human_id == "player":
		scene = load("res://scenes/character/player/corridor_body_player/corridor_body_player.tscn")
	
	if scene == null:
		D.error("Corridor: impossibile caricare corridor_body.tscn")
		return

	var instance = scene.instantiate()
	add_child(instance)

	if instance.has_method("setup_from_info"):
		instance.setup_from_info(h)
	else:
		D.warn("Corridor: %s non implementa setup_from_info()" % instance.name)
