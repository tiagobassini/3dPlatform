extends Node3D
class_name Weather

@export var target: Node3D

@export_range(-4,4) var current_wind_force: float = 2
@export_range(0, 4) var max_wind_intensity:float =4


@export_range(0,30) var current_rain_force: int = 20
@export_range(0, 30) var max_rain_intensity:int = 30
var newer_wind_force: float


@onready var wind_particles: GPUParticles3D = $Wind/Wind_Particles
@onready var thunder_particles: GPUParticles3D = $ThunderVFX/Thunder_Particles
@onready var rain_particles: GPUParticles3D = $Rain/Rain_Particles

@onready var thunder_animation_player: AnimationPlayer = $ThunderVFX/ThunderAnimationPlayer
@onready var wind_force_effect_area: Area3D = $Wind/Wind_Particles/WindForceEffectArea

var anim_finished:bool = true

var body_list = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	randomize()
	_set_wind_force(current_wind_force)
	_set_rain_force(current_rain_force)
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	follow_target()
	thunder_animation()
	wind_force_drag()
	
	verify_weather_change(delta)
	pass

func _set_wind_force(wind_force:float)->void:
	newer_wind_force = wind_force

func _update_wind(_delta:float)->void:
	
	current_wind_force =  move_toward(current_wind_force, newer_wind_force, _delta)
	
	var direction:int = -1 if current_wind_force < 0.0 else 1
	
	#current_wind_force *=10
	rain_particles.process_material.gravity.x = current_wind_force*10
	
	#wind attributes
	var wind_force:float = abs(current_wind_force)*10
	wind_particles.emitting = false if wind_force == 0.0 else true
	wind_particles.amount = int(wind_force) + 10
	wind_particles.process_material.direction.x = direction
	wind_particles.process_material.initial_velocity_min = wind_force
	wind_particles.process_material.initial_velocity_max = wind_force
	#@warning_ignore("integer_division")
	wind_particles.draw_pass_1.size = wind_force / 10.0
	wind_particles.process_material.emission_shape_offset.x = 10 if direction ==-1 else -10
	
	wind_force_effect_area.monitoring= true if wind_force>10 else false
	pass

func _set_rain_force(rain_force:int)->void:
	current_rain_force = rain_force
	rain_particles.emitting = false if rain_force ==0 else true
	pass

func verify_weather_change(_delta:float)->void:
	var rain_force = current_rain_force*100
	if rain_force != rain_particles.amount :
		rain_particles.amount = lerp(rain_particles.amount, rain_force, 0.2 )
	
	if current_wind_force != newer_wind_force :
		_update_wind(_delta)
		pass

func wind_force_drag()->void:
	
	for body in body_list:
		if body as Player:
			
			if current_wind_force == 0.0 :
				return
			elif current_wind_force >0.0:
				body.velocity.x = clamp(current_wind_force*0.05, 1.0,1.5)
			elif current_wind_force <0.0:
				body.velocity.x = clamp(current_wind_force*0.05, -1.0,-1.5)
			#print(body.name," - wind Velocidade X: ",body.velocity.x)
		elif body as RigidBody3D :
			body.linear_velocity.x = lerpf(body.linear_velocity.x,clamp(current_wind_force*0.04, -1.5,1.5),0.05)
			body.linear_velocity.z=0
			#print(body.name," - wind Velocidade X: ",body.linear_velocity.x)
	
	pass

func _on_wind_area_body_entered(body: Node3D) -> void:
	body_list.append(body)
	pass # Replace with function body.

func _on_wind_area_body_exited(body: Node3D) -> void:
	body_list.erase(body)
	pass # Replace with function body.

func thunder_animation()->void:
	if anim_finished :
		var prob = randi() % 100
		#print("prob: ", prob)
		anim_finished=false
		if prob <=50:
			thunder_particles.amount = (randi()%5)+1
			thunder_animation_player.play("thunder_light")
		else:
			await get_tree().create_timer(2.0).timeout
			anim_finished = true

func _on__animation_finished(_anim_name: StringName) -> void:
	anim_finished = true
	pass # Replace with function body.

func follow_target()->void:
	if target!=null:
		global_position.x = target.global_position.x


func _on_weather_update_timeout() -> void:
	
	if randi() % 100 % 2 ==0:
		var new_rain_force:int = ((randi() % max_rain_intensity)+1)
		_set_rain_force(new_rain_force)
	
	if current_rain_force <5 :
		_set_wind_force(0)
	else:
		if (randi() % 10) % 2 ==0:
			return
		
		var new_wind_force:float = randf_range(-max_wind_intensity,max_wind_intensity)
		new_wind_force = 0.0 if new_wind_force<2.0 and new_wind_force>-2.0 else new_wind_force
		print("new wind force: ", new_wind_force)
		_set_wind_force(new_wind_force)
	pass 
