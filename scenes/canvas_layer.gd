extends CanvasLayer
@onready var color_rect = %ColorRect
@onready var monkey_hand = %MonkeyHand

func _ready() -> void:
	pass # Replace with function body.
	
func trigger_camera_action():
	monkey_hand.modulate.a = 0.0
	var camera = get_tree().get_first_node_in_group("main_camera")
	if camera:
		camera.zoom_to(Vector2(3,3),1.5) 
	var tween = create_tween()
	var target_pos = Vector2(offset.x, 0.0) # Replace with your target Y position
	tween.tween_property(self, "offset", target_pos, 1.3)\
	 	.set_trans(Tween.TRANS_BOUNCE)\
	 	.set_ease(Tween.EASE_OUT)\
		.set_delay(0.3)
	await get_tree().create_timer(0.9).timeout
	monkey_hand.process_mode = Node.PROCESS_MODE_INHERIT
	#monkey_hand.visible = true;
	var tween2 = create_tween()
	tween2.tween_property(monkey_hand, "modulate:a", 1.0, 0.6)
	
func done():
	color_rect.save_drawing()
	var tween = create_tween()
	var target_pos = Vector2(offset.x, 750) # Replace with your target Y position
	tween.tween_property(self, "offset", target_pos, 1.6)\
	 	.set_trans(Tween.TRANS_CUBIC)\
	 	.set_ease(Tween.EASE_OUT)
	var camera = get_tree().get_first_node_in_group("main_camera")
	if camera:
		camera.zoom_to(Vector2(1,1),1.5) 
	var tween2 = create_tween()
	tween2.tween_property(monkey_hand, "modulate:a", 0, 0.4)

func clear():
	color_rect.clear_lines()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
