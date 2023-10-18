extends Resource
class_name unit_info
enum Races{furries}
enum Allignments{los_buenos}

@export_category("Info")
@export var name: String
@export var race: Races
@export var description: String
@export var allignment: Allignments

@export_category("Stats")
@export var level: int
@export var hit_points: int
@export var strength: int
@export var magic: int
@export var defense: int
@export var resistance: int
@export var skill: int
@export var speed: int
@export var build: int

@export_category("Resources")
@export var portrait: Sprite2D
@export var map_sprite: AnimatedSprite2D
