extends Node2D
enum CursorMode {normal, target_select}

var cursor_moving

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move()
	check_current_square()
	

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
