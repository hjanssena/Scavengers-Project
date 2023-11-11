extends Node2D

class_name Unit

enum turn_status {not_selected, deciding_move, moving, deciding_action, deciding_target, doing_action, turn_ended, dead}
enum allegiances {player, enemy, ally}
@export var allegiance: allegiances

#bfs
var squares: Array
var current_square
var selectable_squares: Array

#board movement
@export var movement_speed = 130
var current_move_square
var path: Array

#unit status
var current_turn_status = turn_status.not_selected

#unit stats
var strength #Dano fisico
var magic #Dano magico
var skill #Afecta a la probabilidad de que no te esquiven y de criticos
var speed #Esquivadas y probabilidad de pegar una vez extra tal vez?
var defense #Defensa fisica
var resistance #Resistencia magica
var movement = 3 #movimiento en los tiles
var build #Puede servir para las empujadas

var hitpoints
var attack_range = 3

#Resources
var skill_tree
var skills
var map_sprite
var portrait
@export var info: unit_info

func _ready():
	get_square_array()
	$Control/HPBar.max_value = info.hit_points
	hitpoints = info.hit_points
	$Control/HPBar.value = hitpoints

func _process(delta):
	move(delta)
	if current_turn_status == turn_status.turn_ended:
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
		
		if current_turn_status == turn_status.not_selected || turn_status.deciding_move:
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
	current_turn_status = turn_status.moving

func move(delta):
	if current_turn_status == turn_status.moving:
		var direction = Vector2(path[path.size() -1].transform.get_origin().x + 32, path[path.size() -1].transform.get_origin().y + 32)
		var velocity = position.direction_to(direction) * movement_speed
		
		if position.distance_to(direction) <= (velocity.x + velocity.y) * delta:
			transform.origin = direction
			path.remove_at(path.size() -1)
			if(path.size() <= 0):
				path.clear()
				current_turn_status = turn_status.deciding_action
		else:
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

func attack_cursor(target, weapon):
	for aoe in weapon.area_of_effect:
		aoe.x = aoe.x * 64 + target.transform.origin.x
		aoe.y = aoe.y * 64 + target.transform.origin.y
		var square = get_target_square(aoe)
		if square != null:
			var occupant = square.get_occupant_unit()
			if occupant != null && occupant.allegiance != allegiance:
				occupant.take_damage(get_weapon_damage(weapon, occupant))

func attack_ai(target, weapon):
	for aoe in weapon.area_of_effect:
		aoe.x = aoe.x * 64 + target.transform.origin.x + 32
		aoe.y = aoe.y * 64 + target.transform.origin.y + 32
		var square = get_target_square(aoe)
		if square != null:
			var occupant = square.get_occupant_unit()
			if occupant != null && occupant.allegiance != allegiance:
				occupant.take_damage(get_weapon_damage(weapon, occupant))

func get_weapon_damage(weapon, target):
	var damage
	damage = weapon.dam_heal_value - target.info.defense
	return damage

func get_weapon_range(weapon):
	for range in weapon.range:
		range.x = range.x * 64 + transform.origin.x + 32
		range.y = range.y * 64 + transform.origin.y + 32
		var square = get_target_square(range)
		if square != null:
			square.attackable = true

func get_weapon_aoe(weapon, target):
	for aoe in weapon.area_of_effect:
		aoe.x = aoe.x * 64 + target.transform.origin.x
		aoe.y = aoe.y * 64 + target.transform.origin.y
		var square = get_target_square(aoe)
		if square != null:
			square.affected = true
			var occupant = square.get_occupant_unit()
			if occupant != null && occupant.allegiance != allegiance:
				occupant.peek_damage(get_weapon_damage(weapon, occupant))

func take_damage(damage):
	hitpoints -= damage
	$Control/Label.show_damage(damage)
	$Control/HPBar.value = hitpoints
	if(hitpoints <= 0):
		death()

func peek_damage(damage):
	$Control/HPBarPeek.displayed_value = damage

func take_healing(healing):
	hitpoints += healing
	$Label.show_healing(healing)

func end_turn():
	current_turn_status = turn_status.turn_ended

func death():
	current_turn_status = turn_status.dead
	visible = false
	transform.origin = Vector2(-1000,1000)
