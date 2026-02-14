extends Node2D
class_name ScenesDoor
@export var to_room_id :String
@export var output_spwn : Vector2
@export var id : int 
var rng

func _ready() -> void:
	if id == 0:
		rng = RandomNumberGenerator.new()
		rng.randomize()
		id = rng.randi_range(0, 1000)


func _on_area_2d_body_entered(body: HumanBody) -> void:
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
		body.update_info()
		D.debug(body.human_data.human_id +" pos before free: "+ str(body.global_position))
		D.debug(body.human_data.human_id +" pos before free: "+ str(body.human_data.position))

		body.queue_free()
		
	if body.get_groups().has("player"):
		RoomManager.change_room_id(to_room_id)
	
	if body.get_groups().has("npc"):
		RoomManager.enter_new_npc_in_room(body.human_data.human_id,to_room_id)
