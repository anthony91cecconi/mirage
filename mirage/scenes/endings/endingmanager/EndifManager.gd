extends Node
class_name EndingManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	D.debug_order("@")
	D.normal("ending manager started")


func control() -> String:
	D.debug_order("@")
	if ending1():
		return "res://scenes/endings/ending1/ending_1.tscn"
	
	return "res://scenes/endings/ending1/ending_1.tscn"

#TODO - implementare regole primo finale reale di gioco
func ending1() -> bool:
	D.debug_order("@")
	return false
