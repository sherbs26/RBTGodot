extends KinematicBody

var direction = Vector3.FORWARD

func _physics_process(delta):

	direction = Vector3(Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"),
	0,
	Input.get_action_strength("strafe_left") - Input.get_action_strength("strafe_right"))
	
	move_and_slide(direction, Vector3.UP)
