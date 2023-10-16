extends Label
var original_position
var velocity = 50
var fade_speed = 10
var duration = 2.5

func _ready():
	original_position = position
	visible = false

func _process(delta):
	if visible:
		position = Vector2.UP * velocity * delta
		modulate.a = modulate.a - fade_speed * delta
	if modulate.a <= 0:
		visible = false

func show_damage(damage):
	visible = true
	position = original_position
	modulate = Color.RED
	text = damage

func show_healing(healing):
	visible = true
	position = original_position
	modulate = Color.GREEN
	text = healing
