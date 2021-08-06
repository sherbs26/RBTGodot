extends KinematicBody

var currentLevel = 0
var direction = Vector3.FORWARD
var movement_speed = 10
#player movement
func _physics_process(delta):
	
	var h_rot = $Camroot/h.global_transform.basis.get_euler().y
	
	direction = Vector3(Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left"),
				0,
				Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")).rotated(Vector3.UP, h_rot).normalized()
	
	move_and_slide(direction * movement_speed, Vector3.UP)
