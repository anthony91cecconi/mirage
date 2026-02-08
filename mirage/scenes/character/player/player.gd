extends CharacterBody2D
class_name Player
signal data_ready

# =================================================
# CONFIG
# =================================================
@export var move_speed: float = 200.0

# =================================================
# STATE
# =================================================
var human_data: HumansInfo
var input_dir: Vector2 = Vector2.ZERO
@onready var camera : Camera2D =  $Camera2D

func _ready() -> void:
	CameraMenager.change_camera(CameraMenager.CameraType.PLAYER,camera)
	connect("data_ready", Callable(self, "_on_data_ready"))
	
func _on_data_ready() -> void:
	HumansManager.register_body(human_data.human_id, self)


func _exit_tree() -> void:
	HumansManager.unregister_body(human_data.human_id)

# =================================================
# INPUT (solo decisioni)
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
	# ⚠️ LASCIATA INTEGRA (desktop-friendly)
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
# INPUT ASTRATTO (DESKTOP + ANDROID)
# =================================================
func update_input_direction_from_actions() -> void:
	# 🔥 NUOVA – funziona con tastiera E TouchScreenButton
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
# MOVIMENTO FISICO (MINIMO)
# =================================================
func _physics_process(_delta: float) -> void:
	# 🔥 QUESTO È IL PEZZO CHIAVE PER ANDROID
	update_input_direction_from_actions()

	if input_dir == Vector2.ZERO:
		velocity = Vector2.ZERO
	else:
		velocity = input_dir * move_speed

	move_and_slide()


# =================================================
# TELEPORT / CAMBIO STANZA / LOAD
# =================================================
func set_pos(new_pos: Vector2, new_room: String = "") -> void:
	global_position = new_pos

	if not human_data:
		push_warning("Player.set_pos(): human_data mancante")
		return

	# aggiorna stato locale
	human_data.position = new_pos

	if new_room != "":
		human_data.room = new_room

	# 🔥 aggiorna il singleton
	HumansManager.update_position(human_data.human_id, new_pos)

	if new_room != "":
		HumansManager.update_room(human_data.human_id, new_room)

	# SaveManager.request_save() # facoltativo


# =================================================
# SAVE / LOAD
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	human_data = info
	global_position = info.position
	emit_signal("data_ready")
	reset_after_load()


# =================================================
# DEBUG
# =================================================
func debug_print_position(prefix: String = "") -> void:
	print(
		"%sPosition -> x: %.2f | y: %.2f"
		% [prefix, global_position.x, global_position.y]
	)

func sync_to_info() -> void:
	human_data.position = global_position


func reset_after_load() -> void:
	# 1) reset input + moto
	input_dir = Vector2.ZERO
	velocity = Vector2.ZERO

	# 2) evita uno step fisico con valori sporchi
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

	# 3) opzionale: forza aggiornamento DTO (se lo usi)
	if human_data:
		human_data.position = global_position
