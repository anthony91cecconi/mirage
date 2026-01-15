extends Node2D
@onready var spawer : AreaSpawner = $SpawnerArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawer._spawn_precision("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
