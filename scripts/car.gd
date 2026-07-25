extends Node2D
@onready var front_wheel = $chassis/PinJoint2D_Front/frontWheel
@onready var rear_wheel = $chassis/PinJoint2D_Rear/rearWheel



func apply_custom_wheels(drawn_points: PackedVector2Array) -> void:
	if is_instance_valid(front_wheel):
		front_wheel.setup_drawn_wheel(drawn_points)
		
	if is_instance_valid(rear_wheel):
		rear_wheel.setup_drawn_wheel(drawn_points)
