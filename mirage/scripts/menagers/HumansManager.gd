extends Node

# =================================================
# STATE
# =================================================
var humans: Array[HumansInfo] = []
var alive_bodies := {} 

# =================================================
# CRUD
# =================================================
func clear() -> void:
	humans.clear()


func add_human(info: HumansInfo) -> void:
	print(info)
	if get_human_by_id(info.human_id) != null:
		push_warning("HumansManager: human_id duplicato: %s" % info.human_id)
		return
	humans.append(info)


func remove_human(human_id: String) -> void:
	humans = humans.filter(func(h): return h.human_id != human_id)


func get_human_by_id(human_id: String) -> HumansInfo:
	for h in humans:
		if h.human_id == human_id:
			return h
	return null

func register_body(human_id: String, body: Node) -> void:
	alive_bodies[human_id] = body
	D.debug("corpo registrato = "+human_id)

func unregister_body(human_id: String) -> void:
	alive_bodies.erase(human_id)

func update_position(human_id: String, pos: Vector2) -> void:
	D.debug("aggiornamento posizione -> "+human_id+" alla posizione " + str(pos))
	var h := get_human_by_id(human_id)
	if h:
		h.position = pos


func update_room(human_id: String, room: String) -> void:
	var h := get_human_by_id(human_id)
	if h:
		h.room = room


# =================================================
# QUERY (per le scene)
# =================================================
func get_humans_in_room(room: String) -> Array[HumansInfo]:
	var result: Array[HumansInfo] = []
	for h in humans:
		if h.room == room:
			result.append(h)
	return result


# =================================================
# SAVE / LOAD INTERFACE
# =================================================
func to_dict() -> Array:
	var arr: Array = []
	for h in humans:
		arr.append(h.to_dict())
	return arr


func from_dict(arr: Array) -> void:
	clear()
	for d in arr:
		if typeof(d) == TYPE_DICTIONARY:
			add_human(HumansInfo.from_dict(d))
			
			
# =================================================
# SAVE use
# =================================================
func use_for_save() -> Array[HumansInfo]:
	var result: Array[HumansInfo] = []

	for h in humans:
		if h.active:
			if alive_bodies.has(h.human_id):
				var body = alive_bodies[h.human_id]
				body.sync_to_info() 
			result.append(h)

	return result
