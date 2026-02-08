extends StaticBody2D
class_name Door

# =================================================
# STATE
# =================================================
var player_inside := false
var is_open := false
var initialized := false
var selectable: bool = false
var _menu: EntitiesMenu = null
var player_exit_room = false

# =================================================
# CONFIG
# =================================================
@export var lock: bool = false
@export var password: String = ""
@export var limits: bool = false

var password_known: bool = false

@export var max_hp: int = 100
@export var hp: int = 100
@export var id: String
# autorizzazioni ESATTE (non gerarchiche)
@export var required_authorities: Array[String] = [
	"CREW",
	"MEDICAL",
	"ENGINEERING"
]

# =================================================
# NODES
# =================================================
@onready var sprite: Sprite2D = $StaticBody2D2/Sprite2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_body: CollisionShape2D = $door_body
@onready var area2d: Area2D = $Area2D

@onready var menu_spawn: Control = $MenuSpawn
@export var entities_menu_scene: PackedScene = preload("res://scenes/entities/entities_menu/entities_menu.tscn")

# =================================================
# COLLISION
# =================================================
func door_collision_on() -> void:
	# azzera tutto
	collision_layer = 0
	collision_mask = 0

	# attiva layer 4, mask 1
	set_collision_layer_value(4, true)
	set_collision_mask_value(1, true)

	D.debug("DOOR COLLISION ON layer=%s mask=%s" % [collision_layer, collision_mask])


func door_collision_off() -> void:
	collision_layer = 0
	collision_mask = 0
	D.debug("DOOR COLLISION OFF layer=%s mask=%s" % [collision_layer, collision_mask])


func area_off() -> void:
	area2d.collision_layer = 0
	area2d.collision_mask = 0
	D.debug("AREA OFF layer=%s mask=%s" % [str(area2d.collision_layer), str(area2d.collision_mask)])

# =================================================
# STATE SETTERS (non chiamarsi a vicenda)
# =================================================
func _set_closed_visual() -> void:
	$SfxClose.play()
	anim.play("close")
	D.debug("VISUAL play=close")

func _set_open_visual() -> void:
	$SfxOpen.play()
	anim.play("open")
	D.debug("VISUAL play=open")

func _set_lock_visual() -> void:
	anim.play("lock")
	D.debug("VISUALplay=lock")

func _set_limits_visual() -> void:
	anim.play("limit")
	D.debug("VISUAL play=limit")

func _set_destroyed_visual() -> void:
	anim.play("destroyed")
	D.debug("VISUAL play=destroyed")

func _set_fail_visual() -> void:

	anim.play("fail")
	$SfxFail.play()
	await anim.animation_finished
	D.debug("VISUAL play=fail")
	$SfxFail.stop()
	_set_limits_visual()

# =================================================
# CORE LOGIC (diagramma: DESTROYED > LOCKED > LIMITED > CLOSED/OPEN)
# =================================================
func apply_state_from_flags() -> void:
	D.debug("BEFORE APPLY")

	# 1) DESTROYED
	if hp <= 0:
		_set_destroyed()
		D.debug("AFTER APPLY (DESTROYED)")
		return

	# 2) LOCKED
	if lock:
		_set_locked()
		D.debug("AFTER APPLY (LOCKED)")
		return

	# 3) LIMITED (porta chiusa, ma con animazione limits)
	if limits:
		_set_limited()
		D.debug("AFTER APPLY (LIMITED)")
		return
		
	if not password == "" and not password_known :
		_set_fail_visual()

	if password_known: 
		_set_closed()
		return
		
	# 4) NORMAL CLOSED (default)
	#_set_closed()
	D.debug("AFTER APPLY (CLOSED)")

func _set_closed() -> void:
	is_open = false
	door_collision_on()
	_set_closed_visual()

func _set_open() -> void:
	is_open = true
	door_collision_off()
	_set_open_visual()

func _set_locked() -> void:
	is_open = false
	door_collision_on()
	_set_lock_visual()

