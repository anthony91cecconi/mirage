extends Node

var humans: Array[HumansInfo] = []


#TODO: funzione per assegnare il letto agli NPC
#TODO: inglobare logica anche per il player
func assign_bed(_human_id : String, _bed_id : String) -> void:
	for h in  humans:
		if h.get("human_id") == _human_id:
			SaveManager
