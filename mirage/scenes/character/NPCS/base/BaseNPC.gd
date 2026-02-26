extends HumanBody
class_name BaseNPC

@onready var name_npc_label: Label = $Label
@onready var panic_output: Label = $Panic
@onready var navigation: NavigationAgent2D = $NavigationAgent2D
var counter_impossible_moove : int = 0 
var _is_recovering: bool = false 
var priority_system: PrioritySystem
var task: TaskDto

var muved : bool = false

# =================================================
# READY
# =================================================
func _ready() -> void:
	#D.debug_order("@")
	super._ready() 
	
	_update_ui() 
	
	#D.debug("BaseNPC READY e autorizzato a partire")
	if not is_connected("reached_target", _on_reached_target):
		connect("reached_target", _on_reached_target)

	_generate_new_task()
	if human_data:
		pass
		#D.debug(human_data.human_id + " istanziato completamente")
	else:
		D.error("un npc non è ben instanziato")



func _physics_process(delta: float) -> void:
	if counter_impossible_moove > 30:
		free_self()
		
	if not _moving:
		super._physics_process(delta)
		return
	
	if _moving and not velocity.length() > 0.1:
		counter_impossible_moove +=1
		if counter_impossible_moove % 10:
			_generate_new_task()
		return
	else :
		counter_impossible_moove = 0
	
	var next_path_position = navigation.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * human_data.move_speed
	
	if navigation.avoidance_enabled:
		navigation.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	if not _moving:
		velocity = Vector2.ZERO 
		return

	if _is_recovering:
		return
		
	velocity = safe_velocity
	move_and_slide()
	
	var count_collision : int = get_slide_collision_count()
	if count_collision > 0:
		if velocity.length() < (human_data.move_speed * 0.2) and count_collision > 3: 
			_trigger_stuck_recovery(count_collision * 0.5)
			return

	_sync_to_info()

func _trigger_stuck_recovery(collisions : float) -> void:
	if _is_recovering: return
	
	var old_panic = panic_output.text
	_is_recovering = true
	_moving = false
	velocity = Vector2.ZERO 
	
	#D.debug(human_data.human_id + " bloccato da collisione. Pausa di 0.5s...")
	panic_output.text = "COLPITO"
	if muved:
		await get_tree().create_timer(collisions).timeout
	panic_output.text = old_panic
	
	_is_recovering = false
	_moving = true
	#D.debug(human_data.human_id + " Ripresa task dopo incastro.")

	_generate_new_task()
# =================================================
# SETUP
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	#D.debug_order("@")
	super.setup_from_info(info)

	if is_node_ready():
		_update_ui()
	
	#D.debug("Setup NPC: " + human_data.human_id)
	
	if priority_system == null:
		priority_system = PrioritySystem.new(human_data.skills)


func _update_ui() -> void:
	if name_npc_label and human_data:
		name_npc_label.text = human_data.human_id

# =================================================
# TASK FLOW
# =================================================
func _generate_new_task() -> bool:
	#D.debug_order("@")
	if not human_data:
		return false
	
	#D.debug(human_data.human_id + " Generating task")
	
	task = priority_system.generate_new_task()
	
	if task == null:
		#D.debug("Task NULL")
		panic_output.text = "NO_TASK"
		return false
	
	if task.room_id == ""and panic_output:
		#D.debug("Task room_id vuoto")
		panic_output.text = "NO_TASK"
		return false
	
	#D.debug(human_data.human_id + " Task -> " + task.room_id)
	if not task.room_id == null and panic_output: 
		panic_output.text = task.room_id
	
	_execute_task()
	return true

func _on_reached_target() -> void:
	#D.debug_order("@")
	#D.debug(human_data.human_id + " Segnale reached_target ricevuto")
	stop()
	_generate_new_task()


func free_self() -> void:
	panic_output.text = "PANICO"
	await get_tree().create_timer(10).timeout
	_generate_new_task()

# =================================================
# DOOR SEARCH
# =================================================
func _get_strategic_exit_door(randomize_selection: bool = false):
	#D.debug_order("@")
	var doors := get_tree().get_nodes_in_group("doors")
	var valid_doors = []


	for node in doors:
		if node is ScenesDoor:
			var door: ScenesDoor = node
			if door.to_room_id == human_data.room or door.to_room_id == RoomManager.MAP_LAYER_ID:
				valid_doors.append(door)
	
	if valid_doors.is_empty():
		return null
	valid_doors.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	

	if valid_doors.size() > 1 and randomize_selection:
		var pick_index = randi() % min(valid_doors.size(), 3) 
		return valid_doors[pick_index]

	return valid_doors[0]

func move_to(target: Vector2) -> void:
	#D.debug_order("@")
	#D.debug(human_data.human_id + " MOVE_TO chiamato verso " + str(target))
	navigation.target_position = target
	_moving = true


func _execute_task() -> void:
	#D.debug_order("@")
	#D.debug(human_data.human_id + " Execute task")
	var room = _go_in_room()
	
	if not room:
		return
		
	_action()
	muved = true
	
	
func _go_in_room() -> bool:
	#D.debug_order("@")
	#D.debug("Stanza attuale: " + human_data.room)
	#D.debug("Stanza target: " + task.room_id)
	if human_data.room == task.room_id:
		#D.debug("Gia nella stanza corretta")
		return true

	if human_data.room != RoomManager.MAP_LAYER_ID:
		#D.debug("Non nel corridor, cerco uscita")
		var should_randomize = randf() < 0.4
		var door = _get_strategic_exit_door(should_randomize)
		if door:
			#D.debug("Porta trovata verso corridor: " + str(door.global_position))
			move_to(door.global_position)
		else:
			D.error("NESSUNA PORTA TROVATA per uscire")
	else:
		#D.debug("Sono nel corridor, cerco porta verso target")
		var door = _get_door_to_room(task.room_id)
		if door:
			#D.debug("Porta trovata verso target: " + str(door.global_position))
			move_to(door.global_position)
		else:
			#D.debug("NESSUNA PORTA TROVATA verso " + task.room_id)
			return false
	return false

func _action() -> void:
	#D.debug_order("@")
	#D.debug( human_data.human_name + " inizio azione")
	if task.action == TaskDto.action_enum.JOB:
		#D.debug(human_data.human_name +" deve lavorare")
		_job()

func _job() -> void:
	D.debug_order("@")
	var jobs := get_tree().get_nodes_in_group("job")
	var valid_jobs = []
	
	for node in jobs:
		if node is JobStation:
			if node.required_job == human_data.skills.job and not node.is_busy():
				valid_jobs.append(node)
				
	if valid_jobs.is_empty():
		D.debug(human_data.human_id + ": Nessuna stazione lavoro libera trovata")
		return
		
	target_id = valid_jobs.pick_random()
	D.debug(human_data.human_id + " va a lavorare alla stazione: " + str(target_id.id))
	#D.debug("valid_jobs =" + target_station)
	move_to(target_id.global_position)


func stop() -> void:
	super.stop()
	
	if navigation:
		navigation.set_velocity(Vector2.ZERO)