func _set_limited() -> void:
	is_open = false
	door_collision_on()
	_set_limits_visual()

func _set_destroyed() -> void:
	is_open = true
	door_collision_off()
	area_off()
	_set_destroyed_visual()

# =================================================
# LIFECYCLE
# =================================================
func _ready() -> void:
	D.debug("READY START")
	hp = clamp(hp, 0, max_hp)
	D.debug("hp = "+ str(hp))
	
	player_inside = false
	is_open = false

	apply_state_from_flags()
	await get_tree().process_frame
	initialized = true
	D.debug("READY END (initialized=true)")
	D.debug("READY END STATE")

# =================================================
# AREA EVENTS
# =================================================
func _on_area_2d_body_entered(body: Node2D) -> void:
	if  player_exit_room:
		return
	
	D.debug("AREA body_entered name=%s groups=%s" % [str(body.name), str(body.get_groups())])

	if not initialized:
		D.debug("AREA body_entered IGNORED not initialized")
		return

	# accetta player OR npc
	if not (body.is_in_group("player") or body.is_in_group("npc")):
		D.debug("AREA body_entered IGNORED not player/npc")
		return

	# traccia player_inside solo per player (come volevi)
	if body.is_in_group("player") or body.is_in_group("npc"):
		player_inside = true
		D.debug("STATE player_inside=true (entered)")

	# riallinea visuale + collisione in base ai flag correnti
	apply_state_from_flags()

	# BLOCCO ASSOLUTO
	if hp <= 0:
		D.debug("ENTER STOP hp<=0 destroyed -> stay open")
		return
	if lock:
		D.debug("ENTER STOP lock=true -> stay closed")
		return

	# LIMITS: se autorizzato, mostra feedback e poi apri
	if limits:
		_handle_limits_enter(body)
		return


	# porta normale
	_open_door("normal")

func _on_area_2d_body_exited(body: Node2D) -> void:
	player_exit_room = false
	D.debug("AREA body_exited name=%s groups=%s" % [str(body.name), str(body.get_groups())])
	
	if not (body.is_in_group("player") or body.is_in_group("npc")):
		D.debug("AREA body_exited IGNORED not player/npc")
		return

	if hp <= 0:
		D.debug("EXIT STOP hp<=0 destroyed -> stay open")
		return

	if lock:
		D.debug("EXIT lock=true -> ensure locked/closed")
		_set_locked()
		return	

	if body.is_in_group("player")or body.is_in_group("npc"):
		player_inside = false
		D.debug("STATE player_inside=false (exited)")
	
	_close_entities_menu()
	_close_door()

# =================================================
# DOOR ACTIONS
# =================================================
func _open_door(reason: String) -> void:
	D.debug("OPEN REQUEST" + reason)
	D.debug("OPEN BEFORE")

	# sicurezza
	if hp <= 0:
		D.debug("OPEN ABORT hp<=0")
		return
	if lock:
		D.debug("OPEN ABORT lock=true")
		return
	if is_open:
		D.debug("OPEN SKIP already open")
		return

	_set_open()
	D.debug("OPEN AFTER")

func _close_door() -> void:
	D.debug("CLOSE BEFORE")

	if not is_open:
		D.debug("CLOSE SKIP already closed")
		return

	if player_inside:
		D.debug("CLOSE BLOCKED player_inside=true")
		return

	if lock:
		D.debug("CLOSE -> LOCKED lock=true")
		_set_locked()
		D.debug("CLOSE AFTER LOCKED")
		return

	if limits:
		D.debug("CLOSE -> LIMITED limits=true")
		_set_limited()
		D.debug("CLOSE AFTER LIMITED")
		return

	_set_closed()
	D.debug("CLOSE AFTER CLOSED")

