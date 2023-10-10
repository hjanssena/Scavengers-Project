extends Unit

var aggro
var best_target
@export var aggro_range = movement
@export var target_cells: Array[Marker2D]
@export var target_units: Array[Node2D]
@export var level = 1 #Mas adelante cuando se tengan los stats y el
#progreso, se auto generaran los stats en base al nivel

func decide_action(player_units, enemy_units, ally_units):
	var objectives: Array
	objectives = player_units
	objectives += ally_units
	objectives += target_cells
	objectives += target_units
	
	if !aggro:
		for objective in objectives:
			var distance = position.distance_to(objective.get_origin())
			if distance <= aggro_range:
				aggro = true
	
	if aggro:
		best_target = null
		best_target = get_best_target(player_units, enemy_units, ally_units)
		if best_target == null:
			end_turn()

func get_best_target(player_units, enemy_units, ally_units):
	var priority_level = 0
	var damage = 0
	
	for square in target_cells: #Si puede llegar a la celda objetivo se le da prioridad maxima
		if square.selectable:
			return square 
	
	for unit in target_units: #Si se tiene a una unidad objetivo cerca, priorizar
		var available_squares = get_available_adyacent_squares(unit, attack_range)
		var closest_square
		for square in available_squares:
			if closest_square == null:
				closest_square = square
			elif position.distance_to(square) < position.distance_to(closest_square):
				closest_square = square
		return closest_square

func end_turn():
	
	pass


