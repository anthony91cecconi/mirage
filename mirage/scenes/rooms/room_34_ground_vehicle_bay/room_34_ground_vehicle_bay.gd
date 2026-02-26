extends RoomBase

func _ready() -> void:
	super._ready()
	D.debug("Room34GroundVehicleBay generatoa")
	CameraMenager.change_camera(CameraMenager.CameraType.ROOM,camera)
