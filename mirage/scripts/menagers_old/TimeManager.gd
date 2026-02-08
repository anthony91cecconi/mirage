extends Node

# ---- CONFIG ----
const TOTAL_GAME_HOURS := 365.0 * 24.0        # 8760
const TOTAL_REAL_SECONDS := 90.0 * 60.0 * 60.0 # 324000
const GAME_HOURS_PER_SECOND := TOTAL_GAME_HOURS / TOTAL_REAL_SECONDS

const AUTOSAVE_INTERVAL_HOURS := 1.0 # ogni ora di gioco

# ---- STATE ----
var remaining_hours: float 
var _autosave_accumulator: float = 0.0
var running := true

# ---- SIGNALS ----
signal time_tick(hours_left: float)
signal time_over

func _ready() -> void:
#	load_time()
	pass

func _process(delta: float) -> void:
	if not running:
		return

	var hours_passed := delta * GAME_HOURS_PER_SECOND
	remaining_hours -= hours_passed
	_autosave_accumulator += hours_passed

	if remaining_hours <= 0.0:
		remaining_hours = 0.0
		running = false
		time_over.emit()
		return

	if _autosave_accumulator >= AUTOSAVE_INTERVAL_HOURS:
		_autosave_accumulator -= AUTOSAVE_INTERVAL_HOURS
		autosave_state()

	time_tick.emit(remaining_hours)

# ---- PUBLIC API ----

func get_remaining_hours() -> float:
	return remaining_hours

func get_remaining_minutes() -> float:
	return remaining_hours * 60.0

func get_remaining_seconds() -> float:
	return remaining_hours * 3600.0

func get_formatted_time() -> String:
	var total_seconds := int(get_remaining_seconds())

	var h := total_seconds / 3600
	var m := (total_seconds % 3600) / 60
	var s := total_seconds % 60

	return "%d:%02d:%02d" % [h, m, s]



func stop_time() -> void:
	running = false

func resume_time() -> void:
	running = true

# ---- INTERNAL ----

func load_time()-> void:
	remaining_hours = LoadManager.load_time_second()

#TODO: bloccato perche sono tornato in dietro da sistemare quando sara il momento
func autosave_state() -> void:
	#SaveManager.save_time_second(remaining_hours)
	# Qui NON salvi tutto il gioco
	# ma notifichi i manager interessati
	# SaveManager.save_checkpoint(remaining_hours)
	pass
