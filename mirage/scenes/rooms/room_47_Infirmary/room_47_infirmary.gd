extends RoomBase


func _ready() -> void:
	D.debug_order("@")
	super._ready()
	CameraMenager.change_camera(CameraMenager.CameraType.ROOM,camera)
	D.debug("Room47Infirmary istanziata" )
