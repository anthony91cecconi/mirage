extends CharacterBody2D
class_name HumansTopDown

# =========================
# CONFIG
# =========================
@export var speed: float = 120.0
@export var helmet_bool : bool = true
@export var npc: bool = false

@onready var body : BodyContainer = $BodyContainer
@onready var helmet : HelmetContainer = $HelmetContainer
@onready var head : HeadContainer = $HeadContainer

var human_info: HumansInfo
var color : Color = Color.WHITE

# =========================
# ENUM DIREZIONI
# =========================
enum LookDir {
	DOWN,
	DOWN_LEFT,
	LEFT,
	TOP_LEFT,
	TOP,
	TOP_RIGHT,
	RIGHT,
	DOWN_RIGHT
}

# =========================
# STATE
# =========================
var idle := true
var walk := false
var move_dir: Vector2 = Vector2.ZERO

var body_dir: LookDir = LookDir.DOWN
var helmet_dir: LookDir = LookDir.DOWN
var last_move_dir: LookDir = LookDir.DOWN

# =========================================================
# MODEL
# =========================================================
func create_model() -> HumanModel:
	D.debug_order("@")
	#print("[HumansTopDown] create_model")
	return HumanModel.new(
		helmet.helmet_normal_frames,
		helmet.helmet_normal_color_frames,
		head.head_normal_frames,
		head.head_normal_color_frames,
		false, # weapon TODO
		helmet_bool,
		color
	)

func set_model(model: HumanModel) -> void:
	D.debug_order("@")
	#print("[HumansTopDown] set_model")
	human_info.human_model = model
	load_from_model()

func load_from_model() -> void:
	D.debug_order("@")
	#print("[HumansTopDown] load_from_model")
	var m := human_info.human_model
	if m == null:
		#print(" model is NULL")
		return

	helmet.helmet_normal_frames = m.helmet_normal_frames
	helmet.helmet_normal_color_frames = m.helmet_normal_color_frames
	head.head_normal_frames = m.head_normal_frames
	head.head_normal_color_frames = m.head_normal_color_frames

	helmet_bool = m.helmet
	color = m.color

	apply_assets()

func apply_assets() -> void:
	D.debug_order("@")
	#print("[HumansTopDown] apply_assets helmet:", helmet_bool)

	# ✅ applica SEMPRE gli asset
	helmet.apply_assets()
	head.apply_assets()

	# ✅ poi decidi cosa mostrare
	if helmet_bool:
		helmet.show()
		head.hide()
	else:
		helmet.hide()
		head.show()

	_apply_color()


# =========================================================
# PROCESS
# =========================================================
func _physics_process(delta: float) -> void:
	_update_movement()
	_update_body_direction()

	if not npc:
		_update_helmet_from_mouse()

	_update_idle_walk()
	_play_animation()

# =========================
# MOVIMENTO
# =========================
func _update_movement() -> void:
	D.debug_order("@")
	velocity = move_dir * speed
	move_and_slide()

# =========================
# BODY DIRECTION
# =========================
func _update_body_direction() -> void:
	D.debug_order("@")
	if move_dir == Vector2.ZERO:
		body_dir = last_move_dir
		return

	body_dir = _vector_to_dir(move_dir)
	last_move_dir = body_dir

# =========================
# HELMET FROM MOUSE
# =========================
func _update_helmet_from_mouse() -> void:
	D.debug_order("@")
	var dir := get_global_mouse_position() - global_position
	var wanted := _vector_to_dir(dir)
	helmet_dir = _limit_helmet_dir(wanted, body_dir)
	helmet.set_look_dir(helmet_dir)


