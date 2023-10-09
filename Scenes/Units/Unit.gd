extends Node2D

class_name Unit

#bfs
var squares: Array
var current_square
var selectable_squares: Array

#board movement
@export var movement_speed = 130
var moving = false
var current_move_square
var path: Array

#unit status
var has_moved

#unit stats
var hitpoints
var strength
var magic
var skill
var speed
var luck
var defense
var resistance
var movement = 2
var build

var attack_range = 2

func _ready():
	get_square_array()

func _process(delta):
	move(delta)

func set_current_square():
	current_square = get_target_square(transform.get_origin())
	current_square.current = true

func get_target_square(square_position):
	square_position.x -= 32
	square_position.y -= 32
	var square = get_node_or_null("/root/TestMap/Grid/" + str(square_position.x / 64) + "_" + str(square_position.y / 64))
	return square

func get_square_array():
	var grid = get_node("/root/" + get_tree().get_current_scene().name + "/Grid")
	squares = grid.get_children()

func find_selectable_squares():
	compute_adjacency_lists()
	set_current_square()
	
	var square_queue: Array
	square_queue.insert(square_queue.size(), current_square)
	current_square.visited = true
	current_square.selectable = true
	
	while square_queue.size() > 0:
		var square = square_queue[0]
		square_queue.remove_at(0)
		
		if !has_moved :
			if square.distance < movement:
				for s in square.adjacency_list:
					var occupied = s.get_occupant()
					if !s.visited && occupied == null:
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.selectable = true
						square_queue.insert(square_queue.size(), s)
					elif !s.visited && occupied != null && get_meta(occupied.collider.get_parent().get_meta()) == "ally":
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.selectable = false
						square_queue.insert(square_queue.size(), s)
			elif square.distance < movement + attack_range:
				for s in square.adjacency_list:
					var occupied = s.get_occupant()
					if !s.visited && occupied == null:
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.attackable = true
						square_queue.insert(square_queue.size(), s)
					elif !s.visited && occupied != null && get_meta(occupied.collider.get_parent().get_meta()) == "enemy":
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.attackable = true
						square_queue.insert(square_queue.size(), s)
		else:
			if square.distance < attack_range:
				for s in square.adjacency_list:
					var occupied = s.get_occupant()
					if !s.visited && occupied == null:
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.attackable = true
						square_queue.insert(square_queue.size(), s)
					elif !s.visited && occupied != null && get_meta(occupied.collider.get_parent().get_meta()) == "enemy":
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.attackable = true
						square_queue.insert(square_queue.size(), s)

func set_movement(target_square):
	var sqr = target_square
	path.insert(path.size(),sqr)
	while sqr != current_square:
		sqr = sqr.current_parent
		path.insert(path.size(), sqr)
	moving = true

func move(delta):
	if moving:
		var direction = Vector2(path[path.size() -1].transform.get_origin().x + 32, path[path.size() -1].transform.get_origin().y + 32)
		var velocity = position.direction_to(direction) * movement_speed
		
		if position.distance_to(direction) <= (velocity.x + velocity.y) * delta:
			var set_position 
			transform.origin = direction
			path.remove_at(path.size() -1)
			if(path.size() <= 0):
				path.clear()
				has_moved = true
				moving = false
		else:
			#look_at(path[0].transform.get_origin())
			transform.origin = transform.origin + velocity * delta

func compute_adjacency_lists():
	for square in squares:
		square.find_neighbors
