extends Node
enum turns {player, enemy, ally}

var cursor
var player_units: Array
var enemy_units: Array
var ally_units: Array
var current_turn = turns.player

func _ready():
	cursor = get_node("/root/" + get_tree().get_current_scene().name + "/Cursor")
	classify_units()

func _process(_delta):
	if current_turn == turns.player:
		player_turn()
	elif current_turn == turns.enemy:
		enemy_turn()
	elif current_turn == turns.ally:
		ally_turn()

func player_turn():
	cursor.enable_cursor()
	var turn_ended
	for unit in player_units:
		if unit.has_moved: #cambiar a has ended cuando ya se pueda atacar, esto es para pruebas
			turn_ended = true
	if turn_ended:
		current_turn = turns.enemy
		for unit in player_units:
			unit.has_moved = false #aca igual

func enemy_turn():
	cursor.disable_cursor(cursor) #cambiar cuando ya se tenga camara
	var turn_ended
	for unit in enemy_units:
		if unit.has_moved: #cambiar a has ended cuando ya se pueda atacar, esto es para pruebas
			turn_ended = true
	if enemy_units.size() == 0: #If there are no enemy units left
		turn_ended = true
	if turn_ended:
		current_turn = turns.ally
		for unit in enemy_units:
			unit.has_moved = false #aca igual

func ally_turn():
	cursor.disable_cursor(cursor) #cambiar cuando ya se tenga camara
	var turn_ended
	for unit in ally_units:
		if unit.has_moved: #cambiar a has ended cuando ya se pueda atacar, esto es para pruebas
			turn_ended = true
	if ally_units.size() == 0: #If there are no ally units left
		turn_ended = true
	if turn_ended:
		current_turn = turns.player
		for unit in ally_units:
			unit.has_moved = false #aca igual

func classify_units():
	var units = get_node("/root/" + get_tree().get_current_scene().name + "/Units")
	for unit in units.get_children():
		if(unit.allegiance == unit.allegiances.player):
			player_units.insert(player_units.size(), unit)
		elif(unit.allegiance == 1):
			enemy_units.insert(enemy_units.size(), unit)
		elif(unit.allegiance == 2):
			ally_units.insert(ally_units.size(), unit)
