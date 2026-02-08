extends Control

var humanData: HumansInfo

@onready var has_bed: ColorRect = $HasBed
@onready var name_label: Label = $Name

func setup(data: HumansInfo) -> void:
	humanData = data
	if is_node_ready():
		_apply()
	else:
		call_deferred("_apply")  # aspetta che gli @onready siano pronti

func _ready() -> void:
	if humanData != null:
		_apply()


func _apply() -> void:
	# ⚠️ Usa i NOMI REALI delle tue proprietà.
	# Se la tua HumansInfo ha "active" e non "human_active", cambia qui.
	if not humanData.human_active:
		hide()
		return

	has_bed.color = Color.RED if humanData.bed_id.is_empty() else Color.GREEN
	name_label.text = humanData.human_name  # oppure humanData.name, in base alla tua classe
