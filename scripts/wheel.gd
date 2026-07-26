extends RigidBody2D
#I THINK THIS ISNT ALL NEEDED BUT WILL FIX IF IT IS
#TO WORK PROPERLY- you need the drawn_collider_utils.gd script in your filesystem!!!

@export var torque_per_pixel: float = 3000.0 # Extra torque per pixel of radius

# Extra CollisionPolygon2D children for shapes with more than one drawn
# island (disconnected strokes), mirroring rigid_body_2d.gd's approach.
var _extra_collision_polygons: Array[CollisionPolygon2D] = []
func create_collider_from_drawn_shape() -> void:
	if has_node("Sprite2D") and $Sprite2D.texture:
		_setup_wheel_from_texture($Sprite2D.texture)

func generate_test_circle(vertex_count: int, radius: float) -> PackedVector2Array:
	var points = PackedVector2Array()
	
	for i in range(vertex_count):
		# Calculate angle for each point around the circle (in radians)
		var angle = (i * 2.0 * PI) / vertex_count
		# Convert angle to X and Y coordinates
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
		
	return points
	
#------START CLAUDE-----------------------------------------------------
#------To be so honest I had claude rewrite this section using a separate utility 
#------script rather than calculating it in here or in rigid_body_2d,  now they are
#------the same and there is no chance the collider does not spawn at all, though
#------I have no idea what this code does tbh.

func setup_drawn_wheel(drawn_points: PackedVector2Array) -> void:

	if has_node("Sprite2D") and $Sprite2D.texture:
		_setup_wheel_from_texture($Sprite2D.texture)
	else:
		# No texture yet (e.g. the test circle generated in _ready() below).
		# Fall back to the old point-based path, hulled for safety.
		_setup_wheel_from_points(drawn_points)


func _setup_wheel_from_points(drawn_points: PackedVector2Array) -> void:
	if drawn_points.size() < 3:
		push_warning("Wheel shape requires at least 3 points!")
		return

	var center = Vector2.ZERO
	for point in drawn_points:
		center += point
	center /= drawn_points.size()

	var centered_points := PackedVector2Array()
	for point in drawn_points:
		centered_points.append(point - center)

	var hull_points := DrawnColliderUtils.sanitize_convex_polygon(Geometry2D.convex_hull(centered_points))
	if hull_points.size() < 3:
		push_warning("Wheel shape's convex hull collapsed -- drawing may be a single point or line!")
		return

	_clear_extra_colliders()
	$CollisionPolygon2D.polygon = hull_points
	$CollisionPolygon2D.position = Vector2.ZERO
	$CollisionPolygon2D.rotation = 0.0
	if has_node("Sprite2D"):
		$Sprite2D.centered = false
		$Sprite2D.position = -center

func _setup_wheel_from_texture(texture: Texture2D) -> void:
	var img: Image = texture.get_image()
	var valid_polygons: Array[PackedVector2Array] = DrawnColliderUtils.trace_polygons_from_image(img)

	if valid_polygons.is_empty():
		push_warning("setup_drawn_wheel: no collider could be traced from the drawn texture for %s" % name)
		return

	freeze = true

	var real_center: Vector2 = DrawnColliderUtils.calculate_combined_centroid(valid_polygons)
	_clear_extra_colliders()

	for i in range(valid_polygons.size()):
		var raw_vertices := valid_polygons[i]
		var centered_vertices := PackedVector2Array()
		for vertex in raw_vertices:
			centered_vertices.append(vertex - real_center)

		var target_poly: CollisionPolygon2D
		if i == 0:
			target_poly = $CollisionPolygon2D
		else:
			target_poly = $CollisionPolygon2D.duplicate()
			add_child(target_poly)
			_extra_collision_polygons.append(target_poly)

		target_poly.polygon = centered_vertices
		target_poly.disabled = false
		target_poly.position = Vector2.ZERO
		target_poly.rotation = 0.0

	# Realign the sprite so the texture still lines up with the new colliders.
	if has_node("Sprite2D"):
		$Sprite2D.centered = true
		$Sprite2D.position = Vector2.ZERO
		$Sprite2D.rotation = 0.0
		var half_texture_size: Vector2 = img.get_size() / 2.0
		$Sprite2D.offset = half_texture_size - real_center

	set_deferred("freeze", false)


func _clear_extra_colliders() -> void:
	for poly in _extra_collision_polygons:
		poly.queue_free()
	_extra_collision_polygons.clear()

#------END CLAUDE-----------------------------------------------------------
#---------------------------------------------------------------------------


func calculateBonusTorque() -> float:
	var points = $CollisionPolygon2D.polygon

	# Find the radius (max distance from center to any point)
	var max_radius: float = 0.0
	for p in points:
		max_radius = maxf(max_radius, p.length())
	#Incase there are multiple different lines so they have their own colliders
	for extra_poly in _extra_collision_polygons:
		for p in extra_poly.polygon:
			max_radius = maxf(max_radius, p.length())

	# Simple Linear Scaling: BaseTorque + (MaxRadius * BonusTorquePerPix) - larger wheels get more torque and and spin appropriately
	var torqueBonus = (max_radius * torque_per_pixel)
	return torqueBonus

func drive(direction: float, base_power: float) -> void:
	var total_torque = base_power + calculateBonusTorque()
	apply_torque(direction * total_torque)


func _ready() -> void:
	# Automatically generate polygon with X vertices and Y radius
	var test_points = generate_test_circle(4,50)
	# Pass it into the wheel's setup function
	setup_drawn_wheel(test_points)
