extends RoomBase

@onready var camera : Camera2D = $Camera2D


func _ready() -> void:
	super._ready()
	CameraMenager.change_camera(CameraMenager.CameraType.ROOM,camera)
