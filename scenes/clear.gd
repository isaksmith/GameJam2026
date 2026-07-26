extends TextureButton

@onready var canvas_layer = %CanvasLayer

@export var hover_color: Color = Color(0.7, 0.7, 0.7, 1.0)
@export var normal_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var fade_duration: float = 0.15 # Time in seconds for the fade

var tween: Tween

func _on_mouse_entered() -> void:
	fade_to_color(hover_color)

func _on_mouse_exited() -> void:
	fade_to_color(normal_color)

func fade_to_color(target_color: Color) -> void:
	# Stop the previous animation to prevent clipping
	if tween and tween.is_running():
		tween.kill()
		
	# Create and run the new fade animation
	tween = create_tween()
	tween.tween_property(self, "self_modulate", target_color, fade_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


func _on_pressed() -> void:
	canvas_layer.clear()
