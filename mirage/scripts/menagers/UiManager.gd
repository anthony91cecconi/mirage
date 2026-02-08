extends Node

const MOBILE_UI_SCENE := preload("res://android/controls/canvas_layer.tscn")

var _mobile_ui: CanvasLayer = null

func _ready() -> void:
	if not _is_mobile_platform():
		return

	_mobile_ui = MOBILE_UI_SCENE.instantiate() as CanvasLayer
	get_tree().root.add_child(_mobile_ui)
	_mobile_ui.layer = 100

func _is_mobile_platform() -> bool:
	return OS.has_feature("android") or OS.has_feature("ios")
