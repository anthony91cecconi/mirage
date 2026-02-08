extends Resource
class_name HumansInfo

var human_name : String
var room : String
var scena : String
var position : Vector2
var human_id : String
var active : bool

func _init(
	_name: String,
	_room: String,
	_scena: String,
	_position: Vector2,
	_human_id : String,
	_active
):
	human_name = _name
	room = _room
	scena = _scena
	position = _position
	human_id = _human_id
	active = _active

func to_dict() -> Dictionary:
	return {
		"human_name": human_name,
		"room": room,
		"scena": scena,
		"position": {
			"x": position.x,
			"y": position.y
		},
		"human_id": human_id,
		"active" : active
	}


static func from_dict(d: Dictionary) -> HumansInfo:
	var pos := Vector2.ZERO

	if d.has("position") and typeof(d["position"]) == TYPE_DICTIONARY:
		pos = Vector2(
			d["position"].get("x", 0.0),
			d["position"].get("y", 0.0)
		)

	return HumansInfo.new(
		d.get("human_name", ""),
		d.get("room", ""),
		d.get("scena",""),
		pos,
		d.get("human_id", ""),
		d.get("active",false)
	)

func set_position(pos: Vector2) -> void:
	position = pos
