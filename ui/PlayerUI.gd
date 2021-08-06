extends Control
#create the level counter HUD element
onready var level : = $CenterContainer/Column/levelCounter

func _process(delta):
	level.text = str("Current level: ", PlayerVariables.currentLevel)
