extends CharacterBody2D
class_name HumanBody

signal data_ready

# =================================================
# DATA (DTO)
# =================================================
var human_data: HumansInfo = null
var _initialized := false

# =================================================
# LIFECYCLE
# =================================================
func _ready() -> void:
	connect("data_ready", Callable(self, "_on_data_ready"))

func _on_data_ready() -> void:
	if human_data:
		HumansManager.register_body(human_data.human_id, self)
		_initialized = true

func _exit_tree() -> void:
	if human_data:
		HumansManager.unregister_body(human_data.human_id)

# =================================================
# DTO SETUP
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	human_data = info
	global_position = info.position
	emit_signal("data_ready")
	reset_after_load()

func _sync_to_info() -> void:
	if human_data:
		human_data.position = global_position
		#D.debug(human_data.human_id + " sync avvenuto")

# =================================================
# RESET POST LOAD / ROOM TRANSFER
# =================================================
func reset_after_load() -> void:
	velocity = Vector2.ZERO

	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

	if human_data:
		human_data.position = global_position

func update_info() -> void:
	human_data = HumansManager.get_human_by_id(human_data.human_id)
