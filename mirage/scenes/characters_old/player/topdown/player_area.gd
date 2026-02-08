extends Area2D
class_name PlayerArea

var current_target: Area2D = null

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D) -> void:
	# considera SOLO oggetti interagibili
	if not area.is_in_group("interactable"):
		return

	print("ENTER INTERACTABLE:", area)

	current_target = area

	if area.has_method("set_highlighted"):
		area.set_highlighted(true)

func _on_area_exited(area: Area2D) -> void:
	if area != current_target:
		return

	print("EXIT INTERACTABLE:", area)

	if area.has_method("set_highlighted"):
		area.set_highlighted(false)

	current_target = null
