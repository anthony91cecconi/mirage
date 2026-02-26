extends Node
var version : String = "0.0.1"

# =================================================
# CONFIG
# =================================================
#const SAVE_PATH := "user://save.json"
const SAVE_PATH := "res://temp/save.json"
const AUTOSAVE_INTERVAL := 20.0

# =================================================
# STATE
# =================================================
var _autosave_timer: Timer


# =================================================
# LIFECYCLE
# =================================================
func _ready() -> void:
	await  Orchestrator.save_start
	D.debug_order("@")
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = AUTOSAVE_INTERVAL
	_autosave_timer.one_shot = false
	_autosave_timer.autostart = true
	_autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(_autosave_timer)


# =================================================
# AUTOSAVE
# =================================================
func _on_autosave_timeout() -> void:
	D.debug_order("@")
	D.debug("autosalvataggio scattato")
	autosave()


func request_save() -> void:
	D.debug_order("@")
	save_game()


# =================================================
# SAVE
# =================================================
func save_game() -> void:
	D.debug_order("@")
	var data: Dictionary = {}
	data["version"] = version
	data["scene"] = get_tree().current_scene.scene_file_path
	
	data["humans"] = HumansManager.use_for_save()
	D.debug(str(data))
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		D.error("SaveManager: impossibile aprire file")
		return
	var json := JSON.stringify(data, "\t") # oppure "  " (2 spazi)
	file.store_string(json)
	file.close()
	
		

func new_game() -> void:
	D.debug_order("@")
	# reset stato globale
	HumansManager.clear()

	createplayertest("Infirmary",Vector2(-296.12, 1597.60))
	createnpctest(100,"Infirmary",false)

	# costruiamo il save iniziale
	var data: Dictionary = {}
	data["scene"] = ""
	data["humans"] = HumansManager.to_dict()

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		D.error("SaveManager: impossibile creare nuovo save")
		return

	file.store_string(JSON.stringify(data))
	file.close()
	Orchestrator.savemanager = true
	Orchestrator.humansManager = true

func test() -> void:
	D.debug_order("@")
	HumansManager.clear()
	createplayertest("test", Vector2(558.15, 332.86))
	createnpctest(100 , "test", true)
	
	D.debug("savemanager è ok")
	Orchestrator.savemanager = true
	Orchestrator.humansManager = true

func createplayertest(r:String,v:Vector2) -> void:
	D.debug_order("@")
	var player_info := HumansInfo.new(
		"namePlayer",
		r,
		"res://scenes/character/player/player.tscn",
		v,
		"player",
		true,
		"",
		Skills.new(""),
		120.0
	)
	D.debug("tentativo di aggiungere player del savemanager per nuova partita")
	HumansManager.add_human(player_info)

func createnpctest(n:int,r:String,v:bool) ->void:
	D.debug_order("@")
	randomize()
	# rettangolo debug tracciato dal player
	var min_x := 233.83
	var max_x := 909.25
	var min_y := 23.61
	var max_y := 537.03
	for i in range(0,n):
		var room = r
		
		var npc_id := "npc-%03d" % i
		var npc_pos:Vector2
		if v:
			npc_pos = Vector2(558.15,332.86)
		else:
			npc_pos = Vector2(
				randf_range(min_x, max_x),
				randf_range(min_y, max_y)
			)

		var npc_info := HumansInfo.new(
			npc_id, 
			room,
			"res://scenes/character/NPCS/Robner/robner.tscn",
			npc_pos,
			npc_id,
			true,
			"res://scenes/character/NPCS/Robner/robner_bv.gd",
			Skills.new(
				RoomManager.random_room_id(),
				#"test",
				JobManager.job_enum.MINATORE
				),
			float(randf_range(80, 150))
		)

		HumansManager.add_human(npc_info)


func autosave() -> void:
	D.debug_order("@")
	save_game()
