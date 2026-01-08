extends Node
class_name HumansInfo

var human_name : String
var room : String
var position : Vector2
var bed_id : String
var human_active : bool
var human_id : String

func _init(
	_name: String,
	_room: String,
	_position: Vector2,
	_bed_id: String,
	_active: bool,
	_human_id : String
):
	human_name = _name
	room = _room
	position = _position
	bed_id = _bed_id
	human_active = _active
	human_id = _human_id

static func to_dict(human: HumansInfo) -> Dictionary:
	return {
		"human_name": human.human_name,
		"room": human.room,
		"position": {
			"x": human.position.x,
			"y": human.position.y
		},
		"bed_id": human.bed_id,
		"human_active": human.human_active,
		"human_id": human.human_id
	}


static func from_dict(d: Dictionary) -> HumansInfo:
	var pos := Vector2.ZERO

	if d.has("position") and typeof(d["position"]) == TYPE_DICTIONARY:
		pos = Vector2(
			d["position"].get("x", 0),
			d["position"].get("y", 0)
		)

	return HumansInfo.new(
		d.get("human_name", ""),
		d.get("room", ""),
		pos,
		d.get("bed_id", ""),
		d.get("human_active", true),
		d.get("human_id", "")
	)
