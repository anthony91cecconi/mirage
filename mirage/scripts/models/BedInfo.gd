extends Node
class_name BedInfo

var bed_active : bool
var bed_id : String
var mental_health_delta :  int
var sleep_recovery : int
var brocken : bool = false
var NPC_ID: String = ""

func _init(_bed_active : bool,_bed_id : String,_mental_health_delta :  int,_sleep_recovery : int, _brocken : bool ,_NPC_ID: String) -> void:
	bed_active = _bed_active
	bed_id =_bed_id
	mental_health_delta = _mental_health_delta
	sleep_recovery = _sleep_recovery
	brocken = _brocken
	NPC_ID = _NPC_ID


static func to_dict(bed: BedInfo) -> Dictionary:
	return {
		"bed_active": bed.bed_active,
		"bed_id": bed.bed_id,
		"mental_health_delta": bed.mental_health_delta,
		"sleep_recovery": bed.sleep_recovery,
		"brocken": bed.brocken,
		"NPC_ID":bed.NPC_ID
	}


static func from_dict(d: Dictionary) -> BedInfo:
	return BedInfo.new(
		d.get("bed_active", ""),
		d.get("bed_id", ""),
		d.get("mental_health_delta", ""),
		d.get("sleep_recovery", true),
		d.get("brocken", false),
		d.get("NPC_ID", "")
	)

func has_id() -> bool:
	if not bed_id.is_empty() and not bed_id == "":
		return true
	return false 
