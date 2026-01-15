extends CanvasLayer

@export var all_face_frames: Array[SpriteFrames]
@export var all_hair_frames: Array[SpriteFrames]

@export var all_helm_frames: Array[SpriteFrames]
@export var all_helm_color_frames: Array[SpriteFrames]

@onready var human: HumansTopDown = $HumanContainer/Container/HumansTopDown

@onready var slider_r: HSlider = $TextureRect/Control/Colors/TextureRect/Red
@onready var slider_g: HSlider = $TextureRect/Control/Colors/TextureRect/Green
@onready var slider_b: HSlider = $TextureRect/Control/Colors/TextureRect/Blue

@onready var hair_container : Control = $HumanContainer/Container/VBoxContainer/Hair
@onready var face_container : Control = $HumanContainer/Container/VBoxContainer/Face
@onready var helmet_container : Control = $HumanContainer/Container/VBoxContainer/Helmet

@onready var player_name : LineEdit = $TextureRect/Control/TextureRect/Name

func _ready() -> void:
	_on_helmet_button_toggled(true)
	slider_r.value = 1.0
	slider_g.value = 1.0
	slider_b.value = 1.0

	_apply_color()


# Questo metodo collegalo a TUTTI e 3 gli slider (value_changed)
func _on_color_slider_changed(value: float) -> void:
	_apply_color()


func _apply_color() -> void:
	var color := Color(
		slider_r.value,
		slider_g.value,
		slider_b.value
	)

	human.set_color(color)


func _on_red_value_changed(value: float) -> void:
	_on_color_slider_changed(value)


func _on_green_value_changed(value: float) -> void:
	_on_color_slider_changed(value)


func _on_blue_value_changed(value: float) -> void:
	_on_color_slider_changed(value)


func _on_helmet_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$TextureRect/Control/Colors/Helmet/HelmetLabel.text = "helmet"
		human.set_helmet(toggled_on)
		hair_container.hide()
		face_container.hide()
		helmet_container.show()
		return
	
	human.set_helmet(toggled_on)
	$TextureRect/Control/Colors/Helmet/HelmetLabel.text = "head"
	hair_container.show()
	face_container.show()
	helmet_container.hide()


var current_hair_index: int = 0
var current_face_index: int = 0

func _on_hair_left_pressed() -> void:
	if all_hair_frames.is_empty():
		return

	current_hair_index -= 1
	if current_hair_index < 0:
		current_hair_index = all_hair_frames.size() - 1

	var frames := all_hair_frames[current_hair_index]

	human._set_head_color_assets(frames)



func _on_hair_right_pressed() -> void:
	if all_hair_frames.is_empty():
		return

	current_hair_index += 1
	if current_hair_index >= all_hair_frames.size():
		current_hair_index = 0

	var frames := all_hair_frames[current_hair_index]

	human._set_head_color_assets(frames)



func _on_face_left_pressed() -> void:
	if all_face_frames.is_empty():
		return

	current_face_index -= 1
	if current_face_index < 0:
		current_face_index = all_face_frames.size() - 1

	var frames := all_face_frames[current_face_index]

	human._set_head_assets(frames)



func _on_face_right_pressed() -> void:
	if all_face_frames.is_empty():
		return

	current_face_index += 1
	if current_face_index >= all_face_frames.size():
		current_face_index = 0

	var frames := all_face_frames[current_face_index]

	human._set_head_assets(frames)



var current_helm_index: int = 0
func _on_helmet_left_pressed() -> void:
	if all_helm_frames.is_empty() or all_helm_color_frames.is_empty():
		return

	current_helm_index -= 1
	if current_helm_index < 0:
		current_helm_index = all_helm_frames.size() - 1

	var frames := all_helm_frames[current_helm_index]
	var frames_color := all_helm_color_frames[current_helm_index]

	human._set_helmet_assets(frames,frames_color)


func _on_helmet_right_pressed() -> void:
	if all_helm_frames.is_empty() or all_helm_color_frames.is_empty():
		return

	current_helm_index += 1
	if current_helm_index >= all_helm_frames.size():
		current_helm_index = 0

	var frames := all_helm_frames[current_helm_index]
	var frames_color := all_helm_color_frames[current_helm_index]

	human._set_helmet_assets(frames,frames_color)


func _on_save_pressed() -> void:
	if player_name.text == "":
		$TextureRect/Control/TextureRect/ColorRect.show()
		return
	var player : HumansInfo = HumansInfo.new(
		player_name.text,
		"",
		Vector2.ZERO,
		"001",
		true,
		"player",
		human.create_model()
	)
	
	SaveManager.save_player(player)
