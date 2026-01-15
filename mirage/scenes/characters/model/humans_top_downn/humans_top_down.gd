extends CharacterBody2D
class_name HumansTopDown

# =========================
# CONFIG
# =========================
@export var speed: float = 120.0

# =========================
# NODES
# =========================
@onready var body: AnimatedSprite2D =$BodyContainer/Body
@onready var body_color: AnimatedSprite2D =$BodyContainer/Body2

@onready var helmet_sprite_color: AnimatedSprite2D =$HelmetContainer/Helmet2
@onready var helmet_sprite: AnimatedSprite2D =$HelmetContainer/Helmet
@export var helmet_frames: SpriteFrames
@export var helmet_color_frames: SpriteFrames

@onready var head_sprite_color: AnimatedSprite2D =$HeadContainer/Head2
@onready var head_sprite: AnimatedSprite2D =$HeadContainer/Head
@export var head_frames: SpriteFrames
@export var head_color_frames: SpriteFrames

var human_info : HumansInfo

# =========================
# STATE BOOL
# =========================
@export var npc: bool = false

var idle: bool = true
var walk: bool = false

var top: bool = false
var down: bool = true
var left: bool = false
var right: bool = false

@export var weapon: bool = false
@export var helmet: bool = true

@export var color: Color
# =========================
# MOVEMENT
# =========================
var move_dir: Vector2 = Vector2.ZERO
	
func create_model() -> HumanModel:
	return HumanModel.new(
		helmet_frames,
		helmet_color_frames,
		head_frames,
		head_color_frames,
		weapon,
		helmet,
		color
	)

func set_model(_model : HumanModel) -> void:
	human_info.human_model = _model
	load_from_model()
	
func load_from_model()-> void:
		helmet_frames = human_info.human_model.helmet_frames
		helmet_color_frames = human_info.human_model.helmet_color_frames
		head_frames = human_info.human_model.head_frames
		head_color_frames = human_info.human_model.head_color_frames
		weapon = human_info.human_model.weapon
		helmet = human_info.human_model.helmet
		color = human_info.human_model.color
		apply_assets()
		
func apply_assets() -> void:
	if helmet:
		_apply_helmet_assets()
	else:
		_apply_head_assets()
	
	_apply_color()
	
	
	

func _physics_process(delta: float) -> void:
	_update_movement()
	if not npc: 
		_update_direction_from_mouse()
	_update_idle_walk()
	_play_animation()


# =========================
# MOVIMENTO
# =========================
func _update_movement() -> void:
	velocity = move_dir * speed
	move_and_slide()


# =========================
# DIREZIONE DAL MOUSE
# =========================
func _update_direction_from_mouse() -> void:
	var mouse_pos := get_global_mouse_position()
	var dir := mouse_pos - global_position

	# reset direzioni
	top = false
	down = false
	left = false
	right = false

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			right = true
			print("DIR → RIGHT")
		else:
			left = true
			print("DIR → LEFT")
	else:
		if dir.y > 0:
			down = true
			print("DIR → DOWN")
		else:
			top = true
			print("DIR → TOP")


# =========================
# IDLE / WALK
# =========================
func _update_idle_walk() -> void:
	if move_dir == Vector2.ZERO:
		idle = true
		walk = false
	else:
		idle = false
		walk = true


# =========================
# ANIMATION NAME BUILDER
# =========================
func _build_animation_name() -> String:
	var parts: Array[String] = []

	# DIREZIONE (prioritaria)
	if top:
		parts.append("top")
	elif down:
		parts.append("down")
	elif left:
		parts.append("left")
	elif right:
		parts.append("right")

	# STATO
	if walk:
		parts.append("walk")
	else:
		parts.append("idle")

	# ITEM (opzionale)
	if weapon:
		parts.append("weapon")

	var anim_name := "_".join(parts)

	return anim_name


# =========================
# PLAY ANIMATIONS
# =========================
func _play_animation() -> void:
	var anim := _build_animation_name()

	# BODY (sempre attivo)
	if body.animation != anim:
		print("PLAY BODY →", anim)
		body.play(anim)
		body_color.play(anim)

	if helmet:
		# --- HELMET ON ---
		helmet_sprite.visible = true
		helmet_sprite_color.visible = true

		head_sprite.visible = false
		head_sprite_color.visible = false

		if helmet_sprite.animation != anim:
			print("PLAY HELMET →", anim)
			helmet_sprite.play(anim)
			helmet_sprite_color.play(anim)

	else:
		# --- HEAD ON ---
		head_sprite.visible = true
		head_sprite_color.visible = true

		helmet_sprite.visible = false
		helmet_sprite_color.visible = false

		if head_sprite.animation != anim:
			print("PLAY HEAD →", anim)
			head_sprite.play(anim)
			head_sprite_color.play(anim)



# =========================
# SETTERS PUBBLICI
# =========================
func set_weapon(value: bool) -> void:
	weapon = value

func set_helmet(value: bool) -> void:
	helmet = value
	_play_animation()

func set_color(_color: Color) -> void:
	color = _color
	_apply_color()
	
	
func _apply_color() -> void:
	body_color.modulate = color
	helmet_sprite_color.modulate = color

#-----set head
func _apply_head_assets() -> void:
	print("--------------", create_model() )
	if head_frames:
		head_sprite.sprite_frames = head_frames
	if head_color_frames:
		head_sprite_color.sprite_frames = head_color_frames
	

func _set_head_assets(new :SpriteFrames) -> void:
	head_frames = new
	_apply_head_assets()
	
func _set_head_color_assets(new :SpriteFrames) -> void:
	head_color_frames = new
	_apply_head_assets()

#------ set helmet
func _apply_helmet_assets() -> void:
	if helmet_frames:
		helmet_sprite.sprite_frames = helmet_frames
	if helmet_color_frames:
		helmet_sprite_color.sprite_frames = helmet_color_frames

func _set_helmet_assets(new :SpriteFrames,new_color :SpriteFrames) -> void:
	helmet_frames = new
	helmet_color_frames = new_color
	_apply_helmet_assets()

func setup_from_info(info: HumansInfo) -> void:
	global_position = info.position
	npc = info.human_id != "player"
	human_info = info
	if info.human_model != null:
		set_model(info.human_model)
	apply_assets()

func set_story_position(v : Vector2) -> void:
	human_info.position = v
	
