extends CharacterBody2D
class_name CorridorHuman

@export var speed : float = 100.0

@onready var agent : NavigationAgent2D = $NavigationAgent2D

var human_data : HumansInfo
var target_door : ScenesDoor


func _ready() -> void:
	pass


# =================================================
# DTO SETUP
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	human_data = info
	global_position = info.position

	add_to_group("npc")

	await get_tree().process_frame
	choose_random_door()


# =================================================
# DOOR SELECTION
# =================================================
func choose_random_door() -> void:
	var corridor := get_parent()
	var doors : Array = []

	for child in corridor.get_children():
		if child is Node2D:
			for sub in child.get_children():
				if sub is ScenesDoor:
					doors.append(sub)

	if doors.is_empty():
		return

	target_door = doors.pick_random()
	agent.target_position = target_door.global_position


# =================================================
# MOVEMENT
# =================================================
func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_point = agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()

	velocity = direction * speed
	move_and_slide()
