extends Resource
class_name Status_Effects
enum status_effect_types {stat_modifier, turn_blocker, damaging, healing, square}
enum damage_types {physical, magical}
enum stats {hit_points, strength, magic, defense, resistance, skill, speed, build}

@export var name: String
@export var description: String
@export var effect_type: status_effect_types
@export var damage_type: damage_types
@export var duration: int #In turns
@export var stat_affected: stats
@export var value: int

@export_category("Resources")
@export var particles: GPUParticles2D
@export var sfx: AudioEffect
@export var icon: Sprite2D
