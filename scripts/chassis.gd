extends RigidBody2D
@onready var front_wheel: RigidBody2D = $PinJoint2D_Front/frontWheel
@onready var rear_wheel: RigidBody2D = $PinJoint2D_Rear/rearWheel
@export var drive_power: float = 20000.0#increase for more speed/torque to climb hills
@export var rotate_power: float = 30000.0
@export var normal_texture: Texture2D
@export var scared_texture: Texture2D
@export var victory_texture: Texture2D

func setSprite(texture: Texture2D):
	$chassisSprite.texture = texture
func setVictorySprite():
	$chassisSprite.texture = victory_texture


func _physics_process(delta: float) -> void:
	#  Get horizontal input (-1 for left, 1 for right, 0 for none)
	if(linear_velocity.x >= 600 or linear_velocity.x <= -600 or linear_velocity.y <= -600 or linear_velocity.y >=600):
		setSprite(scared_texture)
	else:
		setSprite(normal_texture)
	

	var move_input := Input.get_axis("ui_left", "ui_right")
	if move_input != 0:
		#Apply torque to the wheels to make them roll
		front_wheel.drive(move_input, drive_power)
		rear_wheel.drive(move_input, drive_power)
		#apply torque to chassis so it rotates when mid air
		apply_torque(rotate_power*move_input)