# =========================
# LIMIT HELMET
# =========================
func _limit_helmet_dir(wanted: LookDir, body_allow: LookDir) -> LookDir:
	D.debug_order("@")
	var allowed := {
		LookDir.TOP: [LookDir.TOP, LookDir.TOP_LEFT, LookDir.TOP_RIGHT, LookDir.LEFT, LookDir.RIGHT],
		LookDir.DOWN: [LookDir.DOWN, LookDir.DOWN_LEFT, LookDir.DOWN_RIGHT, LookDir.LEFT, LookDir.RIGHT],
		LookDir.LEFT: [LookDir.LEFT, LookDir.TOP_LEFT, LookDir.DOWN_LEFT, LookDir.TOP, LookDir.DOWN],
		LookDir.RIGHT: [LookDir.RIGHT, LookDir.TOP_RIGHT, LookDir.DOWN_RIGHT, LookDir.TOP, LookDir.DOWN],
		LookDir.TOP_LEFT: [LookDir.LEFT, LookDir.TOP_LEFT, LookDir.TOP, LookDir.TOP_RIGHT, LookDir.DOWN_LEFT],
		LookDir.TOP_RIGHT: [LookDir.RIGHT, LookDir.TOP, LookDir.TOP_RIGHT, LookDir.DOWN_LEFT, LookDir.DOWN_RIGHT],
		LookDir.DOWN_LEFT: [LookDir.DOWN_LEFT, LookDir.LEFT, LookDir.DOWN, LookDir.TOP_LEFT, LookDir.DOWN_RIGHT],
		LookDir.DOWN_RIGHT: [LookDir.DOWN_RIGHT, LookDir.RIGHT, LookDir.DOWN, LookDir.DOWN_LEFT, LookDir.TOP_RIGHT]
	}

	if body_allow in allowed and wanted in allowed[body_allow]:
		return wanted

	return body_allow

# =========================
# IDLE / WALK
# =========================
func _update_idle_walk() -> void:
	D.debug_order("@")
	idle = move_dir == Vector2.ZERO
	walk = not idle

# =========================
# ANIMATION NAME
# =========================
func _build_animation_name(dir: LookDir) -> String:
	D.debug_order("@")
	var base :String= [
		"down","down_left","left","top_left",
		"top","top_right","right","down_right"
	][dir]

	if walk:
		base += "_walk" 
	else:
		base += "_idle"

	return base

func _flip(dir: LookDir) -> bool:
	D.debug_order("@")
	return dir in [LookDir.TOP_RIGHT, LookDir.RIGHT, LookDir.DOWN_RIGHT]

# =========================
# PLAY
# =========================
func _play_animation() -> void:
	D.debug_order("@")
	var anim_body := _build_animation_name(body_dir)
	var anim_head := _build_animation_name(helmet_dir)

	#print("[HumansTopDown] play", anim_body, anim_head)

	body.play(anim_body, _flip(body_dir))
	head.play(anim_head, _flip(helmet_dir))
	helmet.play(anim_head, _flip(helmet_dir), helmet_bool)

# =========================
# UTILS
# =========================
func _vector_to_dir(v: Vector2) -> LookDir:
	D.debug_order("@")
	var angle := rad_to_deg(v.angle())
	if angle < 0: angle += 360

	if angle < 22.5 or angle >= 337.5: return LookDir.RIGHT
	elif angle < 67.5: return LookDir.DOWN_RIGHT
	elif angle < 112.5: return LookDir.DOWN
	elif angle < 157.5: return LookDir.DOWN_LEFT
	elif angle < 202.5: return LookDir.LEFT
	elif angle < 247.5: return LookDir.TOP_LEFT
	elif angle < 292.5: return LookDir.TOP
	else: return LookDir.TOP_RIGHT

# =========================
# SETTERS
# =========================
func set_helmet(value: bool) -> void:
	D.debug_order("@")
	#print("[HumansTopDown] set_helmet", value)
	helmet_bool = value
	apply_assets()

func set_color(c: Color) -> void:
	D.debug_order("@")
	#print("[HumansTopDown] set_color", c)
	color = c
	_apply_color()

func _apply_color() -> void:
	D.debug_order("@")
	body.apply_color(color)
	helmet.helmet_sprite_color.modulate = color

# =========================
# SETUP
# =========================
func setup_from_info(info: HumansInfo) -> void:
	D.debug_order("@")
	#print("[HumansTopDown] setup_from_info")
	human_info = info
	global_position = info.position
	npc = info.human_id != "player"

	if info.human_model:
		set_model(info.human_model)


func pickup_pass() -> void:
	D.debug_order("@")
	print("PASS RACCOLTO")
