extends Label
var original_position

func _ready():
	original_position = position
	visible = false

func _process(delta):
	pass

func show_damage(damage):
	position = original_position
	modulate = Color.RED
	text = damage

func show_healing(healing):
	position = original_position
	modulate = Color.GREEN
	text = healing

