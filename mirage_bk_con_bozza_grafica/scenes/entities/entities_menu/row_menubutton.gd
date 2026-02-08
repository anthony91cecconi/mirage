extends Control
class_name RowMenubutton

signal pressed(action_id: String)

@onready var button: Button = $Button

var action_id: String


func setup(model: EntitiesMenuModel) -> void:
	action_id = model.id
	button.text = model.text_button


func _on_button_pressed() -> void:
	pressed.emit(action_id)
