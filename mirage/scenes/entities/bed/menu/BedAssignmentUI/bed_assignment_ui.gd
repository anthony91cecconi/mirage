extends CanvasLayer

var bed_id : String

@onready var contents : Array[Control] =[
	$Control/VBoxContainer/Content/Assignment,
	$Control/VBoxContainer/Content/Test
] 

@onready var listHumans : Control = $Control/VBoxContainer/Content/Assignment/HBoxContainer/ScrollContainer/ListHumans
var humanLabelScene: PackedScene = preload("res://scenes/entities/bed/menu/BedAssignmentUI/human/human_index.tscn")

signal save

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_tab_bar_tab_changed(0)
	populate_humans_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tab_bar_tab_changed(tab: int) -> void:
	for content in contents:
		content.hide()
	contents[tab].show()


func _on_save_pressed() -> void:
	save.emit()


func _on_unassigned_filter_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func populate_humans_list() -> void:
	for child in listHumans.get_children():
		child.queue_free()

	for human_info in HumansManager.humans:
		var card = humanLabelScene.instantiate()
		listHumans.add_child(card)          # prima entra nell'albero
		card.setup(human_info)              # poi configuri

func close():
	queue_free()
