extends RigidBody2D
#I THINK THIS ISNT ALL NEEDED BUT WILL FIX IF IT IS

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

func setup_drawn_wheel(drawn_points: PackedVector2Array) -> void:
	#$CollisionPolygon2D.polygon = drawn_points
	# Finds the exact middle of whatever shape the player drew
	var center = Vector2.ZERO
	for point in drawn_points:
		center += point
	center /= drawn_points.size()
	
	# Shift all points so the drawing's center sits perfectly on the Rigidbody's (0,0)
	var centered_points = PackedVector2Array()
	for point in drawn_points:
		centered_points.append(point - center)
		
	# 2. Update the physical wheel shape
	$CollisionPolygon2D.polygon = centered_points
	
	



func _ready() -> void:
	# Automatically generate a 32-sided circular polygon with a 40px radius
	var test_points = generate_test_circle(32, 10)
		
	# Pass it into the wheel's setup function
	setup_drawn_wheel(test_points)
