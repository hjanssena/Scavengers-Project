extends Resource
class_name Square_Status_Effects
enum triggers{turn_start, all_the_time}
enum stats {hit_points, strength, magic, defense, resistance, skill, speed, build}

@export var name: String
@export var description: String
@export var trigger: triggers
@export var duration: int
@export var stat_affected: stats
@export var value: int
@export var particles: GPUParticles2D
@export var sfx: AudioEffect
