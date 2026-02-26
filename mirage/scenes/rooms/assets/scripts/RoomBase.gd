extends Node2D
class_name RoomBase

@onready var camera : Camera2D = $Camera2D
@export var room_id: String

func _ready() -> void:
	D.debug_order("@")
	D.debug("RoomBase READY:" + room_id)
	
	# Configuriamo i costi di navigazione prima dello spawn degli umani
	_setup_navigation_costs()
	
	call_deferred("_spawn_after_ready")
	TouchControls.enable()

func _setup_navigation_costs() -> void:
	# Aspettiamo la fine del frame per essere certi che il NavigationServer abbia registrato i layer
	await get_tree().physics_frame
	
	# Cerchiamo i nodi nella gerarchia che hai descritto ($Tiles/Floor e $Tiles/Road)
	var floor_layer = get_node_or_null("Tiles/Floor")
	var road_layer = get_node_or_null("Tiles/Road")
	
	if floor_layer and floor_layer is TileMapLayer:
		# Recuperiamo il RID della regione di navigazione interna del layer
		var floor_rid = floor_layer.get_navigation_map() 
		# In Godot 4.x per i TileMapLayer si usa spesso il RID della regione specifica:
		var region_rid = floor_layer.get_region_rid()
		
		# Impostiamo il costo di percorrenza (3.0 = faticoso, 1.0 = normale)
		NavigationServer2D.region_set_travel_cost(region_rid, 3.0)
		D.debug("Costo navigazione Floor impostato a 3.0")

	if road_layer and road_layer is TileMapLayer:
		var road_rid = road_layer.get_region_rid()
		NavigationServer2D.region_set_travel_cost(road_rid, 1.0)
		D.debug("Costo navigazione Road impostato a 1.0")

# ... resto del tuo script (spawn_humans, ecc.) ...


func _spawn_after_ready():
	D.debug_order("@")

	if room_id != RoomManager.MAP_LAYER_ID:
		D.debug("Stanza principale: inizializzo il layer mappa (corridoio)")
		RoomManager.map_layer_init()

	if not Orchestrator.savemanager or not Orchestrator.roomManager:
		D.debug("Stanza " + room_id + " in attesa dell'Orchestratore...")
		await Orchestrator.npc_ready_to_start

	D.debug("Orchestratore OK: spawno gli umani in " + room_id)
	spawn_humans()


func spawn_humans() -> void:
	var humans := HumansManager.get_humans_in_room(room_id)
	D.debug("Humans in room"+ room_id+ ":"+ str(humans.size()))
	for h in humans:
		spawn_human(h)
		
func spawn_human(h: HumansInfo) -> void:
	D.debug_order("@")
	var scene := load(h.scena) as PackedScene
	if scene == null:
		D.error("RoomBase: impossibile caricare scena %s" % h.scena)
		return

	var instance := scene.instantiate()
	
	# --- PRIMA passi i dati ---
	if instance.has_method("setup_from_info"):
		instance.setup_from_info(h)
	else:
		D.error("RoomBase: %s non ha setup_from_info()" % instance.name)

	# --- POI lo aggiungi all'albero (qui scatterà il suo _ready) ---
	add_child(instance)


func snapshot_humans() -> void:
	D.debug_order("@")
	for h in get_tree().get_nodes_in_group("humans"):
		h.sync_to_info()

func spawn_dinamic_human(id:String) -> void:
	D.debug_order("@")
	var human : HumansInfo = HumansManager.get_human_by_id(id)
	spawn_human(human)

func set_map_layer_camera() -> void:
	D.debug_order("@")
	CameraMenager.change_camera(CameraMenager.CameraType.MAP, camera)
