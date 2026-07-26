extends Node


var is_drawing := false
var current_line: Line2D
var is_mouse_inside: bool = false
@onready var viewport: SubViewport = $".." # Point to your SubViewport
@onready var color_rect: ColorRect = %ColorRect
@onready var target_sprite: Sprite2D = %Sprite2D 
@onready var target_sprite2: Sprite2D = %BackSprite2D 

@onready var target_node: RigidBody2D = %FrontWheel
@onready var target_node2: RigidBody2D = %BackWheel


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed && is_mouse_inside == true:
			is_drawing = true
			start_new_line(event.position)
		else:
			is_drawing = false
			current_line = null

	elif event is InputEventMouseMotion and is_drawing:
		if current_line && is_mouse_inside==true:
			current_line.add_point(event.position)

func start_new_line(pos: Vector2) -> void:
	current_line = Line2D.new()
	current_line.default_color = Color.BLACK # Black shape/line
	current_line.width = 8.0
	current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	viewport.add_child(current_line)
	current_line.add_point(pos)

# Call this function via a Button press (e.g., press 'S' or click a Save Button)
func save_drawing(filename: String = "user://my_shape.png") -> void:
	# Wait for the frame to finish rendering completely
	await RenderingServer.frame_post_draw
	
	var uncropped_img = viewport.get_texture().get_image()
	var rect_position: Vector2 = color_rect.position
	var rect_size: Vector2 = color_rect.size
	
	var crop_box := Rect2i(
		int(rect_position.x), 
		int(rect_position.y), 
		int(rect_size.x), 
		int(rect_size.y)
	)
	var img: Image = uncropped_img.get_region(crop_box)
	# 3. Loop through every pixel to find and modify white colors
	for x in range(img.get_width()):
		for y in range(img.get_height()):
			var pixel_color := img.get_pixel(x, y)
			
			# Check if the pixel is white (Red, Green, and Blue are all 1.0)
			if pixel_color.r == 1.0 and pixel_color.g == 1.0 and pixel_color.b == 1.0:
				# Set alpha channel to 0.0 (fully transparent)
				pixel_color.a = 0.0 
				img.set_pixel(x, y, pixel_color)
				
	# 4. Convert the modified Image into a usable Canvas Texture
	var texture := ImageTexture.create_from_image(img)
	
	var error = img.save_png(filename)
	if error == OK:
		print("Successfully saved image at: ", ProjectSettings.globalize_path(filename))
	else:
		print("Error saving image!")
		
	if target_sprite:
		var car = get_tree().get_first_node_in_group("cart")
		print(texture)
		car.apply_custom_texture(texture)
		target_sprite.texture = texture
		target_sprite2.texture = texture

		target_node.create_collider_from_drawn_shape()
		print("Sprite2D texture updated successfully!")
		
	var all_drawn_points := PackedVector2Array()

	for child in viewport.get_children():
		if child is Line2D:
			#all_drawn_points.append_array(child.points)
			for pt in child.points:
			# Shift drawn points relative to the top-left of the ColorRect
				all_drawn_points.append(pt - color_rect.position)

	#if all_drawn_points.size() > 2:
		var car = get_tree().get_first_node_in_group("cart")
		if car:
			if car.has_method("apply_custom_wheels"):
				car.apply_custom_wheels(all_drawn_points)
	clear_lines()


# Remove the drawn Line2D strokes so the next drawing starts blank instead
# of stacking on top of everything drawn previously.
func clear_lines() -> void:
	for child in viewport.get_children():
		if child is Line2D:
			child.queue_free()


func _on_mouse_entered() -> void:
	is_mouse_inside = true


func _on_mouse_exited() -> void:
	is_mouse_inside = false
