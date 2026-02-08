extends Node2D
class_name HeadContainer

@onready var head_sprite: AnimatedSprite2D = $Head
@onready var head_sprite_color: AnimatedSprite2D = $Head2

@export var head_normal_frames: SpriteFrames
@export var head_normal_color_frames: SpriteFrames

func apply_assets() -> void:
	#print("[HeadContainer] apply_assets")
	if head_normal_frames:
		head_sprite.sprite_frames = head_normal_frames
	if head_normal_color_frames:
		head_sprite_color.sprite_frames = head_normal_color_frames

func play(anim: String, flip: bool) -> void:
	#print("[HeadContainer] play", anim)
	head_sprite.flip_h = flip
	head_sprite_color.flip_h = flip

	if head_sprite.animation != anim:
		head_sprite.play(anim)
		head_sprite_color.play(anim)

func set_frames(frames: SpriteFrames) -> void:
	#print("[HeadContainer] set_frames")
	head_normal_frames = frames
	apply_assets()

func set_color_frames(frames: SpriteFrames) -> void:
	#print("[HeadContainer] set_color_frames")
	head_normal_color_frames = frames
	apply_assets()
