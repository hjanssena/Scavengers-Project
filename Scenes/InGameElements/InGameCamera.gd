extends Camera2D
enum cameraMode { xScroll, yScroll, free, locked }

var target
@export var speed: float
@export var xLimit: float
@export var yLimit: float
@export var xOffset: float
@export var yOffset: float
@export var wantedX: float
@export var wantedY: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null: transform.origin = target.transform.origin

