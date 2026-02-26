extends Resource
class_name HumansInfo

var human_name : String
var room : String
var scena : String
var position : Vector2
var human_id : String
var active : bool
var beavior : String
var skills : Skills
var move_speed : float

func _init(
	_name: String,
	_room: String,
	_scena: String,
	_position: Vector2,
	_human_id : String,
	_active : bool,
	_beavior : String,
	_skills : Skills,
	_move_speed : float
):
	D.debug_order("@")
	human_name = _name
	room = _room
	scena = _scena
	position = _position
	human_id = _human_id
	active = _active
	beavior = _beavior
	skills = _skills
	move_speed =_move_speed

func to_dict() -> Dictionary:	
	D.debug_order("@")
	return {
		"human_name": human_name,
		"room": room,
		"scena": scena,
		"position": {
			"x": position.x,
			"y": position.y
		},
		"human_id": human_id,
		"active" : active,
		"beavior" : beavior,
		"skills" : skills,
		"move_speed" : move_speed 
	}


static func from_dict(d: Dictionary) -> HumansInfo:
	D.debug_order("@")
	var pos := Vector2.ZERO

	if d.has("position") and typeof(d["position"]) == TYPE_DICTIONARY:
		pos = Vector2(
			d["position"].get("x", 0.0),
			d["position"].get("y", 0.0)
		)

	var skill = Skills.from_dict(d.get("skils"))

	return HumansInfo.new(
		d.get("human_name", ""),
		d.get("room", ""),
		d.get("scena",""),
		pos,
		d.get("human_id", ""),
		d.get("active",false),
		d.get("beavior"),
		skill,
		d.get("move_speed" , 120.0)
	)

func set_position(pos: Vector2) -> void:
	D.debug_order("@")
	position = pos
	D.debug(human_id +": set position completo, nuova position è: "+ str(position) )

func set_room(_room : String) -> void:
	D.debug_order("@")
	room = _room
	D.debug(human_id +": set room completo, nuova room è :" + room)