# =================================================
# AUTHORIZATION
# =================================================
#TODO: da controllare come ultima cosa
func _is_authorized(body: Node2D) -> bool:
	D.debug("AUTH CHECK body=%s" % str(body.name))

	if not ("human_info" in body):
		D.debug("AUTH FAIL no human_info var")
		return false

	var info = body.get("human_info")
	if info == null:
		D.debug("AUTH FAIL human_info is null")
		return false

	if info.pass == null:
		D.debug("AUTH FAIL human_info.pass is null")
		return false

	D.debug("AUTH PASSES"+str(info.pass))
	D.debug("AUTH REQUIRED"+str(required_authorities))

	for auth in required_authorities:
		if auth in info.pass:
			D.debug("AUTH OK matched=%s" % auth)
			return true

	D.debug("AUTH FAIL no exact match")
	return false

# =================================================
# DAMAGE / REPAIR
# =================================================
func damage(amount: int) -> void:
	D.debug("DAMAGE amount=%s" % str(amount))
	D.debug("DAMAGE BEFORE")

	if amount <= 0:
		D.debug("DAMAGE IGNORED amount<=0")
		return
	if hp <= 0:
		D.debug("DAMAGE IGNORED already destroyed")
		return

	hp = max(hp - amount, 0)
	D.debug("DAMAGE APPLIED hp=%s" % str(hp))

	if hp == 0:
		D.debug("DAMAGE -> DESTROY hp reached 0")
		_destroy()

	D.debug("DAMAGE AFTER")

func repair(amount: int) -> void:
	D.debug("REPAIR amount=%s" % str(amount))
	D.debug("REPAIR BEFORE")

	if amount <= 0:
		D.debug("REPAIR IGNORED amount<=0")
		return
	if hp <= 0:
		D.debug("REPAIR IGNORED destroyed (irreversible by design)")
		return

	hp = min(hp + amount, max_hp)
	D.debug("REPAIR APPLIED hp=%s" % str(hp))

	D.debug("REPAIR AFTER")

func _destroy() -> void:
	D.debug("DESTROY lock=false, set destroyed state")
	lock = false
	_set_destroyed()
	D.debug("DESTROY AFTER")

# =================================================
# VISUAL HELPERS
# =================================================
#TODO: replicabili su tutti gli entities
func collision_color() -> void:
	sprite.modulate = Color(1, 1, 0)
	D.debug("VISUAL collision_color=YELLOW")
#TODO: replicabili su tutti gli entities
func clear_collision_color() -> void:
	sprite.modulate = Color(1, 1, 1)
	D.debug("VISUAL collision_color=WHITE")

# =================================================
# SAVE DATA
# =================================================
#TODO: testare dopo accertato funzionamento
func get_save_data() -> Dictionary:
	D.debug("SAVE DATA REQUEST")
	var data := {
		"hp": hp,
		"max_hp": max_hp,
		"lock": lock,
		"limits": limits,
		"password": password,
		"is_open": is_open,
		"required_authorities": required_authorities.duplicate(),
		"password_known": password_known
	}
	D.debug("SAVE DATA"+ str(data))
	return data

# =================================================
# MENU SECTION
# =================================================
func _build_menu_models() -> Array[EntitiesMenuModel]:
	D.debug("MENU build models")
	var models: Array[EntitiesMenuModel] = []
	
	if not limits:
		models.append(
			EntitiesMenuModel.new(
				"door_001",
				"block",
				"",
				EntitiesMenuModel.ButtonType.ACTION
			)
		)

	if password != "":
		models.append(
			EntitiesMenuModel.new(
				"door_002",
				"password",
				"Enter password",
				EntitiesMenuModel.ButtonType.INPUT
			)
		)

	D.debug("MENU MODELS count=%s" % str(models.size()))
	return models

func _open_entities_menu() -> void:
	D.debug("MENU open requested selectable=%s" % str(selectable))

	if not selectable:
		D.debug("MENU OPEN ABORT not selectable")
		return

	if not entities_menu_scene:
		push_warning("EntitiesMenu scene non assegnata")
		D.debug("MENU OPEN ABORT entities_menu_scene null")
		return

	_menu = entities_menu_scene.instantiate() as EntitiesMenu
	menu_spawn.add_child(_menu)

	_menu.action_pressed.connect(_on_menu_action_pressed)
	_menu.input_submitted.connect(_on_menu_input_submitted)

	_menu.position = Vector2.ZERO
	_menu.open(_build_menu_models())

	D.debug("MENU opened")

