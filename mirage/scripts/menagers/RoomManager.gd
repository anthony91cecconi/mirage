extends Node

# =================================================
# STATE
# =================================================
var current_room_id: String = ""

# corridor overlay
var _corridor_instance: Node = null

# =================================================
# ROOMS REGISTRY
# =================================================
# room_id -> scene_path
var rooms: Dictionary = {
	"Room47Infirmary": "res://scenes/rooms/room_47_Infirmary/room_47_infirmary.tscn",
	"corridor": "res://scenes/rooms/corridor/corridor.tscn",
	"StarshipBridge": "res://scenes/rooms/room_1_Starship_bridge/room_1_Starship_bridge.tscn",
	"CaptainLounge":"res://scenes/rooms/room_2_Captain_Lounge/room_2_captain_lounge.tscn",
	"LongRangeCommunications": "res://scenes/rooms/room_3_long_range_communications/room_3_long_range_communications.tscn",
	"SensorArray": "res://scenes/rooms/room_4_sensors_array/room_4_sensors_array.tscn",
	"CouncilChamber": "res://scenes/rooms/room_5_council_chamber/room_5_council_chamber.tscn",
	"SecurityOffice":"res://scenes/rooms/room_6_security_office/room_6_security_office.tscn",
	"FirstOfficer":"res://scenes/rooms/room_7_first_officer/room_7_first_officer.tscn",
	"ManualArmsDepot":"res://scenes/rooms/room_8_manual_arms_depot/room_8_manual_arms_depot.tscn",
	"HabitationComplex":"res://scenes/rooms/room_9_habitation_complex/room_9_habitation_complex.tscn",
	"HabitationComplex2":"res://scenes/rooms/room_9_habitation_complex_2/room_9_habitation_complex_2.tscn",
	"OfficerQuarters":"res://scenes/rooms/room_10_officer_quarters/room_10_officer_quarters.tscn",
	"WaterReclamationFacility2":"res://scenes/rooms/room_29_water_reclamation_facility_2/room_29_water_reclamation_facility_2.tscn",
	"HydroponicsBay":"res://scenes/rooms/room_30_hydroponics_bay/room_30_hydroponics_bay.tscn",
	"Landfill":"res://scenes/rooms/room_31_landfill/room_31_landfill.tscn",
	"HRoom": "res://scenes/rooms/room_33_h_room/room_33_h_room.tscn",
	"GroundVehicleBay":"res://scenes/rooms/room_34_ground_vehicle_bay/room_34_ground_vehicle_bay.tscn",
	"CryostasisStorage":"res://scenes/rooms/room_35_cryostasis_storage/room_35_cryostasis_storage.tscn",
	"MechanicalServiceBay":"res://scenes/rooms/room_36_mechanical_service_bay/room_36_mechanical_service_bay.tscn",
	"HeavyOrdnanceStorage":"res://scenes/rooms/room_37_heavy_ordnance_storage/room_37_heavy_ordnance_storage.tscn",
	"FireControlCommand":"res://scenes/rooms/room_38_fire_control_command/room_38_fire_control_command.tscn",
	"LogisticsNexus":"res://scenes/rooms/room_40_logistics_nexus/room_40_logistics_nexus.tscn",
	"WaterReclamationFacility":"res://scenes/rooms/room_41_water_reclamation_facility/room_41_water_reclamation_facility.tscn",
	"AuxiliaryFuelStorage":"res://scenes/rooms/room_42_auxiliary_fuel_storage/room_42_auxiliary_fuel_storage.tscn",
	"Shield":"res://scenes/rooms/room_43_shield/room_43_shield.tscn",
	"Memorial":"res://scenes/rooms/room_44_memorial/room_44_memorial.tscn",
	"DeepSpaceObservatory":"res://scenes/rooms/room_45_deep_space_observatory/room_45_deep_space_observatory.tscn",
	"LifeboatLaunchComplex":"res://scenes/rooms/room_46_lifeboat_launch_complex/room_46_lifeboat_launch_complex.tscn"
}

func corridor_init() -> void:
	if _corridor_instance != null:
		return

	var corridor_scene := get_room_scene("corridor")
	if corridor_scene == null:
		D.error("RoomManager: corridor scene non trovata")
		return

	_corridor_instance = corridor_scene.instantiate()
	get_tree().root.add_child(_corridor_instance)

	# deve continuare a vivere sempre
	_corridor_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	_corridor_instance.set_corridor_camera()
	



# =================================================
# ROOM HELPERS (INVARIATI)
# =================================================
func has_room(room_id: String) -> bool:
	return rooms.has(room_id)

func get_room_path(room_id: String) -> String:
	if not rooms.has(room_id):
		push_error("RoomManager: room_id non trovato: %s" % room_id)
		return ""
	return rooms[room_id]

func get_room_scene(room_id: String) -> PackedScene:
	var path := get_room_path(room_id)
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_error("RoomManager: scena non esiste: %s" % path)
		return null
	return load(path) as PackedScene

func get_room_id_from_path(path: String) -> String:
	for room_id in rooms.keys():
		if rooms[room_id] == path:
			return room_id
	push_error("RoomManager: path non trovato: %s" % path)
	return ""

# =================================================
# REAL ROOM CHANGE (PORTE, GAMEPLAY)
# =================================================
func change_room_id(room_id: String) -> void:
	current_room_id = room_id
	get_tree().change_scene_to_packed(get_room_scene(room_id))

# =================================================
# CORRIDOR OVERLAY (MODALITÀ A)
# =================================================

func enter_new_npc_in_room(id_npc :String , id_room : String) -> void:
	D.debug("corridor esiste ? = " + str(_corridor_instance))
	if id_room == "corridor" and _corridor_instance:
		_corridor_instance.spawn_dinamic_human(id_npc)
