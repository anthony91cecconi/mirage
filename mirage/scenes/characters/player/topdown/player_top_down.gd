extends Node2D

@onready var human: HumansTopDown = $HumansTopDown
@onready var camera: Camera2D = $CameraTopDownPlayer


func _ready() -> void:
	human.npc = false
	print("PLAYER READY")


func _process(delta: float) -> void:
	_handle_input()


# =========================
# INPUT MOVIMENTO
# =========================
func _handle_input() -> void:
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	human.move_dir = dir.normalized()

	if dir == Vector2.ZERO:
		print("INPUT → STOP")
	else:
		print("INPUT → MOVE:", human.move_dir)


# =========================
# ESEMPI USO ITEM
# =========================
func equip_weapon():
	human.set_weapon(true)

func unequip_weapon():
	human.set_weapon(false)

func remove_helmet():
	human.set_helmet(false)

func wear_helmet():
	human.set_helmet(true)

func setup_from_info(human_info: HumansInfo) -> void:
	print("siamo qui")
	human.setup_from_info(human_info)
	print("siamo la")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("Premuto E")
