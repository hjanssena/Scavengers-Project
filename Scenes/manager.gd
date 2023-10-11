#Controls the player-enemy-ally turns and the AI turns
extends Node
enum turns {player, enemy, ally}

var cursor
var grid
var player_units: Array
var enemy_units: Array
var ally_units: Array
var current_unit
var unit_turn = 0 #Controla el numero de turno de las unidades AI
var current_turn = turns.player

func _ready():
	cursor = get_node("/root/" + get_tree().get_current_scene().name + "/Cursor")
	grid = get_node("/root/" + get_tree().get_current_scene().name + "/Grid")
	classify_units()

func _process(_delta):
	if current_turn == turns.player:
		player_turn()
	elif current_turn == turns.enemy:
		enemy_turn()
	elif current_turn == turns.ally:
		ally_turn()
	
	if current_unit != null && !current_unit.moving:
		current_unit.start_turn(player_units, enemy_units, ally_units)

func player_turn():
	cursor.enable_cursor()
	var all_ended = true
	for unit in player_units:
		if !unit.has_moved: #cambiar a has ended cuando ya se pueda atacar, esto es para pruebas
			all_ended = false
	if all_ended:
		end_turn(player_units, turns.enemy)

func enemy_turn():
	if enemy_units.size() == 0: #If there are no enemy units left
		end_turn(enemy_units,turns.ally)
	cursor.disable_cursor(cursor) #cambiar cuando ya se tenga camara
	if current_unit == null || current_unit.has_moved:
		set_next_unit(enemy_units)
	if current_unit == null:
		end_turn(enemy_units,turns.ally)
	elif enemy_units.size() == 0: #If there are no enemy units left
		end_turn(enemy_units,turns.ally)

func ally_turn():
	if enemy_units.size() == 0: #If there are no enemy units left
		end_turn(ally_units,turns.player)
	cursor.disable_cursor(cursor) #cambiar cuando ya se tenga camara
	if current_unit == null || current_unit.has_moved:
		set_next_unit(ally_units)
	if current_unit == null:
		end_turn(ally_units,turns.player)
	elif enemy_units.size() == 0: #If there are no enemy units left
		end_turn(ally_units,turns.player)

func classify_units():
	var units = get_node("/root/" + get_tree().get_current_scene().name + "/Units")
	for unit in units.get_children():
		if(unit.allegiance == unit.allegiances.player):
			player_units.insert(player_units.size(), unit)
		elif(unit.allegiance == 1):
			enemy_units.insert(enemy_units.size(), unit)
		elif(unit.allegiance == 2):
			ally_units.insert(ally_units.size(), unit)

func end_turn(units_array, next_turn):
	current_turn = next_turn
	for unit in units_array:
		unit.has_moved = false #aca igual

func set_next_unit(unit_array: Array):
	if unit_turn < unit_array.size() && unit_array.size() > 0:
		current_unit = unit_array[unit_turn]
		unit_turn = unit_turn + 1
	else:
		unit_turn = 0
		current_unit = null
