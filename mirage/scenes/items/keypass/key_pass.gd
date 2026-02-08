extends Area2D
class_name KeyPass

@onready var sprite: Sprite2D = $Sprite2D

var player_inside: Node = null

func _ready() -> void:
	# fondamentale per ricevere click
	input_pickable = true

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = body
	_make_red()

func _on_body_exited(body: Node) -> void:
	if body != player_inside:
		return

	player_inside = null
	_clear_red()

# ✅ Questo è il pezzo che ti mancava: callback diretto
func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if player_inside == null:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("CLICK SU KEY PASS")

		if player_inside.has_method("pickup_pass"):
			player_inside.pickup_pass()
			queue_free()

# -------------------------
# VISUAL
# -------------------------

func _make_red() -> void:
	if sprite:
		sprite.modulate = Color.RED

func _clear_red() -> void:
	if sprite:
		sprite.modulate = Color.WHITE
