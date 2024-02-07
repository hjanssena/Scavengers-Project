extends Resource
class_name unit_info
enum Allignments{los_buenos}

@export_category("Resources")
@export var portrait: Texture2D
@export var map_sprite: AnimatedSprite2D
@export var inventory: Array[Weapons]

@export_category("Info")
@export var name: String
@export var race: Races
@export var description: String
@export var allignment: Allignments

@export_category("Stats")
@export var level: int
@export var hit_points: int
@export var strength: int
@export var magic_stat: int
@export var defense: int
@export var resistance: int
@export var skill: int
@export var speed: int
@export var movement: int
@export var build: int

@export_category("Stats_Growth_Rate")
@export var hit_points_growth: int
@export var strength_growth: int
@export var magic_stat_growth: int
@export var defense_growth: int
@export var resistance_growth: int
@export var skill_growth: int
@export var speed_growth: int
@export var build_growth: int

@export_category("Weapon Preferences") #These go from 1 to 5
@export var heavy_melee: int
@export var light_melee: int
@export var heavy_gun: int
@export var light_gun: int
@export var shield: int
@export var magic_weapon: int
@export var hacking: int
@export var healing: int

