extends Area

func _ready():
	connect("body_entered", self, "_on_body_entered")
#create exit area functionality on physics body entering
func _on_body_entered(body):
	print(body, " entered exit area.")
	print("Current level: ", PlayerVariables.currentLevel)
	get_tree().change_scene("res://LevelGen.tscn")
