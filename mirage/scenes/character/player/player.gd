extends HumanBody
class_name Player

# =================================================
# CONFIG
# =================================================
@export var move_speed: float = 200.0
@onready var camera: Camera2D = $Camera2D

var input_dir: Vector2 = Vector2.ZERO

# =================================================
# READY
# =================================================
func _ready() -> void:
	super._ready()
	CameraMenager.change_camera(CameraMenager.CameraType.PLAYER, camera)
	D.debug("player instanziato")

# =================================================
# INPUT
# =================================================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up") \
	or event.is_action_pressed("down") \
	or event.is_action_pressed("left") \
	or event.is_action_pressed("right") \
	or event.is_action_released("up") \
	or event.is_action_released("down") \
	or event.is_action_released("left") \
	or event.is_action_released("right"):
		update_input_direction()
	
	if event.is_action_released("log"):
		debug_print_position("test")

func update_input_direction() -> void:
	input_dir = Vector2.ZERO

	if Input.is_action_pressed("right"):
		input_dir.x += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("down"):
		input_dir.y += 1
	if Input.is_action_pressed("up"):
		input_dir.y -= 1

	input_dir = input_dir.normalized()

# =================================================
# MOVEMENT
# =================================================
func _physics_process(_delta: float) -> void:
	if not _initialized:
		return

	update_input_direction()

	if input_dir == Vector2.ZERO:
		velocity = Vector2.ZERO
	else:
		velocity = input_dir * move_speed

	move_and_slide()
	_sync_to_info()


func debug_print_position(prefix: String = "") -> void:
	print(
		"%sPosition -> x: %.2f | y: %.2f"
		% [prefix, global_position.x, global_position.y]
	)
