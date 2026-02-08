extends Node
class_name EntitiesMenuModel

enum ButtonType {
	ACTION,
	INPUT
}

var id: String
var text_button: String
var text_placeholder: String = ""
var button_type: ButtonType

func _init(_id: String,_text_button: String,_text_placeholder: String, _button_type: ButtonType) -> void:
	id =_id
	text_button =_text_button
	text_placeholder =_text_placeholder
	button_type =_button_type
