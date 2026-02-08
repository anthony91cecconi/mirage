extends Node2D

@onready var human: HumansTopDown = $HumansTopDown
@onready var camera: Camera2D = $CameraTopDownPlayer

func _ready() -> void:
	human.npc = false

func _process(delta: float) -> void:
	_handle_movement()

func _handle_movement() -> void:
	if PlayerManager.lock_movement:
		human.move_dir = Vector2.ZERO
		return

	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	human.move_dir = dir.normalized()
