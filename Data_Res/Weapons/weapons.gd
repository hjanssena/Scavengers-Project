extends Resource
class_name Weapons
enum weapon_types {heavy_melee, light_melee, heavy_gun, light_gun, shield, magic, hacking, healing}
enum damage_types {physical, magical, healing}

@export_category("Weapon stats & info")
@export var name: String
@export var description: String
@export var weapon_type: weapon_types
@export var damage_type: damage_types
@export var dam_heal_value: int #Damage or healing value
@export var weapon_level: int #Increases in damage when leveling skill
@export var cooldown: int #Cooldown in turn numbers
@export var weight: int # Affects Speed and movement value, higher value lowers speed and movement in relation to build stat
@export var complexity: int #Affects skill value in relation to the weapon proficiency stat
@export var status_effect: Status_Effects #
@export var status_hit: float #From 0 to 1, percentage chance of applying the status effect

@export_category("Throw variables")
@export var throw_value: int #How much damage/healing is done when thrown
@export var square_status_effect: Square_Status_Effects #Name of square status effect it applies when thrown, not all weapons will have one

@export_category("Range and area of effect")
@export var range: Array[Vector2] #x,y coordinates of reachable squares taking the caster's current position as 0,0
@export var area_of_effect: Array[Vector2] #x,y coordinates of affected squares taking the square the skill was casted on as 0,0
@export var perspective_sensitive: bool #If true, the weapon will consider the perspective of the weapon user when calculating the aoe
@export var throw_range: Array[Vector2]
@export var throw_area_of_effect: Array[Vector2]

@export_category("Resources")
@export var skill_icon: Sprite2D #Icon sprite for showing in the UI
@export var skill_animation: Animation #The animation that plays when the skill is used
@export var skill_sfx: AudioEffect #The sfx that playsr when the skill is usedsW
