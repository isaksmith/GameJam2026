extends RigidBody2D
#I THINK THIS ISNT ALL NEEDED BUT WILL FIX IF IT IS

@export var torque_per_pixel: float = 3000.0 # Extra torque per pixel of radius


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
	#if drawn_points.size() < 3:
		#push_warning("Wheel shape requires at least 3 points!")
		#return
	# Finds the exact middle of whatever shape the player drew, averages all points
	var center = Vector2.ZERO
	for point in drawn_points:
		center += point
	center /= drawn_points.size()
	
	# Shift all points so the drawing's center sits perfectly on center of mass
	var centered_points = PackedVector2Array()
	for point in drawn_points:
		centered_points.append(point - center)
		
	# Update the physical wheel shape
	$CollisionPolygon2D.polygon = centered_points
	if has_node("Sprite2D"):
		$Sprite2D.centered = false
		$Sprite2D.position = -center
	
	
func calculateBonusTorque() -> float:
	var points = $CollisionPolygon2D.polygon

	# Find the radius (max distance from center to any point)
	var max_radius: float = 0.0
	for p in points:
		max_radius = maxf(max_radius, p.length())

	# Simple Linear Scaling: BaseTorque + (MaxRadius * BonusTorquePerPix) - larger wheels get more torque and and spin appropriately
	var torqueBonus = (max_radius * torque_per_pixel)
	return torqueBonus

func drive(direction: float, base_power: float) -> void:
	var total_torque = base_power + calculateBonusTorque()
	apply_torque(direction * total_torque)


func _ready() -> void:
	# Automatically generate polygon with X vertices and Y radius
	var test_points = generate_test_circle(32,150)
	# Pass it into the wheel's setup function
	setup_drawn_wheel(test_points)
	
	
