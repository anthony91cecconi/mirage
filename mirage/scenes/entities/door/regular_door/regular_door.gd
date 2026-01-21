extends Node2D
class_name Door

# -------------------------------------------------
# CONFIG
# -------------------------------------------------

@export var lock: bool = false
@export var password: String = ""
@export var limits: bool = false

@export var max_hp: int = 100
@export var hp: int = 100

# autorizzazioni ESATTE (non gerarchiche)
# esempi: "CREW", "MEDICAL", "ENGINEERING"
@export var required_authorities: Array[String] = [
	"CREW",
	"MEDICAL",
	"ENGINEERING"
]

# collisioni
const DOOR_LAYER := 4
const PLAYER_MASK := 1
var selectable : bool = false
@onready var sprite : Sprite2D = $Sprite2D

# -------------------------------------------------
# NODES
# -------------------------------------------------

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_body: StaticBody2D = $StaticBody2D
@onready var area2d: Area2D = $Area2D


# -------------------------------------------------
# STATE
# -------------------------------------------------

var player_inside := false
var is_open := false
var initialized := false


# -------------------------------------------------
# LIFECYCLE
# -------------------------------------------------

func _ready() -> void:
	hp = clamp(hp, 0, max_hp)

	# porta chiusa di default
	door_body.collision_layer = DOOR_LAYER
	door_body.collision_mask = PLAYER_MASK

	if hp <= 0:
		_set_destroyed()
	elif lock:
		anim.animation = "lock"
	else:
		anim.animation =  "open"

	# evita segnali spuri al primo frame
	await get_tree().process_frame
	initialized = true


# -------------------------------------------------
# AREA EVENTS
# -------------------------------------------------

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not initialized:
		return
	if not body.is_in_group("player"):
		return
	if player_inside:
		return

	player_inside = true

	if hp <= 0:
		return

	if lock:
		anim.play("lock")
		return

	if limits and not _is_authorized(body):
		anim.play("limit")
		return

	_open_door()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if not initialized:
		return
	if not body.is_in_group("player"):
		return
	if not player_inside:
		return

	player_inside = false

	if hp <= 0:
		return

	_close_door()


# -------------------------------------------------
# DOOR LOGIC
# -------------------------------------------------

func _open_door() -> void:
	if is_open:
		return

	is_open = true

	door_body.collision_layer = 0
	door_body.collision_mask = 0

	anim.play("open")
	_close_door()


func _close_door() -> void:
	if not is_open:
		return
	if player_inside:
		return
		
	is_open = false

	anim.play("close")
	door_body.collision_layer = DOOR_LAYER
	door_body.collision_mask = PLAYER_MASK



# -------------------------------------------------
# AUTHORIZATION
# -------------------------------------------------

func _is_authorized(body: Node2D) -> bool:
	if not ("human_info" in body):
		return false

	var info = body.get("human_info")
	if info == null:
		return false

	# info.pass : Array[String]
	var passes = info.pass
	if passes == null:
		return false

	for auth in required_authorities:
		if auth in passes:
			return true

	return false


# -------------------------------------------------
# DAMAGE / REPAIR
# -------------------------------------------------

func damage(amount: int) -> void:
	if amount <= 0 or hp <= 0:
		return

	hp = max(hp - amount, 0)

	if hp == 0:
		_destroy()


func repair(amount: int) -> void:
	if amount <= 0 or hp <= 0:
		return

	hp = min(hp + amount, max_hp)


func _destroy() -> void:
	lock = false
	is_open = true
	_set_destroyed()


func _set_destroyed() -> void:
	# sempre aperta
	door_body.collision_layer = 0
	door_body.collision_mask = 0

	# disattiva trigger
	area2d.collision_layer = 0
	area2d.collision_mask = 0

	anim.animation ="destroyed"

func collision_color() -> void:
	sprite.modulate = Color(1, 1, 0) # giallo

func clear_collision_color() -> void:
	sprite.modulate = Color(1, 1, 1) # colore originale

# -------------------------------------------------
# SAVE DATA
# -------------------------------------------------

func get_save_data() -> Dictionary:
	return {
		"hp": hp,
		"max_hp": max_hp,
		"lock": lock,
		"limits": limits,
		"password": password,
		"is_open": is_open,
		"required_authorities": required_authorities.duplicate()
	}

func _on_area_2d_area_entered(area: Area2D) -> void:
	selectable = true
	if area.is_in_group("player"):
		collision_color()


func _on_area_2d_area_exited(area: Area2D) -> void:
	selectable = false
	if area.is_in_group("player"):
		clear_collision_color()
