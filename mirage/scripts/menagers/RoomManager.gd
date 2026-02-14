extends Node



# =================================================
# STATE
# =================================================
var current_room_id: String = ""
var _current_instance: Node = null
# map_layer overlay
var _map_layer_instance: Node = null
var MAP_LAYER_ID: String = "corridor"

# =================================================
# ROOMS REGISTRY
# =================================================
# room_id -> scene_path
var rooms: Dictionary = {
	"corridor": "res://scenes/rooms/corridor/corridor.tscn",
	"Maintenance": "res://scenes/rooms/room_26_maintenance/room_26_maintenance.tscn",
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
	"PrimaryCargoHold":"res://scenes/rooms/room_25_primary_cargo_hold/room_25_primary_cargo_hold.tscn",
	"FrontierResearchLab":"res://scenes/rooms/room_27_frontier_research_lab/room_27_frontier_research_lab.tscn",
	"MonitorRoom":"res://scenes/rooms/room_28_monitor_room/room_28_monitor_room.tscn",
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
	"LifeboatLaunchComplex":"res://scenes/rooms/room_46_lifeboat_launch_complex/room_46_lifeboat_launch_complex.tscn",
	"Infirmary": "res://scenes/rooms/room_47_Infirmary/room_47_infirmary.tscn"
}

func map_layer_init() -> void:
	if _map_layer_instance != null:
		return

	var map_layer_scene := get_room_scene(MAP_LAYER_ID)
	if map_layer_scene == null:
		D.error("RoomManager: "+MAP_LAYER_ID+" scene non trovata")
		return

	_map_layer_instance = map_layer_scene.instantiate()
	get_tree().root.add_child(_map_layer_instance)

	# deve continuare a vivere sempre
	_map_layer_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	_map_layer_instance.set_map_layer_camera()



# =================================================
# ROOM HELPERS (INVARIATI)
# =================================================
func has_room(room_id: String) -> bool:
	return rooms.has(room_id)

func get_room_path(room_id: String) -> String:
	if not rooms.has(room_id):
		D.error("RoomManager: room_id non trovato: %s" % room_id)
		return ""
	return rooms[room_id]

func get_room_scene(room_id: String) -> PackedScene:
	var path := get_room_path(room_id)
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		D.error("RoomManager: scena non esiste: %s" % path)
		return null
	return load(path) as PackedScene

func get_room_id_from_path(path: String) -> String:
	for room_id in rooms.keys():
		if rooms[room_id] == path:
			return room_id
	D.error("RoomManager: path non trovato: %s" % path)
	return ""

# =================================================
# REAL ROOM CHANGE (PORTE, GAMEPLAY)
# =================================================
func change_room_id(room_id: String) -> void:
	current_room_id = room_id

	var packed := get_room_scene(room_id)
	if packed == null:
		D.error("RoomManager: scena non trovata per id " + room_id)
		return

	await get_tree().change_scene_to_packed(packed)

	_current_instance=get_tree().current_scene
	D.debug("stanza cambiata con successo in " + room_id)



# =================================================
# map_layer OVERLAY (MODALITÀ A)
# =================================================

func enter_new_npc_in_room(id_npc :String , id_room : String) -> void:
	if _current_instance == null:
		_current_instance=get_tree().current_scene
	D.debug("verifica se current_room_id sia popolato = "+current_room_id)
	D.debug("verifica parametri = "+id_npc +" "+ id_room )
	if id_room == current_room_id and _current_instance:
		_current_instance.spawn_dinamic_human(id_npc)
		D.debug(id_npc + " human instanziato dinamicamente in :"+current_room_id)
		return
	
	if id_room == MAP_LAYER_ID and _map_layer_instance:
		_map_layer_instance.spawn_dinamic_human(id_npc)
		D.debug(id_npc + " human instanziato dinamicamente in :"+MAP_LAYER_ID)
		return
