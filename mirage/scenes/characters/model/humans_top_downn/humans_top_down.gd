extends CharacterBody2D
class_name HumansTopDown

@export var speed: float = 120.0
@export var has_helmet: bool = true

@onready var body: AnimatedSprite2D = $Body
@onready var head: AnimatedSprite2D = $Head
@onready var ray_cast_2d : RayCast2D = $RayCast2D

var last_dir: String = "down"


var move_dir: Vector2 = Vector2.ZERO
var is_dead: bool = false

func _ready():
	_apply_head_source()
	_play_idle("down")

func _physics_process(delta):
	if is_dead:
		velocity = Vector2.ZERO
		return

	velocity = move_dir * speed
	move_and_slide()

	_update_animation()

# =========================
# ANIMAZIONI
# =========================

func _update_animation():
	if move_dir == Vector2.ZERO:
		_play_idle(last_dir)
		_update_raycast_direction()
		return

	if abs(move_dir.x) > abs(move_dir.y):
		if move_dir.x > 0:
			last_dir = "right"
			_set_flip(false)
		else:
			last_dir = "left"
			_set_flip(true)
	else:
		if move_dir.y > 0:
			last_dir = "down"
		else:
			last_dir = "top"

	_play_walk(last_dir)
	_update_raycast_direction()


func _play_idle(dir: String):
	if dir == "left":
		dir = "right"
	body.play(dir)
	head.play(dir)

func _play_walk(dir: String):
	#non dispongo attualmente delle animazioni verso sinistra dedicate, uso quelle di destra con il flip attivo
	if dir == "left":
		dir = "right"
	body.play("go_" + dir)
	head.play("go_" + dir)

func _set_flip(value: bool):
	body.flip_h = value
	head.flip_h = value

# =========================
# TESTA / CASCO
# =========================

func set_head_override(sprite_frames: SpriteFrames):
	if sprite_frames == null:
		has_helmet = true
		_apply_head_source()
		return

	has_helmet = false
	head.sprite_frames = sprite_frames

func _apply_head_source():
	if has_helmet:
		# usa le SpriteFrames già assegnate in scena (casco)
		return

# =========================
# MORTE
# =========================

func die():
	if is_dead:
		return

	is_dead = true
	body.play("die")
	head.play("die")


func _update_raycast_direction():
	match last_dir:
		"right":
			ray_cast_2d.target_position = Vector2(35, 0)
		"left":
			ray_cast_2d.target_position = Vector2(-35, 0)
		"down":
			ray_cast_2d.target_position = Vector2(0, 45)
		"top":
			ray_cast_2d.target_position = Vector2(0, -45)
