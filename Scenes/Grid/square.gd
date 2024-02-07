extends Marker2D

@export_category("Traversal flags")
#Movement variables
@export var walkable: bool
@export var wall: bool

#Breadth First Search
var visited
var distance = 0
var current_parent = null

var adjacency_list: Array

#Pseudo enemy BFS
var target_visited = false

#For grid coloring
var current = false #Your current square
var interactable #You can heal or interact with an object
var selectable #You can walk there
var attackable #You can attack it
var affected #Its affected by the aoe

var position_in_grid: Vector2

@export_category("Square stat modifiers")
@export var movement_cost: int
@export var bonus_defense: int
@export var bonus_skill: int
@export var bonus_speed: int

var manager
var cursor

func _ready():
	position_in_grid = transform.get_origin()
	manager = get_node("/root/" + get_tree().get_current_scene().name + "/Manager")
	cursor = get_node("/root/" + get_tree().get_current_scene().name + "/Cursor")

func _process(_delta):
	if manager.current_turn == 0:
		set_color()
	else:
		$SquareColor.color = Color.TRANSPARENT
	find_neighbors()

func set_square_type(): #Depending square type it gets assigned a speed, skill and movement penalty
	pass

func set_color():
	if current:
		$SquareColor.color = Color.MAGENTA
	elif affected:
		$SquareColor.color = Color.ORANGE
		if cursor.selected_unit == null:
			$SquareColor.color.a = 0.5
	elif interactable:
		$SquareColor.color = Color.GREEN
		if cursor.selected_unit == null:
			$SquareColor.color.a = 0.5
	elif selectable:
		$SquareColor.color = Color.BLUE
		if cursor.selected_unit == null:
			$SquareColor.color.a = 0.5
	elif attackable:
		$SquareColor.color = Color.RED
		if cursor.selected_unit == null:
			$SquareColor.color.a = 0.5
	else:
		$SquareColor.color = Color.TRANSPARENT

func reset_values():
	adjacency_list.clear()
	
	current = false
	interactable = false
	selectable = false
	attackable = false
	affected = false
	
	visited = false
	distance = 0
	current_parent = null
	
	target_visited = false

func find_neighbors (): #Uses check square function to check if adjacent squares have something in them
	reset_values()
	
	check_adyacent_square(Vector2.UP)
	check_adyacent_square(Vector2.DOWN)
	check_adyacent_square(Vector2.LEFT)
	check_adyacent_square(Vector2.RIGHT)

func check_adyacent_square(direction):
	var square_pos = transform.get_origin() + direction * 64
	var square_node = get_node_or_null("/root/" + get_tree().get_current_scene().name +"/Grid/" + str(square_pos.x / 64) + "_" + str(square_pos.y / 64))
	
	if square_node != null && square_node.walkable && !square_node.check_if_occupied():
		adjacency_list.insert(adjacency_list.size(), square_node)

func check_if_occupied():
	var square_pos = transform.get_origin()
	var target_pos = square_pos + Vector2(square_pos.x + 32, square_pos.y + 32)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(square_pos, target_pos)
	var result = space_state.intersect_ray(query)
	
	if result.size() == 0:
		return false
	else:
		return true

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

func get_occupant_unit():
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
		return result.collider.get_parent()

func get_neighbors():
	var squares: Array
	
	get_adyacent_square(Vector2.UP)
	get_adyacent_square(Vector2.DOWN)
	get_adyacent_square(Vector2.LEFT)
	get_adyacent_square(Vector2.RIGHT)
	
	return squares

func get_adyacent_square(direction):
	var square_pos = transform.get_origin() + direction * 64
	var square_node = get_node_or_null("/root/" + get_tree().get_current_scene().name +"/Grid/" + str(square_pos.x / 64) + "_" + str(square_pos.y / 64))
	
	if square_node != null && square_node.walkable:
		return square_node

func get_available_neighbors():
	var squares: Array
	var square
	
	square = get_available_adyacent_square(Vector2.UP)
	if square != null:
		squares.insert(squares.size(), square)
	square = get_available_adyacent_square(Vector2.DOWN)
	if square != null:
		squares.insert(squares.size(), square)
	square = get_available_adyacent_square(Vector2.LEFT)
	if square != null:
		squares.insert(squares.size(), square)
	square = get_available_adyacent_square(Vector2.RIGHT)
	if square != null:
		squares.insert(squares.size(), square)
	
	for s in squares:
		if square == null:
			squares.erase(square)
	return squares

func get_available_adyacent_square(direction):
	var square_pos = transform.get_origin() + direction * 64
	var square_node = get_node_or_null("/root/" + get_tree().get_current_scene().name +"/Grid/" + str(square_pos.x / 64) + "_" + str(square_pos.y / 64))
	
	if square_node != null && square_node.walkable && !square_node.check_if_occupied():
		return square_node
