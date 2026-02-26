extends Node

signal npc_moved
signal npc_moved_simulation(human_id, old_room, new_room)

# =================================================
# STATE
# =================================================
var humans: Array[HumansInfo] = []
var alive_bodies := {} 

# =================================================
# CRUD
# =================================================
func clear() -> void:
	D.debug_order("@")
	humans.clear()


func add_human(info: HumansInfo) -> void:	
	D.debug_order("@")
	if get_human_by_id(info.human_id) != null:
		D.error("human_id duplicato: %s" % info.human_id)
		return
	humans.append(info)
	D.debug(info.human_id + " human aggiunto")


func remove_human(human_id: String) -> void:
	D.debug_order("@")
	humans = humans.filter(func(h): return h.human_id != human_id)
	D.debug(human_id + "human rimosso")


func get_human_by_id(human_id: String) -> HumansInfo:
	D.debug_order("@")
	for h in humans:
		if h.human_id == human_id:
			return h
	return null


func register_body(human_id: String, body: HumanBody) -> void:
	D.debug_order("@")
	alive_bodies[human_id] = body
	D.debug("human inserito al registro humans attivi nella scena")

#TODO: vedere se si puo non de registrare in caso si va nel corridor, risparmiando computazione
func unregister_body(human_id: String) -> void:
	D.debug_order("@")
	alive_bodies.erase(human_id)
	D.debug("human tolto dal registro humans attivi nella scena")


func update_position(human_id: String, pos: Vector2) -> void:
	D.debug_order("@")
	var h := get_human_by_id(human_id)
	if h:
		h.set_position(pos)


# =================================================
# ROOM UPDATE ORIGINALE (NON TOCCATO)
# =================================================
func update_room(human_id: String, room: String) -> void:
	D.debug_order("@")
	var h := get_human_by_id(human_id)
	if h:
		var old_room = h.room 
		h.set_room(room)
		emit_signal("npc_moved", old_room, room)
		return
	D.error("update_room per "+human_id+" fallito")


# =================================================
# ROOM UPDATE SOLO PER SIMULAZIONE
# =================================================
func update_room_simulation(human_id: String, room: String) -> void:
	D.debug_order("@")
	var h := get_human_by_id(human_id)
	if h:
		var old_room = h.room
		h.room = room
		
		# posizione speciale SOLO per simulazione map_layer
		if room == RoomManager.MAP_LAYER_ID:
			h.position = Vector2(-4972.48, 1465.24)
		
		emit_signal("npc_moved_simulation", human_id, old_room, room)


# =================================================
# QUERY
# =================================================
func get_humans_in_room(room: String) -> Array[HumansInfo]:
	D.debug_order("@")
	var result: Array[HumansInfo] = []
	for h in humans:
		if h.room == room:
			result.append(h)
	return result


func get_humans_in_room_only_number(room: String) -> int:
	D.debug_order("@")
	var result: int = 0
	for h in humans:
		if h.room == room:
			result += 1
	return result


func get_offscreen_humans() -> Array:
	D.debug_order("@")
	var result := []
	for h in humans:
		if not alive_bodies.has(h.human_id):
			result.append(h)
	return result


# =================================================
# SAVE
# =================================================
func to_dict() -> Array:
	D.debug_order("@")
	var arr: Array = []
	for h in humans:
		arr.append(h.to_dict())
	return arr


func from_dict(arr: Array) -> void:
	D.debug_order("@")
	clear()
	for d in arr:
		if typeof(d) == TYPE_DICTIONARY:
			add_human(HumansInfo.from_dict(d))
			
	Orchestrator.humansManager = true


func use_for_save() -> Array[Dictionary]:
	D.debug_order("@")
	var result: Array[Dictionary] = []

	for h in humans:
		if h.active:
			if alive_bodies.has(h.human_id):
				var body :HumanBody = alive_bodies[h.human_id]
				body._sync_to_info()
			result.append(h.to_dict())

	return result
	
func set_ready():
	Orchestrator.humansManager = true
