extends Node

signal hour_passed
signal time_tick(hours_left: float)
signal time_over

# ---- CONFIG ----
const TOTAL_GAME_HOURS := 365.0 * 24.0        # 8760
const TOTAL_REAL_SECONDS := 90.0 * 60.0 * 60.0 # 324000
const GAME_HOURS_PER_SECOND := TOTAL_GAME_HOURS / TOTAL_REAL_SECONDS

const AUTOSAVE_INTERVAL_HOURS := 1.0 # ogni ora di gioco

# ---- STATE ----
var remaining_hours: float = TOTAL_GAME_HOURS
var _autosave_accumulator: float = 0.0
var running := true

# ---- READY ----
func _ready() -> void:
	# load_time()
	pass

# ---- PROCESS ----
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

	# 🔥 QUI ORA EMETTIAMO hour_passed
	if _autosave_accumulator >= AUTOSAVE_INTERVAL_HOURS:
		_autosave_accumulator -= AUTOSAVE_INTERVAL_HOURS
		
		hour_passed.emit()   # <--- QUESTO È IL PASSO DECISIVO
		# autosave_state()

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
