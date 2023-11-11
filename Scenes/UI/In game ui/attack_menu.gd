extends Control
var action_menu
signal show_action_menu
signal hide_action_menu

var cursor
var selected_unit
var on_focus = false #We want a frame to pass after making the panel visible

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible && on_focus:
		if Input.is_action_just_pressed("cancel_button"):
			emit_signal("show_action_menu")
			visible = false
	on_focus = true

func _on_action_menu_show_attack_menu(ncursor):
	cursor = ncursor
	selected_unit = cursor.selected_unit
	populate_buttons()
	visible = true
	$MainVBox/Weapon1.grab_focus()

func _on_cursor_show_attack_menu(ncursor):
	cursor = ncursor
	selected_unit = cursor.selected_unit
	populate_buttons()
	visible = true
	on_focus = false
	$MainVBox/Weapon1.grab_focus()

func _on_action_menu_hide_attack_menu():
	pass # Replace with function body.

func populate_buttons():
	if selected_unit.info.inventory[0] != null:
		$MainVBox/Weapon1.text = selected_unit.info.inventory[0].name
	else:
		$MainVBox/Weapon1.text = "No available weapons"
	if selected_unit.info.inventory[1] != null:
		$MainVBox/Weapon2.text = selected_unit.info.inventory[1].name
	else:
		$MainVBox/Weapon2.visible = false
	if selected_unit.info.inventory[2] != null:
		$MainVBox/Weapon3.text = selected_unit.info.inventory[2].name
	else:
		$MainVBox/Weapon3.visible = false
	if selected_unit.info.inventory[3] != null:
		$MainVBox/Weapon4.text = selected_unit.info.inventory[3].name
	else:
		$MainVBox/Weapon4.visible = false
	if selected_unit.info.inventory[4] != null:
		$MainVBox/Weapon5.text = selected_unit.info.inventory[4].name
	else:
		$MainVBox/Weapon5.visible = false

func select_weapon(weapon):
	selected_unit.current_turn_status = Unit.turn_status.deciding_target
	visible = false
	cursor.selected_weapon = weapon

func _on_weapon_1_pressed():
	select_weapon(selected_unit.info.inventory[0])

func _on_weapon_2_pressed():
	select_weapon(selected_unit.info.inventory[0])

func _on_weapon_3_pressed():
	select_weapon(selected_unit.info.inventory[0])

func _on_weapon_4_pressed():
	select_weapon(selected_unit.info.inventory[0])

func _on_weapon_5_pressed():
	select_weapon(selected_unit.info.inventory[0])

