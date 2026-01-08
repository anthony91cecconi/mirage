extends Control

signal self_assign
@onready var box : VBoxContainer = $VBoxContainer
@onready var alternative : Label = $Alternative

var bed_ui_instance: CanvasLayer = null

var bed_ui_scene := preload("res://scenes/entities/bed/menu/BedAssignmentUI/bed_assignment_ui.tscn")


func _on_self_assign_pressed() -> void:
	self_assign.emit()

func is_player() -> void:
	box.hide()
	alternative.text = "is your bed"

func restart()-> void:
	box.show()
	alternative.text = ""

func open_bed_ui() -> void:
	if bed_ui_instance:
		return

	bed_ui_instance = bed_ui_scene.instantiate()
	get_tree().current_scene.add_child(bed_ui_instance)
	bed_ui_instance.connect("save", save)

func close_bed_ui() -> void:
	if bed_ui_instance:
		bed_ui_instance.queue_free()
		bed_ui_instance = null

	
func save()-> void:
	print("salvataggio premuto")
	close_bed_ui()

func _on_assign_pressed() -> void:
	open_bed_ui()
