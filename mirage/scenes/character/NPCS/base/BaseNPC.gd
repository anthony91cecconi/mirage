extends HumanBody
class_name BaseNPC

# =================================================
# CONFIG
# =================================================
@export var move_speed: float = 120.0
@export var decision_interval := Vector2(1.0, 3.0)
@onready var name_npc: Label = $Label
@onready var panic_output: Label = $Panic

var panic_state :Dictionary = {
	"sclero": "!@#!##" 
}


# =================================================
# READY
# =================================================
func _ready() -> void:
	super._ready()
	panic_output.text = panic_state.sclero


# =================================================
# OVERRIDE SETUP
# =================================================
func setup_from_info(info: HumansInfo) -> void:
	super.setup_from_info(info)
	name_npc.text = human_data.human_id
