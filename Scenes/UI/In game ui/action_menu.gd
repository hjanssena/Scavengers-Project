extends Control
var current_unit

func _ready():
	visible = false
	$VBoxContainer/AttackButton.release_focus()

func _on_attack_button_pressed():
	pass 

func _on_skills_button_pressed():
	pass 

func _on_wait_button_pressed():
	current_unit.turn_ended = true

func _on_cursor_show_action_menu(cursor):
	if !visible:
		visible = true
		$VBoxContainer/AttackButton.grab_focus()


func _on_cursor_hide_action_menu():
	visible = false
	current_unit = null
