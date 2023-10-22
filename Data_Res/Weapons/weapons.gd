extends Resource
class_name Weapons
enum weapon_type {heavy_melee, light_melee, heavy_gun, light_gun, shield, magic, hacking, healing}

@export_category("Weapon stats & info")
@export var name: String
@export var type: weapon_type
@export var description: String
@export var dam_heal_value: int #Damage or healing value
@export var weapon_level: int #Increases in damage when leveling skill
@export var cooldown: int #Cooldown in turn numbers
@export var weight: float #Affects the unit's skill, speed and movement value, higher value means the hit is larger
@export var status_effect: Status_Effects #Pending to add class
@export var status_hit: float #From 0 to 1, percentage chance of applying the status effect
@export var aoe_value_scaling: float #From 0 to 1, percentage for how much damage or healing changes in relation to the distance from the tile the skill was casted on

@export_category("Throw variables")
@export var throw_value: int #How much damage is done when thrown
@export var square_status_effect: Square_Status_Effects #Name of square status effect it applies when thrown, not all weapons will have one

@export_category("Range and area of effect")
@export var range: Array[Vector2] #x,y coordinates of reachable squares taking the caster's current position as 0,0
@export var area_of_effect: Array[Vector2] #x,y coordinates of affected squares taking the square the skill was casted on as 0,0
@export var throw_range: Array[Vector2]
@export var throw_area_of_effect: Array[Vector2]

@export_category("Bonus stats") #These can be positive or negative to impact unit stats
@export var hit_points: int
@export var strength: int
@export var magic: int
@export var defense: int
@export var resistance: int
@export var skill: int
@export var speed: int
@export var movement: int

@export_category("Resources")
@export var skill_icon: Sprite2D #Icon sprite for showing in the UI
@export var skill_animation: Animation #The animation that plays when the skill is used
@export var skill_sfx: AudioEffect #The sfx that playsr when the skill is usedsW
