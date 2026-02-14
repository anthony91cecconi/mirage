extends Node
class_name SimulationManager

func _ready() -> void:
	TimeManager.hour_passed.connect(_on_hour_passed)


func _on_hour_passed() -> void:
	_simulate()


func _simulate() -> void:
	var offscreen := HumansManager.get_offscreen_humans()

	for h in offscreen:
		if h.offscreen_behaviour:
			h.offscreen_behaviour.simulate(h, 1.0)
