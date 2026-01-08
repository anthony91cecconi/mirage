extends Node2D
class_name Bed

@onready var sprite: Sprite2D =$StaticBody2D/Sprite2D

var bed_info : BedInfo
@export var bed_active : bool
@export var bed_id : String
@export var mental_health_delta :  int
@export var sleep_recovery : int
@export var brocken : bool = false
@export var NPC_ID: String = ""


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
	
	self_load()
	bed_menu.hide()
	select_sprite()

func select_sprite()-> void:
	if bed_info.brocken:
		set_state(BedState.BROKEN)
	elif bed_info.NPC_ID == "":
		set_state(BedState.UNASSIGNED)
	elif occupied:
		set_state(BedState.OCCUPIED)
	else:
		set_state(BedState.IDLE)

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
	print("è il player",bed_info.NPC_ID)
	if  bed_info.NPC_ID and bed_info.NPC_ID == "player" and selectable:
		print("è il player",bed_info.NPC_ID)
		bed_menu.show()
		bed_menu.is_player()
		return
	elif selectable:
		bed_menu.show()
		bed_menu.restart()
		bed_menu.connect("self_assign",self_assign)
	else:
		bed_menu.close_bed_ui()
		bed_menu.hide()

func save_human(human_id : String) -> void:
	bed_info.NPC_ID = human_id
	SaveManager.save_bed(bed_info)

func self_assign() -> void:
	SaveManager.bed_remuve_old_human(PlayerManager.player_info)
	save_human("player")
	PlayerManager.assigned_bed(bed_info.bed_id)
	load_all_beds_in_scene()
	open_menu()

func self_load() -> void:
	LoadManager.load_data()
	print("self load iniziato")
	var memorybed :Dictionary = LoadManager.get_bed(bed_id)
	if memorybed.succes:
		bed_info = memorybed.bed
		print("self_load memoria caricata")
		print("self_load bed id " , bed_info.bed_id," self_load memorybed " , memorybed.bed.NPC_ID," ", "self_load bed_info ",bed_info.NPC_ID )
	else:
		bed_info = BedInfo.new(bed_active,bed_id,mental_health_delta,sleep_recovery,brocken,NPC_ID)
		SaveManager.save_bed(bed_info)
		print("self_load salvato letto nuovo")
	select_sprite()
	open_menu()

func load_all_beds_in_scene() -> void:
	print("lista dei letti recuperata dalla scena ",get_tree().get_nodes_in_group("bed"))
	for bed : Bed in get_tree().get_nodes_in_group("bed"):
		print("prova a ricaricare tutto al letto ",bed.bed_id)
		bed.self_load()
		print("bed.NPC_ID",bed.NPC_ID)