func _close_entities_menu() -> void:
	D.debug("MENU close requested")
	if not _menu:
		D.debug("MENU CLOSE SKIP menu is null")
		return
	_menu.queue_free()
	_menu = null
	D.debug("MENU closed")

func _on_pick_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not selectable:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		D.debug("PICK left click -> open menu")
		_open_entities_menu()

func _on_pick_area_area_entered(area: Area2D) -> void:
	selectable = true
	D.debug("PICK area_entered selectable=true groups=%s" % str(area.get_groups()))
	if area.is_in_group("player"):
		collision_color()

func _on_pick_area_area_exited(area: Area2D) -> void:
	D.debug("PICK area_exited groups=%s" % str(area.get_groups()))
	if area.is_in_group("player"):
		selectable = false
		clear_collision_color()
	D.debug("PICK selectable=%s" % str(selectable))

func _on_menu_action_pressed(action_id: String) -> void:
	D.debug("MENU action_pressed id=%s" % action_id)
	match action_id:
		"door_001":
			_block_unblock()
	_close_entities_menu()

#TODO: DA TESTARE
func _on_menu_input_submitted(action_id: String, value: String) -> void:
	D.debug("MENU input_submitted id=%s value=%s" % [action_id, value])
	match action_id:
		"door_002":
			_try_password(value)
	_close_entities_menu()

func _block_unblock() -> void:
	if not limits:
		lock = not lock
		_set_open()
	D.debug("BLOCK/UNBLOCK lock now=%s" % str(lock))
	apply_state_from_flags()
	


func _try_password(value: String) -> void:
	D.debug("PASSWORD try value=%s stored=%s" % [value, password])

	if password == value:
		password_known = true
		save()
		D.debug("PASSWORD OK")
		
		if player_inside:
			_open_door("password ok")
	else:
		D.debug("PASSWORD FAIL")
		_set_fail_visual()


func _can_pass_limits(body: Node2D) -> bool:
	if password_known and body.is_in_group("player"):
		return true

	if password != "" and not password_known:
		return false

	return _is_authorized(body)

func _handle_limits_enter(body: Node2D) -> void:
	if _can_pass_limits(body):
		_set_limits_visual()
		await get_tree().create_timer(1.0).timeout
		_open_door("limits ok")
	else:
		_set_fail_visual()

func save() -> void:
	pass


func load_from_data(data: Dictionary) -> void:
	if data.has("hp"):
		hp = data.hp
	if data.has("max_hp"):
		max_hp = data.max_hp
	if data.has("lock"):
		lock = data.lock
	if data.has("limits"):
		limits = data.limits
	if data.has("password"):
		password = data.password
	if data.has("password_known"):
		password_known = data.password_known
	if data.has("required_authorities"):
		required_authorities = data.required_authorities.duplicate()

	# riallinea stato visivo + collisioni
	apply_state_from_flags()


func _on_exit_area_body_entered(body: Node2D) -> void:
	player_exit_room = true
	D.debug("AREA body_entered name=%s groups=%s" % [str(body.name), str(body.get_groups())])

	# accetta player OR npc
	if not (body.is_in_group("player") or body.is_in_group("npc")):
		D.debug("AREA body_entered IGNORED not player/npc")
		return
	_set_open()


func _on_exit_area_body_exited(body: Node2D) -> void:
	D.debug("AREA body_entered name=%s groups=%s" % [str(body.name), str(body.get_groups())])

	# accetta player OR npc
	if not (body.is_in_group("player") or body.is_in_group("npc")):
		D.debug("AREA body_entered IGNORED not player/npc")
		return
	_set_closed()
