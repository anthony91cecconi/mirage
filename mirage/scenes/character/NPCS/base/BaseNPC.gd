extends HumanBody
class_name BaseNPC

# =================================================
# CONFIG
# =================================================
@export var move_speed: float = 120.0
@export var decision_interval := Vector2(1.0, 3.0)
@onready var name_npc: Label = $Label

# =================================================
# AI STATE
# =================================================
var current_goal = null
var _move_dir: Vector2 = Vector2.ZERO
var _timer := 0.0

# =================================================
# READY
# =================================================
func _ready() -> void:
	super._ready()

# =================================================
# PHYSICS
# =================================================
func _physics_process(delta: float) -> void:
	if not _initialized:
		return

	_timer -= delta
	if _timer <= 0.0:
		_pick_next_direction()

	if current_goal == null:
		velocity = _move_dir * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if is_on_wall() and current_goal == null:
		_pick_next_direction()

	#_sync_to_info()

# =================================================
# AI LOGIC
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

# =================================================
# OVERRIDE SETUP
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	super.setup_from_info(info)
	name_npc.text = human_data.human_id
	_pick_next_direction()
