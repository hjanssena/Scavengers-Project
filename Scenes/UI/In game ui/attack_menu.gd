extends Control
var action_menu
signal show_action_menu
signal hide_action_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		if Input.is_action_just_pressed("cancel_button"):
			emit_signal("show_action_menu")
			visible = false

func _on_action_menu_show_attack_menu(cursor):
	visible = true
	$MainVBox/Weapon1.grab_focus()

func _on_action_menu_hide_attack_menu():
	pass # Replace with function body.
