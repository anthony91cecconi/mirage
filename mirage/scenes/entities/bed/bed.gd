extends Node2D

@onready var sprite: Sprite2D =$StaticBody2D/Sprite2D

@export var bed_info : BedInfo

enum BedState {
	IDLE,
	OCCUPIED,
	BROKEN,
	UNASSIGNED
}

const REGIONS := {
	BedState.IDLE: Rect2(28, 31, 239, 369),
	BedState.OCCUPIED: Rect2(300, 30, 247, 370),
	BedState.BROKEN: Rect2(574, 38, 244, 357),
	BedState.UNASSIGNED: Rect2(843, 38, 259, 357),
}

var selectable : bool = false

@onready var bed_menu : Control = $BedMenu

var occupied : bool = false

func set_state(state: BedState) -> void:
	sprite.region_rect = REGIONS[state]

func _ready() -> void:
	bed_menu.hide()
	if bed_info.brocken:
		print("impostato letto rotto")
		set_state(BedState.BROKEN)
	elif bed_info.NPC_ID == "":
		set_state(BedState.UNASSIGNED)
		print("impostato non assegnato")
	elif occupied:
		set_state(BedState.OCCUPIED)
		print("impostato occupato")
	else:
		set_state(BedState.IDLE)
		print("impostato vuoto e assegnato")

func collision_color() -> void:
	sprite.modulate = Color(1, 1, 0) # giallo


func clear_collision_color() -> void:
	sprite.modulate = Color(1, 1, 1) # colore originale


func _on_area_2d_area_entered(area: Area2D) -> void:
	selectable = true
	if area.is_in_group("player"):
		collision_color()


func _on_area_2d_area_exited(area: Area2D) -> void:
	selectable = false
	if area.is_in_group("player"):
		clear_collision_color()
		open_menu()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and selectable:
		open_menu()

func open_menu() -> void:
	if selectable:
		bed_menu.show()
	else:
		bed_menu.hide()
