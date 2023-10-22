extends Resource
class_name Status_Effects
enum status_effect_type {stat_modifier, turn_blocker}

@export var name: String
@export var description: String
@export var type: status_effect_type
@export var stat_affected: String
@export var value: int

@export_category("Resources")
@export var particles: GPUParticles2D
@export var sfx: AudioEffect
@export var icon: Sprite2D
