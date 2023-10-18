extends Resource
class_name Skills
enum skill_type {healing, attacking, effect}

@export_category("Base stats")
@export var name: String
@export var type: skill_type
@export var description: String
@export var dam_heal_value: int #Damage or healing value
@export var level_scaling: int #Increases in damage when leveling skill
@export var cooldown: int #Cooldown in turn numbers
@export var complexity: float #From 0 to 1, affects the unit's skill value, if higher its harder to hit with the skill
var status_effect #Pending to add class
@export var status_hit: float #From 0 to 1, percentage chance of applying the status effect 

@export_category("Range and area of effect")
@export var range: Array[Vector2] #x,y coordinates of reachable squares taking the caster's current position as 0,0
@export var area_of_effect: Array[Vector2] #x,y coordinates of affected squares taking the square the skill was casted on as 0,0

@export_category("Resources")
@export var skill_icon: Sprite2D #Icon sprite for showing in the UI
@export var skill_animation: Animation #The animation that plays when the skill is used
@export var skill_sfx: AudioEffect #The sfx that playsr when the skill is useds
