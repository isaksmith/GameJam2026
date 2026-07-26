extends Node2D
@onready var front_wheel = $chassis/PinJoint2D_Front/frontWheel
@onready var rear_wheel = $chassis/PinJoint2D_Rear/rearWheel
@onready var front_wheel_sprite = $chassis/PinJoint2D_Front/frontWheel/Sprite2D
@onready var rear_wheel_sprite = $chassis/PinJoint2D_Rear/rearWheel/Sprite2D


func on_kill():
	print("killed :(")
	$AnimatedSprite2D.position = $chassis.position + Vector2(0,-60)
	$chassis/chassisSprite.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")
	pass

func apply_custom_texture(texture):
	front_wheel_sprite.texture = texture
	rear_wheel_sprite.texture = texture
	print(texture)

func apply_custom_wheels(drawn_points: PackedVector2Array) -> void:
	if is_instance_valid(front_wheel):
		front_wheel.setup_drawn_wheel(drawn_points)
		
	if is_instance_valid(rear_wheel):
		rear_wheel.setup_drawn_wheel(drawn_points)

func _process(delta: float) -> void:
	#front_wheel_sprite.global_position = $chassis/PinJoint2D_Front/frontWheel/CollisionPolygon2D.global_position
	#rear_wheel_sprite.global_position = $chassis/PinJoint2D_Rear/rearWheel/CollisionPolygon2D.global_position

	pass
