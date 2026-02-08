extends Control
class_name RowMenuEdit

signal submitted(action_id: String, value: String)

@onready var button: Button = $HBoxContainer/Button
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit

var action_id: String

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	line_edit.focus_entered.connect(_on_focus_entered)
	line_edit.focus_exited.connect(_on_focus_exited)


func setup(model: EntitiesMenuModel) -> void:
	action_id = model.id
	button.text = model.text_button
	line_edit.placeholder_text = model.text_placeholder

func _on_button_pressed() -> void:
	submitted.emit(action_id, line_edit.text)

func _on_focus_entered() -> void:
	PlayerManager.lock_movement = true


func _on_focus_exited() -> void:
	PlayerManager.lock_movement = false
