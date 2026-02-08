extends Node2D
class_name ScenesDoor
@export var to_room_id :String
@export var output_spwn : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	D.debug("entrato nella porta")
	D.debug(str(body.get_groups()))
	D.debug("direzione "+to_room_id+" "+str(output_spwn))
	if body.get_groups().has("player") or body.get_groups().has("npc"):
		body.human_data.position = output_spwn
		body.human_data.room = to_room_id

		HumansManager.update_position(
			body.human_data.human_id,
			output_spwn
		)
		HumansManager.update_room(
			body.human_data.human_id,
			to_room_id
		)
		body.queue_free()
		
	#SaveManager.save_game()
	if body.get_groups().has("player"):
		RoomManager.change_room_id(to_room_id)
	
	if body.get_groups().has("npc"):
		RoomManager.enter_new_npc_in_room(body.human_data.human_id,to_room_id)
