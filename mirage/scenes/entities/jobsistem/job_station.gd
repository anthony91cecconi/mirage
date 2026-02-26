extends Node2D
class_name JobStation

@export var work_duration : float = randf_range(1.5, 8.0)
@export var required_job : JobManager.job_enum = JobManager.job_enum.MINATORE
@export var id : int
@onready var timerLabel : Label = $Label
@onready var area2d : Area2D = $Area2D
var control : bool = false

var current_worker : HumanBody = null 

func _on_area_2d_body_entered(body: Node2D) -> void:
	if control:
		return
	D.debug(body.get_class() + "ed è humanbody " + str(body is HumanBody) )
	if body is BaseNPC and not is_busy():
		var h : HumanBody = body
		D.debug("body è umano con nome" + h.human_data.human_name)
		if h.human_data.skills.job == required_job and h.target_id and h.target_id.id == id:
			_start_work(body)

func _start_work(npc: BaseNPC) -> void:
	control = true
	current_worker = npc
	D.debug(npc.human_data.human_id + " inizia a lavorare presso " + name)
	
	npc.stop()
	
	var time_left = work_duration

	while time_left > 0:
		if current_worker == null:
			break
			
		timerLabel.text = str(snapped(time_left, 0.1))
		
		await get_tree().process_frame
		time_left -= get_process_delta_time()
	
	timerLabel.text = "" 
	D.debug(npc.human_data.human_id + " ha finito il turno")
	
	current_worker = null
	npc.resume()
	npc._execute_task()

func _on_area_2d_body_exited(_body: Node2D) -> void:
	D.debug_order("@")
	if _body == current_worker:
		current_worker = null
		control = false

func is_busy() -> bool:
	D.debug_order("@")
	return current_worker != null
