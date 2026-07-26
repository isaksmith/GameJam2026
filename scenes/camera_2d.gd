extends Camera2D

# Keep a reference so we can stop old tweens if a new one starts
var zoom_tween: Tween

func zoom_to(target_zoom: Vector2, duration: float) -> void:
	# Stop the previous tween if it is still running
	if zoom_tween and zoom_tween.is_running():
		zoom_tween.kill()
	
	# Create a new tween
	zoom_tween = create_tween()
	
	# Animate the 'zoom' property to the target value
	zoom_tween.tween_property(self, "zoom", target_zoom, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
