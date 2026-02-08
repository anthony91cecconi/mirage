extends CharacterBody2D
class_name BaseNPC

# =================================================
# CONFIG
# =================================================
@export var move_speed: float = 120.0
@export var decision_interval := Vector2(1.0, 3.0)
@onready var name_npc :Label = $Label
# =================================================
# DATA (DTO)
# =================================================
var human_data: HumansInfo = null

# =================================================
# GOAL
# =================================================
var current_goal = null
# null → movimento random
# non null → per ora fermo

# =================================================
# STATE
# =================================================
var _move_dir: Vector2 = Vector2.ZERO
var _timer := 0.0
var _initialized := false

# =================================================
# LIFE CYCLE
# =================================================
func _ready() -> void:
	HumansManager.register_body(human_data.human_id, self)

func _exit_tree() -> void:
	HumansManager.unregister_body(human_data.human_id)

func _physics_process(delta: float) -> void:
	# 🔒 finché non è inizializzato, non fa nulla
	if not _initialized:
		return

	_timer -= delta
	if _timer <= 0.0:
		_pick_next_direction()

	if current_goal == null:
		velocity = _move_dir * move_speed
	else:
		velocity = Vector2.ZERO
		print_debug("NPC goal presente:", current_goal)

	move_and_slide()

	# collision reaction solo se random
	if is_on_wall() and current_goal == null:
		_pick_next_direction()

	_sync_to_info()

# =================================================
# INTERNAL
# =================================================
func _pick_next_direction() -> void:
	_timer = randf_range(decision_interval.x, decision_interval.y)

	if current_goal == null:
		_move_dir = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()
	else:
		_move_dir = Vector2.ZERO

func _reset_after_room_transfer() -> void:
	velocity = Vector2.ZERO
	_move_dir = Vector2.ZERO
	_timer = 0.0

# =================================================
# DTO SYNC (COME IL PLAYER)
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	human_data = info
	global_position = info.position
	_reset_after_room_transfer()
	_initialized = true
	_pick_next_direction()
	D.debug("posizione settata dalle info passate " +   str(human_data.position))
	name_npc.text = human_data.human_id
	
func _sync_to_info() -> void:
	if human_data:
		human_data.position = global_position
