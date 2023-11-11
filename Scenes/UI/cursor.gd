extends Node2D
signal show_action_menu (cursor)
signal hide_action_menu
signal show_attack_menu (cursor)

enum CursorMode {normal, target_select}

var cursor_moving
var original_position
var selected_unit
var selected_weapon
var enabled

var is_action_menu_open = false

var manager

func _ready():
	manager = get_node("/root/" + get_tree().get_current_scene().name + "/Manager")

func _process(_delta):
	if manager.current_turn == 0:
		if(selected_unit != null):
			match selected_unit.current_turn_status:
				Unit.turn_status.deciding_move:
					move()
					selected_unit.find_selectable_squares()
					if Input.is_action_just_pressed("action_button") && get_current_square().selectable:
						move_unit()
						disable_cursor()
					if Input.is_action_just_pressed("cancel_button"):
						transform.origin = selected_unit.transform.origin
						clear()
				Unit.turn_status.deciding_action:
					if (!is_action_menu_open):
						emit_signal("show_action_menu",self)
						disable_cursor()
						check_current_square()
						is_action_menu_open = true
				Unit.turn_status.deciding_target:
					enable_cursor()
					move()
					selected_unit.get_weapon_range(selected_weapon)
					if get_current_square().attackable: selected_unit.get_weapon_aoe(selected_weapon, self)
					if Input.is_action_just_pressed("cancel_button"):
						disable_cursor()
						selected_unit.current_turn_status = Unit.turn_status.deciding_action
						is_action_menu_open = true
						emit_signal("show_attack_menu",self)
					if Input.is_action_just_pressed("action_button"):
						selected_unit.current_turn_status = Unit.turn_status.doing_action
						selected_unit.attack(self, selected_weapon)
				Unit.turn_status.turn_ended:
					selected_unit = null
					enable_cursor()
		else:
			if !enabled: enable_cursor()
			move()
			check_current_square()
			if(Input.is_action_just_pressed("action_button")):
				select_unit()
	elif (enabled):
		disable_cursor()

func move():
	if ($cursor_timer.is_stopped() && cursor_moving):
		hold_move()
	else:
		tap_move()

func tap_move():
	if(Input.is_action_just_pressed("move_up")):
		if(peek_next_square(Vector2(0,-64))):
			position.y -= 64
			cursor_moving = true
			$cursor_timer.wait_time = .2
			$cursor_timer.start()
	elif (Input.is_action_just_pressed("move_down")):
		if(peek_next_square(Vector2(0,64))):
			position.y += 64
			cursor_moving = true
			$cursor_timer.wait_time = .2
			$cursor_timer.start()
	elif (Input.is_action_just_pressed("move_right")):
		if(peek_next_square(Vector2(64,0))):
			position.x += 64
			cursor_moving = true
			$cursor_timer.wait_time = .2
			$cursor_timer.start()
	elif (Input.is_action_just_pressed("move_left")):
		if(peek_next_square(Vector2(-64,0))):
			position.x -= 64
			cursor_moving = true
			$cursor_timer.wait_time = .2
			$cursor_timer.start()

func hold_move():
	if(Input.is_action_pressed("move_up")):
		if(peek_next_square(Vector2(0,-64))):
			position.y -= 64
			$cursor_timer.wait_time = .05
			$cursor_timer.start()
	elif (Input.is_action_pressed("move_down")):
		if(peek_next_square(Vector2(0,64))):
			position.y += 64
			$cursor_timer.wait_time = .05
			$cursor_timer.start()
	elif (Input.is_action_pressed("move_right")):
		if(peek_next_square(Vector2(64,0))):
			position.x += 64
			$cursor_timer.wait_time = .05
			$cursor_timer.start()
	elif (Input.is_action_pressed("move_left")):
		if(peek_next_square(Vector2(-64,0))):
			position.x -= 64
			$cursor_timer.wait_time = .05
			$cursor_timer.start()
	else:
		cursor_moving = false

func peek_next_square(direction):
	var current_pos = transform.get_origin() + direction
	current_pos.x -= 32
	current_pos.y -= 32
	var square_node = get_node_or_null("/root/TestMap/Grid/" + str(current_pos.x / 64) + "_" + str(current_pos.y / 64))
	
	if square_node == null:
		return false
	else:
		return true

func check_current_square():
	var current_pos = transform.get_origin()
	current_pos.x -= 32
	current_pos.y -= 32
	var square_node = get_node_or_null("/root/TestMap/Grid/" + str(current_pos.x / 64) + "_" + str(current_pos.y / 64))
	
	var occupant = square_node.get_occupant()
	
	if(occupant != null):
		occupant.collider.get_parent().find_selectable_squares()

func get_current_square():
	var current_pos = transform.get_origin()
	current_pos.x -= 32
	current_pos.y -= 32
	var square_node = get_node_or_null("/root/TestMap/Grid/" + str(current_pos.x / 64) + "_" + str(current_pos.y / 64))
	return square_node

func select_unit():
	var current_pos = transform.get_origin()
	current_pos.x -= 32
	current_pos.y -= 32
	var square_node = get_node_or_null("/root/TestMap/Grid/" + str(current_pos.x / 64) + "_" + str(current_pos.y / 64))
	
	var occupant = square_node.get_occupant()
	
	if(occupant != null && occupant.collider.get_parent().allegiance == 0 && occupant.collider.get_parent().current_turn_status != Unit.turn_status.turn_ended):
		selected_unit = occupant.collider.get_parent()
		selected_unit.current_turn_status = Unit.turn_status.deciding_move

func move_unit():
	var selected_square = get_current_square()
	if selected_square.selectable:
		original_position = selected_unit.transform.origin
		selected_unit.set_movement(selected_square)
		disable_cursor()
		selected_unit.current_turn_status = Unit.turn_status.moving

func clear():
	selected_unit = null
	original_position = null

func enable_cursor(): #Add camera focus to cursor
	enabled = true
	is_action_menu_open = false
	$Sprite2D.show()

func disable_cursor(): #Remove camera focus to cursor and give it to the unit focus
	enabled = false
	$Sprite2D.hide()

