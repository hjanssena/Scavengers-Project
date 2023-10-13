extends Node2D
signal show_action_menu (cursor)
signal hide_action_menu
enum CursorMode {normal, target_select}

var cursor_moving
var original_position
var selected_unit
var enabled
var manager

func _ready():
	manager = get_node("/root/" + get_tree().get_current_scene().name + "/Manager")

func _process(_delta):
	if enabled:
		move()
		if selected_unit == null:
			check_current_square()
		elif selected_unit != null && !selected_unit.moving:
			selected_unit.find_selectable_squares()
			if Input.is_action_just_pressed("action_button"):
				var selected_square = get_current_square()
				if selected_square.selectable:
					selected_unit.set_movement(selected_square)
					disable_cursor(null)
		if(Input.is_action_just_pressed("action_button")):
			select_unit()
		if(Input.is_action_just_pressed("cancel_button")):
			clear()
	else:
		if selected_unit == null && manager.current_turn == 0:
			enable_cursor() 
		elif !selected_unit.moving && selected_unit.has_moved && manager.current_turn == 0:
			emit_signal("show_action_menu",self)

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
	
	if(occupant != null && occupant.collider.get_parent().allegiance == 0):
		selected_unit = occupant.collider.get_parent()

func clear():
	selected_unit = null
	original_position = null

func enable_cursor(): #Add camera focus to cursor
	enabled = true
	$Sprite2D.show()

func disable_cursor(camera_focus): #Remove camera focus to cursor and give it to the unit focus
	enabled = false
	$Sprite2D.hide()

