extends Node2D

class_name Unit

enum allegiances {player, enemy, ally}
@export var allegiance: allegiances

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
var has_moved = false
var turn_ended = false

#unit stats
var hitpoints #xd
var strength #Dano fisico
var magic #Dano magico
var skill #Afecta a la probabilidad de que no te esquiven y de criticos
var speed #Esquivadas y probabilidad de pegar una vez extra tal vez?
var luck #Afecta criticos y esquivadas de manera oculta
var defense #Defensa fisica
var resistance #Resistencia magica
var movement = 3 #movimiento en los tiles
var build #Puede servir para las empujadas

var attack_range = 2

func _ready():
	get_square_array()

func _process(delta):
	move(delta)
	
	if turn_ended:
		$AnimatedSprite2D.modulate.a = .6
	else:
		$AnimatedSprite2D.modulate.a = 1

func get_current_square():
	return get_target_square(transform.get_origin())

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

#STILL HAVE TO IMPLEMENT INTERACTABLE
func find_selectable_squares(): #Assing all squares that apply the selectable, attackable and interactable properties
	compute_adyacency_lists()
	set_current_square()
	
	var ally
	var enemy
	var enemy_ally
	
	if allegiance == allegiances.player:
		ally = allegiances.ally
		enemy = allegiances.enemy
		enemy_ally = 99
	elif allegiance == allegiances.enemy:
		ally = 99
		enemy = allegiances.player
		enemy_ally = allegiances.ally
	else:
		ally = allegiances.player
		enemy = allegiances.enemy
		enemy_ally = 99
	
	var square_queue: Array
	square_queue.insert(square_queue.size(), current_square)
	current_square.visited = true
	current_square.selectable = true
	
	while square_queue.size() > 0:
		var square = square_queue[0]
		square_queue.remove_at(0)
		
		if !has_moved:
			if square.distance < movement:
				for s in square.adjacency_list:
					var occupied = s.get_occupant()
					if !s.visited && occupied == null:
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.selectable = true
						square_queue.insert(square_queue.size(), s)
					if !s.visited && occupied != null:
						if occupied.collider.get_parent().allegiance == allegiance || occupied.collider.get_parent().allegiance == ally:
							s.current_parent = square
							s.visited = true
							s.distance = 1 + s.movement_cost + square.distance
							s.selectable = false
							square_queue.insert(square_queue.size(), s)
					if !s.visited && occupied != null:
						if occupied.collider.get_parent().allegiance == enemy || occupied.collider.get_parent().allegiance == enemy_ally:
							s.visited = true
							s.distance = 1 + s.movement_cost + square.distance
							s.attackable = true
			elif square.distance < movement + attack_range:
				for s in square.adjacency_list:
					var occupied = s.get_occupant()
					if !s.visited && occupied == null:
						s.current_parent = square
						s.visited = true
						s.distance = 1 + s.movement_cost + square.distance
						s.attackable = true
						square_queue.insert(square_queue.size(), s)
					if !s.visited && occupied != null:
						if occupied.collider.get_parent().allegiance == enemy || occupied.collider.get_parent().allegiance == enemy_ally:
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
					elif !s.visited && occupied != null:
						if occupied.collider.get_parent().allegiance == enemy || occupied.collider.get_parent().allegiance == enemy_ally:
							s.current_parent = square
							s.visited = true
							s.distance = 1 + s.movement_cost + square.distance
							s.attackable = true
							square_queue.insert(square_queue.size(), s)

func set_movement(target_square): #Builds the path for the unit to take when moving
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
			transform.origin = direction
			path.remove_at(path.size() -1)
			if(path.size() <= 0):
				path.clear()
				has_moved = true
				moving = false
		else:
			#look_at(path[0].transform.get_origin())
			transform.origin = transform.origin + velocity * delta

func compute_adyacency_lists():
	for square in squares:
		square.find_neighbors()

func get_available_adyacent_squares(unit, area):
	var target_square = unit.get_current_square()
	var squares_to_evaluate: Array
	var adyacent_squares: Array
	var next_iteration_squares: Array
	var iterations = 0
	squares_to_evaluate = target_square.get_available_neighbors()
	
	while iterations < area:
		for square in squares_to_evaluate:
			if square.selectable:
				adyacent_squares.insert(adyacent_squares.size(), square)
			for s in square.get_available_neighbors():
				if !s.target_visited:
					next_iteration_squares.insert(next_iteration_squares.size(), s)
			square.target_visited = true
		squares_to_evaluate += next_iteration_squares
		next_iteration_squares.clear()
		iterations += 1
	return adyacent_squares

func end_turn():
	turn_ended = true
