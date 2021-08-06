extends Spatial

var mazeH = 4 + PlayerVariables.currentLevel
var mazeW = 4 + PlayerVariables.currentLevel
var pathWidth = 7
var stack = [[]]
var maze = []
#define bit flags for cell paths
const CELL_PATH_N = 1 << 1
const CELL_PATH_E = 1 << 2
const CELL_PATH_S = 1 << 3
const CELL_PATH_W = 1 << 4
const CELL_VISITED = 1 << 5
var visitedCells = 0

onready var Map = $GridMap

func _ready():
	PlayerVariables.currentLevel += 1
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	make_maze()
	make_exit()
	create_timer()

func make_maze():
	Map.clear()
	#create maze walls and fill in the "cell" walls
	for _i in range(mazeW*mazeH):
		maze.append(0)
	
	for _k in range(mazeH*(pathWidth+1)):
		Map.set_cell_item(-1, 0, _k, 2)
		for _j in range(mazeW*(pathWidth+1)):
			Map.set_cell_item(_j, 0, -1, 2)
	
	for _x in range(mazeW*(pathWidth+1)):
		for _y in range(mazeH*(pathWidth+1)):
			Map.set_cell_item(_x, 0, _y, 2)
		
	
	var xCoord = randi() % mazeW
	var yCoord = randi() % mazeH
	stack.push_back(Vector2(xCoord,yCoord))
	maze[yCoord * mazeW + xCoord] = CELL_VISITED
	visitedCells = 1
	
	while (visitedCells < (mazeH * mazeW)):
		#create set of unvisited neighbours
		var neighbours = []
		#NORTH Neighbour
		if(stack.back()[1] > 0):
			if(maze[(stack.back()[1] - 1) * mazeW + (stack.back()[0])] & CELL_VISITED == 0):
				neighbours.push_back(0)
		
		#EAST Neighbour
		if(stack.back()[0] < mazeW - 1):
			if(maze[(stack.back()[1]) * mazeW + (stack.back()[0] + 1)] & CELL_VISITED == 0):
				neighbours.push_back(1)
		
		#SOUTH Neighbour
		if(stack.back()[1] < mazeH - 1):
			if(maze[(stack.back()[1] + 1) * mazeW + (stack.back()[0])] & CELL_VISITED == 0):
				neighbours.push_back(2)
		
		#WEST Neighbour
		if(stack.back()[0] > 0):
			if(maze[(stack.back()[1]) * mazeW + (stack.back()[0] - 1)] & CELL_VISITED == 0):
				neighbours.push_back(3)
		
		if (!neighbours.empty()):
			var next_cell_dir = neighbours[randi() % neighbours.size()]
			
			match next_cell_dir:
				0: #NORTH
					maze[(stack.back()[1]) * mazeW + (stack.back()[0])] |= CELL_VISITED | CELL_PATH_S
					maze[(stack.back()[1] - 1) * mazeW + (stack.back()[0])] |= CELL_PATH_N
					stack.push_back(Vector2(stack.back()[0] + 0, stack.back()[1] - 1))
				1: #EAST
					maze[(stack.back()[1]) * mazeW + (stack.back()[0])] |= CELL_VISITED | CELL_PATH_W
					maze[(stack.back()[1] + 0) * mazeW + (stack.back()[0] + 1)] |= CELL_PATH_E
					stack.push_back(Vector2(stack.back()[0] + 1, stack.back()[1] + 0))
				2: #SOUTH
					maze[(stack.back()[1]) * mazeW + (stack.back()[0])] |= CELL_VISITED | CELL_PATH_N
					maze[(stack.back()[1] + 1) * mazeW + (stack.back()[0])] |= CELL_PATH_S
					stack.push_back(Vector2(stack.back()[0] + 0, stack.back()[1] + 1))
				3: #WEST
					maze[(stack.back()[1]) * mazeW + (stack.back()[0])] |= CELL_VISITED | CELL_PATH_E
					maze[(stack.back()[1] + 0) * mazeW + (stack.back()[0] - 1)] |= CELL_PATH_W
					stack.push_back(Vector2(stack.back()[0] -1 , stack.back()[1] + 0))
			maze[(stack.back()[1]) * mazeW + (stack.back()[0])] |= CELL_VISITED 
			visitedCells = visitedCells + 1
		else:
			stack.pop_back()
			
	for x in mazeW:
		for y in mazeH:
			for py in pathWidth:
				for px in pathWidth:
					if (maze[y* mazeW + x] & CELL_VISITED):
						Map.set_cell_item(x*(pathWidth+1) + px,0,y*(pathWidth+1) +py, 0)
					else:
						Map.set_cell_item(x*(pathWidth+1) + px,0,y*(pathWidth+1) +py, 1)
			for p in pathWidth:
				if maze[y* mazeW + x] & CELL_PATH_N:
					Map.set_cell_item(x*(pathWidth+1) + p, 0, y*(pathWidth+1) + pathWidth, 0)
				if maze[y* mazeW + x] & CELL_PATH_W:
					Map.set_cell_item(x*(pathWidth+1) + pathWidth, 0, y*(pathWidth+1) + p, 0)
	
	#place event trigger at top of the stack
	for py in pathWidth:
				for px in pathWidth:
					Map.set_cell_item(stack.back()[0] * (pathWidth + 1)+ px, 0,stack.back()[1] * (pathWidth + 1) + py , 3)

func make_exit():
	#create exit point using last coordinates of the stack
	var exitPoints = []
	for py in pathWidth:
			for px in pathWidth:
				exitPoints.push_back(Vector3(Map.map_to_world(stack.back()[0] * (pathWidth + 1) + px, 0,stack.back()[1] * (pathWidth + 1) + py)))
	var exitCoords = Vector3((exitPoints.front()[0]+(pathWidth/2)),0,exitPoints.back()[2]-(pathWidth/2))
	
	var shape = BoxShape.new()
	var shapeExtents = Vector3((pathWidth/2), 10, (pathWidth/2))
	shape.set_extents(shapeExtents)
	$ExitArea/CollisionShape.set_shape(shape)
	$ExitArea.global_translate(exitCoords)

func create_timer(): #create a timer for the player
	var timer
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(60) #60 seconds
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	get_tree().change_scene("res://GameOverScene.tscn") #change scene on timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	PlayerVariables.currentLevel = 0 #set current 
