extends Node
class_name HumansInfo

var human_name : String
var room : String
var position : Vector2
var bed_id_assigned : String
var human_active : bool

func _init(
	_name: String,
	_room: String,
	_position: Vector2,
	_bed_id_assigned: String,
	_active: bool
):
	human_name = _name
	room = _room
	position = _position
	bed_id_assigned = _bed_id_assigned
	human_active = _active
