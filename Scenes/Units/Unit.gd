extends Node2D

class_name Unit
var rng = RandomNumberGenerator.new()

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
var movement #movimiento en los tiles
var build #Puede servir para las empujadas

var status_effects: Array
var hitpoints
@export var equiped_weapon: Weapons
var attack_range = 0

#Resources
var skill_tree
var skills
var map_sprite
var portrait
@export var info: unit_info

func _ready():
	if(equiped_weapon == null):
		equiped_weapon = info.inventory[0]
	compute_stats()
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
	if(current_square != null):
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
				var hit_probability = calculate_hit_probability(occupant, weapon)
				if hit_probability > rng.randf_range(0,100):
					occupant.take_damage(get_weapon_damage(weapon, occupant))
					if weapon.status_effect != null:
						var status_probability = calculate_status_effect_probability(occupant, weapon)
						if status_probability > rng.randf_range(0,100):
							occupant.apply_status_effect(weapon.status_effect)
				else:
					occupant.missed_attack()

func attack_ai(target, weapon):
	for aoe in weapon.area_of_effect:
		aoe.x = aoe.x * 64 + target.transform.origin.x + 32
		aoe.y = aoe.y * 64 + target.transform.origin.y + 32
		var square = get_target_square(aoe)
		if square != null:
			var occupant = square.get_occupant_unit()
			if occupant != null && occupant.allegiance != allegiance:
				var hit_probability = calculate_hit_probability(occupant, weapon)
				if hit_probability > rng.randf_range(0,100):
					occupant.take_damage(get_weapon_damage(weapon, occupant))
				else:
					occupant.missed_attack()

func get_weapon_damage(weapon, target):
	var damage
	compute_stats()
	target.compute_stats()
	match weapon.damage_type:
		0:#physical
			damage = weapon.dam_heal_value + strength - target.info.defense
		1:#magical
			damage = weapon.dam_heal_value + magic - target.info.resistance
	return damage

func get_status_effect_damage(effect, target):
	var damage
	compute_stats()
	target.compute_stats()
	match effect.damage_type:
		0:#physical
			damage = effect.dam_heal_value - target.info.defense/2
		1:#magical
			damage = effect.dam_heal_value - target.info.resistance/2
	return damage

func get_weapon_range(weapon):
	for range in weapon.range:
		range.x = range.x * 64 + transform.origin.x
		range.y = range.y * 64 + transform.origin.y
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
				occupant.peek_damage(get_weapon_damage(weapon, occupant), calculate_hit_probability(occupant, weapon))

func calculate_hit_probability(target, weapon):
	compute_stats()
	target.compute_stats()
	return (75 + skill*10 + speed*7) - (target.skill*10 + target.speed*7)

func calculate_status_effect_probability(target, weapon):
	compute_stats()
	target.compute_stats()
	return (weapon.status_hit*100 + skill*10 + speed*7) - (target.skill*10 + target.speed*7)

func take_damage(damage):
	hitpoints -= damage
	$Control/Label.show_damage(damage)
	$Control/HPBar.value = hitpoints
	if(hitpoints <= 0):
		death()

func take_healing(healing):
	hitpoints += healing
	if hitpoints > info.hit_points:
		hitpoints = info.hit_points
	$Control/Label.show_damage(healing)
	$Control/HPBar.value = hitpoints

func missed_attack():
	$Control/Label.show_miss()

func apply_status_effect(status_effect):
	status_effects.insert(status_effects.size(), status_effect)

func peek_damage(damage, hit_percent):
	$Control/HPBarPeek.displayed_value = damage
	$Control/Label.show_hit_percent(hit_percent)

func end_turn():
	current_turn_status = turn_status.turn_ended

func compute_stats(): #Aca se procesan todos los stats con los buffs y debuffs que se tengan
	#Tomar stats base
	strength = info.strength
	magic = info.magic_stat
	skill = info.skill
	speed = info.speed
	defense = info.defense
	resistance = info.resistance
	movement = info.movement
	build = info.build
	
	#Aplicar el penalty de peso de arma si aplica
	var skill_penalty = build - equiped_weapon.weight
	var speed_penalty = (build - equiped_weapon.weight)/2
	if skill_penalty > 0:
		skill -= skill_penalty
		speed -= speed_penalty
	
	#Aplicar stats del tile en que estan parados
	set_current_square() #Refrescar tile actual
	if (current_square != null):
		defense = defense + current_square.bonus_defense
		skill = skill + current_square.bonus_skill
		speed = speed + current_square.bonus_speed
	#Aplicar status effects que afecten a los stats base
	for effect in status_effects:
		if effect.effect_type == 0:#stat_modifier
			match effect.stat_affected:
				1: #strength
					strength += effect.value
				2: #magic
					magic += effect.value
				3: #defense
					defense += effect.value
				4: #resistance
					resistance += effect.value
				5: #skill
					skill += effect.value
				6: #speed
					speed += effect.value
				7: #build
					build += effect.value

func death():
	current_turn_status = turn_status.dead
	visible = false
	transform.origin = Vector2(-1000,1000)

func apply_turn_status_effects():
	for effect in status_effects: #Applied status effects
		match effect.type:
			0:#stat_modifier:
				pass
			1:#turn_blocker
				end_turn()
			2:#damaging
				take_damage(get_status_effect_damage(effect, self))
			3:#healing
				take_healing(effect.value)
