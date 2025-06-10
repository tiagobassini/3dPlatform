extends Node3D

@onready var ground_sensor: Node3D = $GroundSensor
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var spikes: Node3D = $Spikes

var passed: bool = false

var spikes_count: int = 0


func _ready() -> void:
	print("spell")
	#_verify_ground_size()
	pass

func _physics_process(_delta: float) -> void:
	
	if not passed:
		passed = true
		_verify_ground_size()
	pass


func _verify_ground_size()->void:
	var end_ground = false
	var sensores:Array = ground_sensor.get_children()
	for sensor:RayCast3D in sensores :
		await get_tree().process_frame
		if not sensor.is_colliding():
			print("i: ", spikes_count , " não colidiu")
			end_ground = true
		
		if end_ground :
			var spike: Node3D = spikes.get_child(spikes_count)
			#spike.hide()
			spike.show()
			var stone = spike.get_child(0)
			if stone.name.contains("Stone"):
				stone.get_child(0).queue_free()
			
		else:
			#print("i: ", spikes_count , " colidiu")
			spikes.get_child(spikes_count).show()
			#print("spike ",spikes_count, ": ",spikes.get_child(spikes_count).name, " foi exibido")
		spikes_count+=1
	
	animation_player.play("Init")
	pass



func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.
