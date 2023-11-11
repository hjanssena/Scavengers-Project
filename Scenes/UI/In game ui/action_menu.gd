extends Control
signal show_attack_menu (cursor)
signal hide_attack_menu

var current_unit
var cursor
var attack_menu

func _ready():
	visible = false
	$VBoxContainer/AttackButton.release_focus()

func _process(delta):
	if visible:
		if Input.is_action_just_pressed("cancel_button"):
			cursor.enable_cursor()
			current_unit.transform.origin = cursor.original_position
			cursor.transform.origin = cursor.original_position
			current_unit.current_turn_status = Unit.turn_status.deciding_move
			visible = false

func _on_attack_button_pressed():
	$VBoxContainer/AttackButton.release_focus()
	visible = false
	emit_signal("show_attack_menu",cursor)

func _on_skills_button_pressed():
	pass 

func _on_wait_button_pressed():
	current_unit.end_turn()
	cursor.clear()
	visible = false

func _on_cursor_show_action_menu(map_cursor):
	if !visible:
		cursor = map_cursor
		current_unit = cursor.selected_unit
		visible = true
		$VBoxContainer/AttackButton.grab_focus();

func _on_cursor_hide_action_menu():
	visible = false
	current_unit = null


func _on_attack_menu_show_action_menu():
	visible = true
	$VBoxContainer/AttackButton.grab_focus();
