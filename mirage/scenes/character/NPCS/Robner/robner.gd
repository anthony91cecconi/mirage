extends BaseNPC


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	_on_velocity_computed(safe_velocity)
