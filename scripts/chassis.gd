extends RigidBody2D
@onready var front_wheel: RigidBody2D = $PinJoint2D_Front/frontWheel
@onready var rear_wheel: RigidBody2D = $PinJoint2D_Rear/rearWheel
@export var drive_power: float = 20000.0#increase for more speed/torque to climb hills
@export var rotate_power: float = 30000.0




func _physics_process(delta: float) -> void:
	#  Get horizontal input (-1 for left, 1 for right, 0 for none)


	var move_input := Input.get_axis("ui_left", "ui_right")
	if move_input != 0:
		#Apply torque to the wheels to make them roll
		front_wheel.drive(move_input, drive_power)
		rear_wheel.drive(move_input, drive_power)
		#apply torque to chassis so it rotates when mid air
		apply_torque(rotate_power*move_input)
