extends Node2D

@onready var human: HumansTopDown = $HumansTopDown
@onready var camera: Camera2D = $CameraTopDownPlayer

func _ready() -> void:
	human.npc = false
	#print("PLAYER READY")

func _process(delta: float) -> void:
	_handle_input()

func _handle_input() -> void:
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	human.move_dir = dir.normalized()

func equip_weapon():
	human.set_weapon(true)

func unequip_weapon():
	human.set_weapon(false)

func remove_helmet():
	human.set_helmet(false)

func wear_helmet():
	human.set_helmet(true)

func setup_from_info(human_info: HumansInfo) -> void:
	human.setup_from_info(human_info)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			human.helmet.set_light()
