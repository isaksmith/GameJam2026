extends TextureRect

func _process(_delta: float) -> void:
	# Teleports the image directly to the cursor's world position
	global_position = get_global_mouse_position()
