extends ProgressBar
var displayed_value
var unit
var manager

# Called when the node enters the scene tree for the first time.
func _ready():
	unit = self.get_parent().get_parent()
	displayed_value = 0
	manager = get_node("/root/" + get_tree().get_current_scene().name + "/Manager/")

func _process(delta):
	var square = unit.get_current_square()
	if square != null && square.affected: 
		value = unit.hitpoints - displayed_value
		if manager.peek_bars_on: visible = true
		else: visible = false
	else: 
		value = unit.hitpoints
		visible = false
