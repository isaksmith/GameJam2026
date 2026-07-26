extends Camera2D


func _process(delta: float) -> void:
	global_position.x = $"../Car/chassis".global_position.x
	global_position.y = $"../Car/chassis".global_position.y
	pass
