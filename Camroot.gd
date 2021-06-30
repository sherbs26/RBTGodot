extends Spatial

var camrot_h = 0
var camrot_v = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x
		camrot_v += -event.relative.y
		
func _physics_process(delta):
	
	$h.rotation_degrees.y = camrot_h
	$h/v.rotation_degrees.x = camrot_v
	
