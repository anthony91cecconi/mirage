extends Node2D

@export var head_no_helmet_path: String = ""

@onready var human: HumansTopDown = $HumansTopDown
@onready var camera: Camera2D = $CameraTopDownPlayer

func _ready():
	_setup_head()

func _process(delta):
	_handle_input()

# =========================
# INPUT
# =========================

func _handle_input():
	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	human.move_dir = dir.normalized()

# =========================
# TESTA SENZA CASCO
# =========================

func _setup_head():
	if head_no_helmet_path == "":
		human.has_helmet = true
		return

	if not ResourceLoader.exists(head_no_helmet_path):
		human.has_helmet = true
		return

	var frames := load(head_no_helmet_path)
	if frames is SpriteFrames:
		human.set_head_override(frames)
	else:
		human.has_helmet = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if area.is_in_group("entities"):
		print(area.get_parent())
