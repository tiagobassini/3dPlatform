extends Node3D
class_name Weather

@export var target: Node3D

@export var init_wind_force: int = -30
@export var init_rain_force: int = 1000


@onready var wind_particles: GPUParticles3D = $Wind/Wind_Particles
@onready var gpu_particles_3d: GPUParticles3D = $ThunderVFX/GPUParticles3D
@onready var rain_particles: GPUParticles3D = $Rain/Rain_Particles

@onready var weather_animation_player: AnimationPlayer = $WeatherAnimationPlayer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_wind_force(init_wind_force)
	_set_rain_force(init_rain_force)
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	
	pass


func _set_wind_force(wind_force:int)->void:
	
	var direction:int = -1 if wind_force < 0 else 1
	
	wind_particles.emitting = false if wind_force ==0 else true
	rain_particles.process_material.gravity.x = wind_force
	
	#wind attributes
	wind_force = abs(wind_force)
	wind_particles.process_material.direction.x = direction
	wind_particles.process_material.initial_velocity_min = wind_force
	wind_particles.process_material.initial_velocity_max = wind_force
	wind_particles.draw_pass_1.size = (wind_force / 10)
	wind_particles.process_material.emission_shape_offset.x = 10 if direction ==-1 else -10
	
	
func _set_rain_force(rain_force:int)->void:
	
	rain_particles.emitting = false if rain_force ==0 else true
	rain_particles.amount = rain_force
	pass

