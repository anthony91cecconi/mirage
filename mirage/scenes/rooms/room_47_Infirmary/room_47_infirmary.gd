extends RoomBase


func _ready() -> void:
	super._ready()
	CameraMenager.change_camera(CameraMenager.CameraType.ROOM,camera)
	D.debug("Room47Infirmary istanziata" )
