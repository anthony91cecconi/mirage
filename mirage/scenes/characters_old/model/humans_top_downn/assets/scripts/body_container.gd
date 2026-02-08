extends Node2D
class_name BodyContainer

@onready var body: AnimatedSprite2D = $Body
@onready var body_color: AnimatedSprite2D = $Body2

func play(anim: String, flip: bool) -> void:
	#print("[BodyContainer] play", anim)
	body.flip_h = flip
	body_color.flip_h = flip

	if body.animation != anim:
		body.play(anim)
		body_color.play(anim)

func apply_color(color: Color) -> void:
	#print("[BodyContainer] apply_color", color)
	body_color.modulate = color
