extends Unit

var aggro
var best_move
var best_attack
var best_weapon
var best_damage
@export var aggro_range: float
@export var target_cells: Array[Marker2D]
@export var target_units: Array[Node2D]
@export var level = 1 #Mas adelante cuando se tengan los stats y el progreso, se podrian auto-generar los stats en base al nivel

func _process(delta):
	if current_turn_status == turn_status.moving:
		move(delta)
	if current_turn_status == turn_status.deciding_action:
		current_turn_status = turn_status.doing_action
		attack_ai(best_attack, best_weapon)
		end_turn()

func start_turn(player_units, enemy_units, ally_units): #Here goes all the setup for the AI turn
	find_selectable_squares()
	best_move = null
	best_attack = null
	best_damage = 0
	
	if !aggro:
		aggro_check(player_units, enemy_units, ally_units)
	
	if aggro:
		plan_move(player_units, enemy_units, ally_units)
		if best_move == null:
			end_turn()
		else:
			set_movement(best_move)
	else:
		end_turn()

func aggro_check(player_units, enemy_units, ally_units): #Checks if unit is close enough. Once aggro activates it doesnt deactivate.
	var objectives: Array
	objectives = player_units
	objectives += ally_units
	objectives += target_cells
	objectives += target_units
	
	if !aggro:
		for objective in objectives:
			var distance = position.distance_to(objective.transform.origin)
			if distance/64 <= aggro_range:
				aggro = true

func plan_move(player_units, enemy_units, ally_units): #Main AI decision making function
	for square in target_cells: #Si puede llegar a la celda objetivo, se le da prioridad maxima
		if square.selectable:
			return square
	for square in squares:
		if square.selectable:
			get_best_attack(square)

func get_best_attack(selectable_square): #Checks in this tile all the possible attacks the unit can do and sets the best one on the global variables
	for weapon in info.inventory:
		for range in weapon.range:
			range.x = range.x * 64 + selectable_square.transform.origin.x + 32
			range.y = range.y * 64 + selectable_square.transform.origin.y + 32
			var possible_square = get_target_square(range)
			if possible_square != null:
				var damage = 0
				for aoe in weapon.area_of_effect:
					aoe.x = aoe.x * 64 + possible_square.transform.origin.x + 32
					aoe.y = aoe.y * 64 + possible_square.transform.origin.y + 32
					var attack_square = get_target_square(aoe)
					if attack_square != null:
						var occupant = attack_square.get_occupant_unit()
						if occupant != null && occupant.allegiance != allegiance:
							damage += get_weapon_damage(weapon, occupant)
				if(best_move == null):
					if(damage > 0):
						best_move = selectable_square
						best_attack = possible_square
						best_damage = damage
						best_weapon = weapon
				elif damage == best_damage && transform.origin.distance_to(selectable_square.transform.origin) < transform.origin.distance_to(best_move.transform.origin):
					best_move = selectable_square
					best_attack = possible_square
					best_weapon = weapon
				elif damage > best_damage:
					best_move = selectable_square
					best_attack = possible_square
					best_damage = damage
					best_weapon = weapon
