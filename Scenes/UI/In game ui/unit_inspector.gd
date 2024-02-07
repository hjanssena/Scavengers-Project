extends PanelContainer


func _on_cursor_cursor_move(current_square):
	var unit = current_square.get_occupant_unit()
	if(unit != null):
		visible = true
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLbl.text = unit.info.name
		$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/WeaponLbl.text = unit.equiped_weapon.name
		$MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/TextureRect.texture = unit.info.portrait
		$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/HitpointsLbl.text = str(unit.hitpoints) + "/" + str(unit.info.hit_points)
		$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/VBoxContainer/HitpointsBar.max_value = unit.info.hit_points
		$MarginContainer/VBoxContainer/MarginContainer/HBoxContainer2/VBoxContainer/HitpointsBar.value = unit.hitpoints
	else:
		visible = false
