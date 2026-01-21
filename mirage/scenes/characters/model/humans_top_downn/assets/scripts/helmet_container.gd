extends Node2D
class_name HelmetContainer

@onready var helmet_sprite: AnimatedSprite2D = $Helmet
@onready var helmet_sprite_color: AnimatedSprite2D = $Helmet2
@onready var light : PointLight2D = $PointLight2D
@export var helmet_normal_frames: SpriteFrames
@export var helmet_normal_color_frames: SpriteFrames
@export var helmet: bool = true
@export var light_bool: bool = false
@export var light_enabled := true
@export var light_energy := 2.0
@export var light_scale := Vector2(3.0, 2.0) # lunghezza / apertura


func _ready() -> void:
	_setup_light()

func _setup_light() -> void:
	if not light:
		return

	light.enabled = light_enabled
	light.energy = light_energy
	light.scale = light_scale
	light.position = Vector2.ZERO


func apply_assets() -> void:
	#print("[HelmetContainer] apply_assets")
	if helmet_normal_frames:
		helmet_sprite.sprite_frames = helmet_normal_frames
	if helmet_normal_color_frames:
		helmet_sprite_color.sprite_frames = helmet_normal_color_frames

func play(anim: String, flip: bool, visible: bool) -> void:
	#print("[HelmetContainer] play", anim, "visible:", visible)

	if not visible:
		hide()
		return

	show()
	helmet_sprite.flip_h = flip
	helmet_sprite_color.flip_h = flip

	if helmet:
		if helmet_sprite.animation != anim:
			helmet_sprite.play(anim)
			helmet_sprite_color.play(anim)
	else:
		helmet_sprite.stop()
		helmet_sprite_color.stop()

func set_assets(frames: SpriteFrames, color_frames: SpriteFrames) -> void:
	#print("[HelmetContainer] set_assets")
	helmet_normal_frames = frames
	helmet_normal_color_frames = color_frames
	apply_assets()

func set_look_dir(dir: int) -> void:
	var rot := 0.0

	match dir:
		0: rot = 90    # DOWN
		1: rot = 135   # DOWN_LEFT
		2: rot = 180   # LEFT
		3: rot = 225   # TOP_LEFT
		4: rot = 270   # TOP
		5: rot = 315   # TOP_RIGHT
		6: rot = 0     # RIGHT
		7: rot = 45    # DOWN_RIGHT

	light.rotation = deg_to_rad(rot)

func set_light() -> void:
	light_bool = !light_bool
	light.enabled = light_bool

func set_light_enabled(value: bool) -> void:
	light_enabled = value
	if light:
		light.enabled = value

func set_light_shape(length: float, width: float) -> void:
	if light:
		light.scale = Vector2(length, width)
