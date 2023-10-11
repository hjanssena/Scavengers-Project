extends Node2D
var squares

func _ready():
	squares = get_children()
	for square in squares:
		var sqr_position = square.transform.get_origin()
		square.set_name(str(sqr_position.x / 64) + "_" + str(sqr_position.y / 64))

func reset_squares():
	for square in squares:
		square.reset_values()
