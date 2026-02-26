extends Camera2D
@onready var timestamp : Label = $CanvasLayer/Time

func _ready():
	D.debug_order("@")
	TimeManager.time_tick.connect(_on_time_tick)

func _on_time_tick(hours_left: float):
	D.debug_order("@")
	timestamp.text = TimeManager.get_formatted_time()
