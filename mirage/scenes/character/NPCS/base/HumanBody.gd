extends CharacterBody2D
class_name HumanBody

# =================================================
# DATA
# =================================================
var human_data: HumansInfo = null
var _initialized := false
var target_id

# =================================================
# LIFECYCLE
# =================================================
func _ready() -> void:
	D.debug_order("@")
	D.debug("HumanBody READY per " + str(human_data.human_id if human_data else "Sconosciuto"))

	call_deferred("_on_data_ready")

func setup_from_info(info: HumansInfo) -> void:
	D.debug_order("@")
	D.debug("Setup from info per " + info.human_id)
	human_data = info


func _physics_process(delta: float) -> void:
	if not _moving:
		return


# =================================================
# MOVEMENT
# =================================================
var _moving: bool = false


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	D.debug_order("@")
	# AGGIUNGI QUESTO CONTROLLO
	if not _moving: 
		return

	velocity = safe_velocity
	move_and_slide()
	_sync_to_info()


func _on_data_ready() -> void:
	D.debug_order("@")
	if human_data:
		D.debug("Data ready per " + human_data.human_id)
		HumansManager.register_body(human_data.human_id, self)
		_initialized = true


func _exit_tree() -> void:
	D.debug_order("@")
	if human_data:
		D.debug("Unregister " + human_data.human_id)
		HumansManager.unregister_body(human_data.human_id)


func _sync_to_info() -> void:
	if human_data:
		human_data.position = global_position

# =================================================
# MOVEMENT API
# =================================================
func move_to(target: Vector2) -> void:
	D.debug_order("@")
	D.debug(human_data.human_id + " MOVE_TO chiamato verso " + str(target))


func stop() -> void:
	D.debug_order("@")
	D.debug(human_data.human_id + " STOP")
	
	_moving = false  # Settiamo il flag per primo
	velocity = Vector2.ZERO
	
	if $NavigationAgent2D:
		$NavigationAgent2D.set_target_position(global_position)
	
	
# =================================================
# RESET
# =================================================
func reset_after_load() -> void:
	D.debug_order("@")
	D.debug("Reset after load per " + human_data.human_id)
	velocity = Vector2.ZERO
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

	if human_data:
		human_data.position = global_position


func update_info() -> void:
	D.debug_order("@")
	human_data = HumansManager.get_human_by_id(human_data.human_id)


func _get_door_to_room(target_room_id: String):
	D.debug_order("@")
	var doors := get_tree().get_nodes_in_group("doors")
	D.debug("Doors trovate: " + str(doors.size()))
	
	var nearest = null
	var min_dist = INF
	
	for door in doors:
		if door.to_room_id == target_room_id:
			var dist = global_position.distance_to(door.global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = door
	return nearest


func resume() -> void:
	D.debug_order("@")
	_moving = true
