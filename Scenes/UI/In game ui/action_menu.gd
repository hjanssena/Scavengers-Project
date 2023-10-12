extends Control
var current_unit

func _ready():
	hide()

func _on_attack_button_pressed():
	pass 

func _on_skills_button_pressed():
	pass 

func _on_wait_button_pressed():
	pass

func _on_cursor_show_action_menu(unit):
	current_unit = unit
	show()
	$VBoxContainer/AttackButton.grab_focus()

func _on_cursor_hide_action_menu():
	hide()
	current_unit = null
