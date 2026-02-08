extends RoomBase

@onready var camera : Camera2D = $Camera2D


func _ready() -> void:
	super._ready()
	#debug_print_tree(self)

	D.debug("corridor _ready()")
	
func set_corridor_camera() -> void:
	CameraMenager.change_camera(CameraMenager.CameraType.CORRIDOR,camera)


func debug_print_tree(node: Node, indent: int = 0) -> void:
	var prefix := "  ".repeat(indent)
	print(prefix + "- " + node.name + " [" + node.get_class() + "]")

	for child in node.get_children():
		debug_print_tree(child, indent + 1)
