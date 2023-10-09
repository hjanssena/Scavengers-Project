extends Marker2D
enum squareType {plain, mud, water, sand, mountain}

#Movement variables
@export var walkable: bool
@export var flyable: bool
var occupied: bool

#Breadth First Search
var visited
var distance = 0
var current_parent = null

var adjacency_list: Array

#Pseudo enemy BFS
var target_visited = false
var target_selectable

#For grid coloring
var current #Your current square
var interactable #You can heal or interact with an object
var selectable #You can walk there
var attackable #You can attack it

#For A*
var f = 0
var g = 0
var h = 0

@export var position_in_grid: Vector2

#Penalties for standing on this square
@export var type: squareType
@export var movement_cost: int
var speed_penalty
var skill_penalty

func _ready():
	position_in_grid = transform.get_origin()

func _process(_delta):
	if current:
		$SquareColor.color = Color.MAGENTA
	elif interactable:
		$SquareColor.color = Color.GREEN
	elif selectable:
		$SquareColor.color = Color.BLUE
	elif attackable:
		$SquareColor.color = Color.RED
	else:
		$SquareColor.color = Color.TRANSPARENT
	
	find_neighbors(null)


func reset_values():
	adjacency_list.clear()
	
	current = false
	interactable = false
	selectable = false
	attackable = false
	
	visited = false
	distance = 0
	current_parent = null
	
	f = 0 
	g = 0 
	h = 0

func find_neighbors (target): #Uses check square function to check if adjacent squares have something in them
	reset_values()
	
	check_square(Vector2.UP, target)
	check_square(Vector2.DOWN, target)
	check_square(Vector2.LEFT, target)
	check_square(Vector2.RIGHT, target)

func check_square(direction, target):
	var square_pos = transform.get_origin() + direction * 64
	var square_node = get_node_or_null("/root/" + get_tree().get_current_scene().name +"/Grid/" + str(square_pos.x / 64) + "_" + str(square_pos.y / 64))
	
	if square_node != null && square_node.walkable && !square_node.occupied:
		adjacency_list.insert(adjacency_list.size(), square_node)
		

func check_if_occupied():
	var square_pos = transform.get_origin()
	var target_pos = square_pos + Vector2(square_pos.x + 32, square_pos.y + 32)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(square_pos, target_pos)
	var result = space_state.intersect_ray(query)
	
	if result != null:
		return true
	else:
		return false

func get_occupant():
	var square_pos = transform.get_origin()
	var target_pos = square_pos
	target_pos.x += 32
	target_pos.y += 32 
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(square_pos, target_pos)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return null
	else:
		return result

