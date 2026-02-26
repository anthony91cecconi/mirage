extends RefCounted
class_name PrioritySystem
var skills : Skills


func _init(_skills  :Skills) -> void:
	D.debug_order("@")
	skills = _skills


func generate_new_task() -> TaskDto:
	D.debug_order("@")
	var task : TaskDto = TaskDto.new()
	
	if skills.work_room_id:
		task.room_id = skills.work_room_id
	
	if skills.job:
		task.action = task.action_enum.JOB
	
	return task
