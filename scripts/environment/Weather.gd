extends Node3D
class_name Weather

@export var target: Node3D

@export var current_wind_force: int = -30
@export var current_rain_force: int = 1000


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

func _physics_process(_delta: float) -> void:
	follow_target()
	thunder_animation()
	wind_force_drag()
	pass


func _set_wind_force(wind_force:int)->void:
	current_wind_force = wind_force
	
	var direction:int = -1 if wind_force < 0 else 1
	
	
	rain_particles.process_material.gravity.x = wind_force
	
	#wind attributes
	wind_force = abs(wind_force)
	wind_particles.emitting = false if wind_force ==0 else true
	wind_particles.amount = wind_force + 10
	wind_particles.process_material.direction.x = direction
	wind_particles.process_material.initial_velocity_min = wind_force
	wind_particles.process_material.initial_velocity_max = wind_force
	@warning_ignore("integer_division")
	wind_particles.draw_pass_1.size = wind_force / 10
	wind_particles.process_material.emission_shape_offset.x = 10 if direction ==-1 else -10
	
	wind_force_effect_area.monitoring= true if wind_force>10 else false
	pass



func _set_rain_force(rain_force:int)->void:
	current_rain_force = rain_force
	rain_particles.emitting = false if rain_force ==0 else true
	rain_particles.amount = rain_force
	pass

func rain_force_update()->void:
	var prob:int = randi() % 100
	
	if prob % 2 ==0:
		return
	
	var new_rain_force:int = (randi() %15 +1) *100
	_set_wind_force(new_rain_force)
	pass



func wind_force_update()->void:
	var prob:int = randi() % 100
	
	if prob % 2 ==0:
		return
	
	var new_wind_force:int = randi_range(-3,3)
	new_wind_force = 0 if new_wind_force<2 and new_wind_force>-2 else new_wind_force
	_set_wind_force(new_wind_force)
	
	
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
		print("prob: ", prob)
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
	
	rain_force_update()
	wind_force_update()
	
	pass # Replace with function body.
