extends PanelContainer

func _on_cursor_cursor_move(current_square):
	$MarginContainer/GridContainer/SpdEffect.text = str(current_square.bonus_speed)
	$MarginContainer/GridContainer/SklEffect.text = str(current_square.bonus_skill)
	$MarginContainer/GridContainer/BuffEffect.text = str(current_square.bonus_defense)
