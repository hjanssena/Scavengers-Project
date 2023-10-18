extends Unit

var aggro
var best_target
@export var aggro_range: float
@export var target_cells: Array[Marker2D]
@export var target_units: Array[Node2D]
@export var level = 1 #Mas adelante cuando se tengan los stats y el progreso, se podrian auto-generar los stats en base al nivel

func _process(delta):
	if moving:
		move(delta)
	if has_moved:
		end_turn()

func start_turn(player_units, enemy_units, ally_units): #Here goes all the setup for the AI turn
	find_selectable_squares()
	if !aggro:
		aggro_check(player_units, enemy_units, ally_units)
	if aggro:
		best_target = get_best_target(player_units, enemy_units, ally_units)
		if best_target == null:
			end_turn()
	if(best_target != null):
		set_movement(best_target)
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

func get_best_target(player_units, enemy_units, ally_units): #Main AI decision making function
	best_target = null
	var priority_level = 0
	var damage = 0
	
	for square in target_cells: #Si puede llegar a la celda objetivo, se le da prioridad maxima
		if square.selectable:
			return square 
	
	for unit in target_units: #Si se tiene a una unidad objetivo cerca, priorizar
		var available_squares = get_available_adyacent_squares(unit, attack_range)
		var closest_square
		for square in available_squares:
			if closest_square == null:
				closest_square = square
			elif current_square.position.distance_to(square.transform.origin) < current_square.position.distance_to(closest_square.transform.origin):
				closest_square = square
		return closest_square
