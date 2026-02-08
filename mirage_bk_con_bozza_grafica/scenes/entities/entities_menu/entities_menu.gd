extends Control
class_name EntitiesMenu

signal action_pressed(action_id: String)
signal input_submitted(action_id: String, value: String)

@onready var list: VBoxContainer = $VBoxContainer

@export var row_button_scene: PackedScene = preload("res://scenes/entities/entities_menu/row_menubutton.tscn")
@export var row_input_scene: PackedScene = preload("res://scenes/entities/entities_menu/row_menu_edit.tscn")


func open(models: Array[EntitiesMenuModel]) -> void:
	show()
	clear()
	for model in models:
		match model.button_type:
			EntitiesMenuModel.ButtonType.ACTION:
				_create_action_row(model)
			EntitiesMenuModel.ButtonType.INPUT:
				_create_input_row(model)
	print("open ok")



func clear() -> void:
	for child in list.get_children():
		child.queue_free()
	print("clear ok")


func _create_action_row(model: EntitiesMenuModel) -> void:
	var row: RowMenubutton = row_button_scene.instantiate()
	list.add_child(row)
	
	row.setup(model)
	row.connect("pressed", _on_action_pressed)
	print("create_action_row ok")


func _create_input_row(model: EntitiesMenuModel) -> void:
	var row := row_input_scene.instantiate()
	list.add_child(row)

	row.setup(model)
	row.connect("submitted", _on_input_submitted)
	print("create_inpu_row ok")


func _on_action_pressed(action_id: String) -> void:
	action_pressed.emit(action_id)
	close()
	print("on_action_pressed")

func _on_input_submitted(action_id: String, value: String) -> void:
	input_submitted.emit(action_id, value)
	# qui NON chiudo forzatamente: decidi tu se farlo o no
	print("on_input_submitted")


func close() -> void:
	print("CLOSE CHIAMATO")
	hide()
	clear()
